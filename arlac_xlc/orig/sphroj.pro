function sphroj,inrad,ourad,drad=drad,xrange=xrange,yrange=yrange,$
	nx=nx,ny=ny,verbose=verbose, _extra=e
;+
;function	sphroj
;	return a 2D image projection of a possibly hollow spherical
;	volume with a radially varying intensity profile by computing
;	the integrals of the intensity along the line of sight.
;
;parameters
;	inrad	[INPUT; required] inner radius of sphere
;	ourad	[INPUT; required] outer radius of sphere
;
;keywords
;	drad	[INPUT] thickness of each slice
;		* default: (OURAD-INRAD)/20
;	xrange	[INPUT] range in x-values (default=[-2*OURAD,2*OURAD])
;	yrange	[INPUT] range in x-values (default=[-2*OURAD,2*OURAD])
;	nx	[INPUT] number of elements along X (default=512L)
;	ny	[INPUT] number of elements along Y (default=512L)
;	verbose	[INPUT] if set, becomes garrulous -- plots a lot
;	_extra	[INPUT] keywords for CCIRCLE and PATHPROJ
;		* CCIRCLE: NORM, SMALL, RAND
;		* PATHPROJ: RFUNCT, SCLHT, NSTEP, HALFSH, CONEANG
;
;subroutines
;	CCIRCLE
;	PATHPROJ
;	KILROY
;
;history
;	vinay kashyap (MIM.XI)
;	changed keyword V to VERBOSE (VK; IMVIM.I)
;-

;	usage
ninr=n_elements(inrad) & nour=n_elements(ourad)
if ninr eq 0 or nour eq 0 then begin
  print,'Usage: img=sphroj(inrad,ourad,drad=drad,xrange=xr,yrange=yr,$'
  print,'       nx=nx,ny=ny,verbose=verbose, norm=norm,/small,/rand,$'
  print,'       rfunct=rfunct,sclht=sclht,nstep=nstep,$'
  print,'       /halfsh,coneang=coneang)'
  print,'  returns 2D projection of spherical volume with opaque core'
  return,0*ccircle(0,0,1, _extra=e)
endif

;	check inputs
ok='ok'
if ninr gt 1 then ok='cannot handle multiple inner cores' else $
 if nour gt 1 then ok='cannot handle multiple spheres' else $
  if ourad(0) le inrad(0) then ok='outer radius smaller then inner?'
if ok ne 'ok' then begin
  message,ok,/info & return,0*ccircle(0,0,1, _extra=e)
endif

;	keywords
delr=(ourad-inrad)/20.
xr=[-2.*ourad(0),2*ourad(0)] & yr=xr & binx=512L & biny=binx
if keyword_set(drad) then delr=drad(0)
if n_elements(xrange) eq 2 then xr=[xrange(0),xrange(1)]
if n_elements(yrange) eq 2 then yr=[yrange(0),yrange(1)]
if xr(0) gt xr(1) then xr=reverse(xr) & if yr(0) gt yr(1) then yr=reverse(yr)
if xr(0) eq xr(1) then xr(1)=xr(0)+1. & if yr(0) eq yr(1) then yr(1)=yr(0)+1.
if keyword_set(nx) then binx=long(nx(0)) > 1L
if keyword_set(ny) then biny=long(ny(0)) > 1L
if not keyword_set(verbose) then vv=0 else vv=long(verbose(0))>1
;
xpix=(xr(1)-xr(0))/binx & ypix=(yr(1)-yr(0))/biny

;	define output
xc=0. & yc=0.
img=0.0*ccircle(xc,yc,inrad,xrange=xr,yrange=yr,nx=binx,ny=biny, _extra=e)

;	project each pixel
kx=binx/2 & ky=biny/2
for ix=0L,kx do begin
  if vv gt 0 then kilroy; was here.
  if vv gt 1 then kilroy,dot=strtrim(ix,2)
  for iy=0L,ky do begin
    ;d=sqrt(xpix^2*(ix-binx/2.)^2+ypix^2*(iy-biny/2)^2)
    dx=xpix*(ix-binx/2.) & dy=ypix*(iy-biny/2.)
    p=pathproj([dx,dy],inrad,maxrad=ourad,verbose=vv, _extra=e)
    img(ix,iy)=p
    if p lt 0 then stop,ix,iy
    ;	replicate each quarter
    img(binx-ix-1L,iy)=p
    img(ix,biny-iy-1L)=p
    img(binx-ix-1L,biny-iy-1L)=p
    if vv gt 1 and iy eq 0 then tvscl,img
  endfor
endfor


return,img
end
