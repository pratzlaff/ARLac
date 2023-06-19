function cpie,xc,yc,th1,th2,xrange=xrange,yrange=yrange,nx=nx,ny=ny,pros=pros
;+
;function	cpie
;		returns a bit image of a pie cut
;
;parameters	xc	x-coordinate of center
;		yc	y-coordinate of center
;		th1	beginning angle of pie cut (>0, [degrees])
;		th2	ending angle of pie cut (>0, [degrees])
;
;keywords	xrange	range in x-values (def:[1,512])
;		yrange	range of y-values (def:[1,512])
;		nx	number of elements in x (def: 512)
;		ny	number of elements in y (def: 512)
;		pros	if set, assumes IRAF/PROS convention of angle
;			measurement (anti-clockwise from y-axis)
;
;history	VK	{1/24/94}
;-

;check for correct parameters
np = n_params(0) & img = bytarr(2,2)
if np le 1 or np eq 3 then begin
  print, 'Usage: img = cpie(xc,yc,th1,th2,xrange=[xmin,xmax],$'
  print, '  yrange=[ymin,ymax],nx=nx,ny=ny,/pros)'
  print, '  returns bit image of a pie cut' & return,img
endif
;if only two parameters are given, assume that they are angles, centered on
;the center of the image
if np eq 2 then begin
  th1 = xc & th2 = yc
endif

x0 = xc & y0 = yc & ang1 = th1 & ang2 = th2

;initialize keywords
xr = [1.,512.] & yr = xr & binx = 512L & biny = 512L
if keyword_set(xrange) then begin
  sz = size(xrange) & if sz(0) eq 1 then xr = float(xrange)
endif
if keyword_set(yrange) then begin
  sz = size(yrange) & if sz(0) eq 1 then yr = float(yrange)
endif
if keyword_set(nx) then binx = nx & if keyword_set(ny) then biny = ny
if keyword_set(pros) then begin & ang1=ang1+90. & ang2=ang2+90. & endif

if np eq 2 then begin
  x0 = 0.5*(xr(0)+xr(1)) & y0 = 0.5*(yr(0)+yr(1))
endif
ang1 = modulo(abs(ang1),360.) & ang2 = modulo(abs(ang2),360.)

dx = (xr(1)-xr(0))/(binx-1.) & dy = (yr(1)-yr(0))/(biny-1.)
x = dx*dindgen(binx) + xr(0) & y = dy*dindgen(biny) + yr(0)

img = bytarr(binx,biny)

;short cut!
a1 = modulo(ang1,90.) & a2 = modulo(ang2,90.)
if a1 eq 0. and a2 eq 0. then begin
  if ang1 eq 0. and ang2 eq 0. then return,img
  if ang2 eq 0. then ang2 = 360.
  h1 = where(x ge x0) & h2 = where(y ge y0)
  if h1(0) ne -1 then i = h1(0) else i = xr(binx-1)-1
  if h1(0) ne -1 then j = h1(0) else j = yr(biny-1)-1
  if ang1 eq 0. then begin
    if ang2 ge 90. then img(i:*,j:*) = 1
    if ang2 ge 180. then img(0:i-1,j:*) = 1
    if ang2 eq 270. then img(0:i-1,0:j-1) = 1
  endif
  if ang1 eq 90. then begin
    if ang2 ge 180. then img(0:i-1,j:*) = 1
    if ang2 ge 270. then img(0:i-1,0:j-1) = 1
    if ang2 eq 360. then img(i:*,0:j-1) = 1
  endif
  if ang1 eq 180. then begin
    if ang2 eq 90. then ang2 = 450.
    if ang2 ge 270. then img(0:i-1,0:j-1) = 1
    if ang2 ge 360. then img(i:*,0:j-1) = 1
    if ang2 eq 450. then img(i:*,j:*) = 1
  endif
  if ang1 eq 270. then begin
    if ang2 lt ang1 then ang2 = 360. + ang2
    if ang2 ge 360. then img(i:*,0:j-1) = 1
    if ang2 ge 450. then img(i:*,j:*) = 1
    if ang2 ge 540. then img(0:i-1,j:*) = 1
  endif
  return,img
endif

theta = fltarr(binx,biny)
for i=0,binx-1 do begin
  xh = x(i)
  if xh ne x0 then begin
    tmp = atan(y-y0,xh-x0)*180./!pi
    h1 = where(tmp lt 0) & if h1(0) ne -1 then tmp(h1) = tmp(h1)+360.
    theta(i,*) = float(tmp(*))
  endif else begin
    h1 = where(y ge y0) & if h1(0) ne -1 then theta(i,h1) = 90.
    h1 = where(y lt y0) & if h1(0) ne -1 then theta(i,h1) = 270.
  endelse
endfor

icase = 0
if ang1 lt ang2 then icase = 1
if ang2 lt ang1 then icase = 2

if icase eq 1 then begin
  h1 = where(theta ge ang1 and theta le ang2)
  if h1(0) ne -1 then img(h1) = 1
endif

if icase eq 2 then begin
  h1 = where(theta ge ang2 and theta le ang1)
  if h1(0) ne -1 then img(h1) = 1
  tmp = 0*img + 1 & img = tmp - temporary(img)
endif

tmp = 0 & theta = 0

return,img
end
