function sphervol,inrad,ourad,drad=drad,xc=xc,yc=yc,v=v, _extra=e
;+
;function	sphervol
;	return a 2D image projection of a spherical volume with an inner
;	"opaque" spherical volume by summing over volume in slices
;
;parameters
;	inrad	[INPUT; required] inner radius of sphere
;	ourad	[INPUT; required] outer radius of sphere
;
;keywords
;	drad	[INPUT] thickness of each slice
;		* default: (OURAD-INRAD)/20
;	xc	[INPUT; default=0] x-coordinate of center of projection
;	yc	[INPUT; default=0] y-coordinate of center of projection
;	v	[INPUT] if set, becomes garrulous -- plots a lot
;	_extra	[INPUT] keywords for CCIRCLE
;
;subroutines
;	CCIRCLE
;	KILROY
;
;history
;	vinay kashyap (Apr99)
;-

;	usage
ninr=n_elements(inrad) & nour=n_elements(ourad)
if ninr eq 0 or nour eq 0 then begin
  print,'Usage: img=sphervol(inrad,ourad,drad=drad,xc=xc,yc=yc,v=v,$'
  print,'       xrange=xr,yrange=yr,nx=nx,ny=ny,norm=norm,/small,/rand)'
  print,'  returns 2D projection of spherical shell with opaque core'
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
if keyword_set(drad) then delr=drad(0)
if not keyword_set(xc) then xc=0
if not keyword_set(yc) then yc=0
if not keyword_set(v) then v=0

;	default output image
img=0*ccircle(xc,yc,1, _extra=e)
img_o=img	;the opaque part

if keyword_set(v) then tvscl,img

z=ourad
while z ge -ourad do begin
  z0=z & z1=z-drad & zz=0.5*(z0+z1)	;zz=center of slice, == r*sin(theta)
  z=z-drad				;step
  th_out=acos(zz/ourad)		;intersection angle of slice w.  surface
  r_out=ourad*sin(th_out)		;radius of transparent slice
  img_t=ccircle(xc,yc,r_out, _extra=e)	;the transparent stuff
  th_in=0. & r_in=0.
  if zz le inrad then begin
    th_in=acos(zz/inrad)		;as above, for opaque sphere
    r_in=inrad*sin(th_in)		;radius of opaque slice
    img_o=img_o+ccircle(xc,yc,r_in, _extra=e)	;the opaque stuff
  endif
  if v gt 1 then print,z,zz,r_in,r_out,th_in,th_out
  if not keyword_set(v) then kilroy; was here.
  ;
  oo=where(img_o gt 0,moo)
  if moo gt 0 then img_t(oo)=0.
  img=img+img_t*drad
  ;
  if v eq 1 then tvscl,alog10(img+0.01)
  ;
  oo=where(img_t gt 0,moo) & if moo eq 0 then z=-ourad-drad	;out!
endwhile

return,img
end
