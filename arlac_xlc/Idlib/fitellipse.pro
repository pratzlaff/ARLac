pro fitellipse,img,a,b,xcen,ycen,phi,result=result,thresh=thresh,wei=wei
;+
;procedure	fitellipse
;	fits an ellipse to a segment in an image
;
;parameters
;	img	[INPUT; required] input image
;	a	[OUTPUT] major-axis
;	b	[OUTPUT] minor-axis
;	xcen	[OUTPUT] x-coord of center
;	ycen	[OUTPUT] y-coord of center
;	phi	[OUTPUT] orientation
;
;keywords
;	thresh	[INPUT; default=0] threshold to be used to segment the
;		input image
;	wei	[INPUT; default=0] weighting to use
;		* if scalar, use IMG^WEI
;		* if vector, *must* match IMG else IMG will be used
;	result	[OUTPUT] array of
;		[A,B,XCEN,YCEN,PHI,Mxx,Myy,pixels]
;
;history
;	vinay kashyap (Apr98)
;-

;	usage
npix=n_elements(img)
if npix le 5 then begin
  print,'Usage: fitellipse,img,a,b,xcen,ycen,phi,result=result,thresh=thresh'
  print,'  fits an ellipse to a segment in an image'
  return
endif

;	initialize
a=1. & b=1. & xcen=0 & ycen=0 & phi=0. & Mxx=1. & Myy=1. & pixels=1
result=[A,B,XCEN,YCEN,PHI,Mxx,Myy,pixels]
;	get the axes
sz=size(img) & nx=sz(1) & ny=sz(2) & xx=findgen(nx)+1 & yy=findgen(ny)+1
ix=fltarr(nx,ny) & for j=0,ny-1 do ix(*,j)=xx
jy=fltarr(nx,ny) & for i=0,nx-1 do jy(i,*)=yy

;	figure out the weight
if keyword_set(wei) then begin
  if n_elements(wei) eq 1 then wt=img^wei(0)
  if n_elements(wei) ne npix then wt=img
  wt=reform(wt,nx,ny)
endif else wt=0*img+1

;	use the threshold
if not keyword_set(thresh) then thr=0. else thr=thresh
oo=where(img le thr,moo)
if moo eq npix then begin
  message,'threshold too high?  no area selected',/info
  return
endif
wt(oo)=0.

;	make the calcs
weight=total(wt)
xcen=total(wt*ix)/weight & ycen=total(wt*jy)/weight
Mxx=total(wt*(ix-xcen)^2)/weight & Myy=total(wt*(jy-ycen)^2)/weight
Mxy=total(wt*(ix-xcen)*(jy-ycen))/weight
a=sqrt(2*(Mxx+Myy) + sqrt((Mxx-Myy)^2+4*Mxy^2))
b=sqrt(2*(Mxx+Myy) - sqrt((Mxx-Myy)^2+4*Mxy^2))
phi=atan(2*Mxy,(Mxx-Myy))
result=[A,B,XCEN,YCEN,PHI,Mxx,Myy,npix-moo]

cc='A='+strtrim(a,2)+' ; B='+strtrim(b,2)+' ; Xcen='+strtrim(xcen,2)+$
	' ; Ycen='+strtrim(ycen,2)+' ; PHI='+strtrim(phi*180/!pi,2)
if n_params() lt 2 then message,cc,/info

return
end
