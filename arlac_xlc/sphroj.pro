function sphroj,inrad,ourad,drad=drad,xrange=xrange,yrange=yrange,$
	nx=nx,ny=ny,root=root,libdir=libdir,verbose=verbose,$
	rfunct=rfunct,sclht=sclht,coneang=coneang,$
	_extra=e
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
;	root	[INPUT] look for previously saved library files named
;			ROOT_NNNNxNNNN_FFFF_FFFF_RRRRR_SSSS_sCCC.save
;		where NNNNxNNNN == NX,NY, FFFF_FFFF is INRAD_OURAD in f4.2,
;		RRRRR is 'expon'/'const'/'invsq' is the type of radial
;		dependency, SSSS is the scale height in f4.2, and sCCC is
;		the cone angle in sign (p/m) and abs f3.1
;		* strongly recommend setting ROOT to include the HALFSH
;		  and NSTEP keywords, e.g., "G100h", "K201full", etc.
;		* there is no default.  ignored if not set.
;	libdir	[INPUT] look for the library files in this directory
;		* ignored if ROOT is not set
;		* default is './'
;		* NOTE: if the appropriate library save file
;		  -- exists in LIBDIR: then it will be read in and
;		     the call to PATHPROJ will be skipped.
;		  -- does not exist in LIBDIR: the image calculated
;		     with PATHPROJ will be written out to appropriately
;		     named save file in LIBDIR
;	verbose	[INPUT] if set, becomes garrulous -- plots a lot
;	rfunct	[INPUT] function describing intensity variation along the
;		radius; passed on w/o modification to PATHPROJ
;		* default is "const"
;	sclht	[INPUT] scale-height for exponential drop-off
;		* default is abs(OURAD-INRAD)>1
;	coneang	[INPUT] opening cone angle in [degree]
;		* default is +90
;	_extra	[INPUT] keywords for CCIRCLE and PATHPROJ
;		* CCIRCLE: NORM, SMALL, RAND
;		* PATHPROJ: NSTEP, HALFSH
;
;subroutines
;	CCIRCLE
;	PATHPROJ
;	KILROY
;
;history
;	vinay kashyap (MIM.XI)
;	changed keyword V to VERBOSE (VK; IMVIM.I)
;	added keywords ROOT, LIBDIR, RFUNCT, SCLHT, CONEANG (VK; MMXII.V)
;-

;	usage
ninr=n_elements(inrad) & nour=n_elements(ourad)
if ninr eq 0 or nour eq 0 then begin
  print,'Usage: img=sphroj(inrad,ourad,drad=drad,xrange=xr,yrange=yr,$'
  print,'       nx=nx,ny=ny,root=root,libdir=libdir,verbose=verbose,$'
  print,'       norm=norm,/small,/rand,rfunct=rfunct,sclht=sclht,nstep=nstep,$'
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
;
;	PATHPROJ keywords used to define savefile filename
rrrrr='const' & if keyword_set(rfunct) then begin
  case rfunct of
    'exp': rrrrr='expon'
    'invsq': rrrrr='invsq'
    'bradw': rrrrr='bradw'
    else: rrrrr='const'
  endcase
endif
sss=float(abs(ourad(0)-inrad(0)))>1 & if keyword_set(sclht) then sss=sclht(0)
ssss=string(fix(sss*100.),'(i4.4)')
cc=90. & if keyword_set(coneang) then cc=coneang(0)
if cc ge 0 then ss='p' else ss='m' & ccc=ss+string(abs(fix(cc*10.)),'(i3.3)')
;
;	check for input via savefile
if keyword_set(root) then begin
  froot=strtrim(root[0],2)
  savfil=froot+'_'+string(binx,'(i4.4)')+'x'+string(biny,'(i4.4)')+'_'+$
  	string(fix(inrad(0)*100.),'(i4.4)')+'_'+string(fix(ourad(0)*100.),'(i4.4)')+$
	'_'+rrrrr+'_'+ssss+'_'+ccc+'.save'
  dirlib='.' & if keyword_set(libdir) then dirlib=libdir[0]
  filnam=filepath(savfil,root_dir=dirlib)
  fil=file_search(filnam)
  if keyword_set(fil) then begin
    if vv gt 0 then message,'reading image from '+filnam,/informational
    restore,filnam,/verbose
    return,img
  endif else wrtsavfil=1
endif else wrtsavfil=0

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
    p=pathproj([dx,dy],inrad,maxrad=ourad,verbose=vv,rfunct=rfunct,sclht=sclht,coneang=coneang, _extra=e)
    img(ix,iy)=p
    if p lt 0 then stop,ix,iy
    ;	replicate each quarter
    img(binx-ix-1L,iy)=p
    img(ix,biny-iy-1L)=p
    img(binx-ix-1L,biny-iy-1L)=p
    if vv gt 5 and iy eq 0 then tvscl,img
  endfor
endfor
if keyword_set(wrtsavfil) then begin
  if vv gt 0 then message,'writing image to '+filnam,/informational
  save,file=filnam,img
endif

return,img
end
