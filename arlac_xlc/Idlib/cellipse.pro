function cellipse,xcen,ycen,xwdt,yhgt,angl, xbin=xbin,ybin=ybin,$
	xrange=xrange,yrange=yrange, _extra=e
;+
;function	cellipse
;	returns a bit image of an ellipse, defined by 1s (on ellipse) and 0s
;	(off ellipse)
;
;	ellipses are defined as all points which have
;		(x'/XWDT)^2 + (y'/YHGT)^2  <= 1
;	where 	x'=(x-XCEN)*cos(ANGL)+(y-YCEN)*sin(ANGL)
;	and	y'=-(x-XCEN)*sin(ANGL)+(y-YCEN)*cos(ANGL)
;
;parameters
;	xcen	[INPUT; required] x-position of center of ellipse
;	ycen	[INPUT; required] y-position of center of ellipse
;	xwdt	[INPUT; required] half-width of ellipse
;	yhgt	[INPUT; required] half-height of ellipse
;	angl	[INPUT] rotation angle (default=0 [deg])
;
;keywords
;	xbin	[INPUT] binning size along X-axis, default=1
;	ybin	[INPUT] binning size along Y-axis, default=1
;	xrange	[INPUT] range in X, default=[1,512]
;	yrange	[INPUT] range in Y, default=[1,512]
;
;	_extra	[JUNK] here only to prevent crashing program
;
;subroutines
;	KILROY
;
;history
;	vinay kashyap (Jul92)
;	shiny new version (VK; Dec98)
;-

;	usage
nxc=n_elements(xcen) & nyc=n_elements(ycen)
nxw=n_elements(xwdt) & nyh=n_elements(yhgt)
ok='ok'
if nxc eq 0 then ok='X-center position missing' else $
 if nyc eq 0 then ok='Y-center position missing' else $
  if nxw eq 0 then ok='half-width of ellipse missing' else $
   if nyh eq 0 then ok='half-height of ellipse missing'
if ok ne 'ok' then begin
  print,'Usage: img=cellipse(xcen,ycen,xwdt,yhgt,angl,xbin=xbin,ybin=ybin,$'
  print,'       xrange=xrange,yrange=yrange)'
  print,'  returns image with ellipses'
  return,-1L
endif

;	check inputs
xc=float(xcen) & yc=xc & xw=xc & yh=xc & aa=xc
if nyc le nxc then for i=0,nyc-1 do yc(i)=ycen([i]) else yc=ycen(0:nxc-1)
if nxw le nxc then for i=0,nxw-1 do xw(i)=xwdt([i]) else xw=xwdt(0:nxc-1)
if nyh le nxc then for i=0,nyh-1 do yh(i)=yhgt([i]) else yh=yhgt(0:nxc-1)
nang=n_elements(angl)
if nang eq 0 then aa(*)=0. else begin
  if nang le nxc then for i=0,nang-1 do aa(i)=angl([i]) else $
	aa=angl(0:nxc-1)
endelse
aa=aa*!pi/180.		;[deg] -> [rad]

;	define output image
if not keyword_set(xbin) then binx=1. else binx=float(xbin)
if not keyword_set(ybin) then biny=1. else biny=float(ybin)
if n_elements(xrange) ne 2 then xr=[1.,512.] else xr=float(xrange)
if n_elements(yrange) ne 2 then yr=[1.,512.] else yr=float(yrange)
Nx=long((xr(1)-xr(0))/binx+1.) & Ny=long((yr(1)-yr(0))/biny+1.)
img=intarr(Nx,Ny)

;	make and add ellipses
for i=0,nxc-1 do begin			;{for each defined ellipse
  eidx=2^i		;number with which to mark the ellipse
  if nxc gt 1 then kilroy,dot=strtrim(eidx,2)+'..'
  if xw(i) eq 0 then xw(i)=0.1*binX
  if yh(i) eq 0 then yh(i)=0.1*binY
  xx=findgen(Nx)*binX+xr(0) & yy=findgen(Ny)*biny+yr(0)
  for iy=0L,Ny-1L do begin
    x1=(xx-xc(i))*cos(aa(i))+(yy(iy)-yc(i))*sin(aa(i))
    y1=-(xx-xc(i))*sin(aa(i))+(yy(iy)-yc(i))*cos(aa(i))
    ee=(x1/xw(i))^2 + (y1/yh(i))^2
    oe=where(ee le 1,moe)
    if moe gt 0 then img(oe,iy)=img(oe,iy)+eidx
  endfor
endfor					;I=0,NXC-1}

return,img
end
