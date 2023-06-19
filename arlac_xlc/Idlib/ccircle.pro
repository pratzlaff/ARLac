function ccircle,xc,yc,rad,xrange=xrange,yrange=yrange,nx=nx,ny=ny,norm=norm,$
		small=small,rand=rand, _extra=e
;+
;function	ccircle
;		returns a bit image of a circle
;
;parameters	xc	x-coordinate of center
;		yc	y-coordinate of center
;		rad	radius of circle
;
;keywords	xrange	range in x-values (def:[1,512])
;		yrange	range of y-values (def:[1,512])
;		nx	number of elements in x (def: 512)
;		ny	number of elements in y (def: 512)
;		norm	normalization factor
;		small	stores image of smaller size
;		rand	resorts to monte carlo tricks to speed things up.
;		_extra	[JUNK] here to avoid crashing the program
;
;history	modified from imgcreate.pro by VK	{8/12/93}
;		added keyword _EXTRA (VK; Apr99)
;-

;check for correct parameters
np = n_params(0) & img = bytarr(2,2)
if np eq 0 then begin
  print, 'Usage: img = ccircle(xc,yc,rad,xrange=[xmin,xmax],yrange=[ymin,ymax],'
  print, '  nx=nx,ny=ny,norm=norm,small=small,/rand)'
  print, '  returns bit image of a circle' & return,img
endif
if np eq 1 then begin & yc = xc & rad = 10. & endif
if np eq 2 then begin & rad = abs(yc) & yc = xc & endif

;initialize keywords
xr = [1.,512.] & yr = xr & binx = 512L & biny = 512L
if keyword_set(xrange) then begin
  sz = size(xrange) & if sz(0) eq 1 then xr = float(xrange)
endif
if keyword_set(yrange) then begin
  sz = size(yrange) & if sz(0) eq 1 then yr = float(yrange)
endif
if keyword_set(nx) then binx = nx & if keyword_set(ny) then biny = ny

;set up the grid
xstp = (xr(1)-xr(0))/float(binx-1) & ystp = (yr(1)-yr(0))/float(biny-1)
x = findgen(binx)*xstp+xr(0) & y = findgen(biny)*ystp+yr(0)

img = bytarr(binx,biny)

;set up the corners
x0 = xc-rad-xstp & x1 = xc+rad+xstp & y0 = yc-rad-ystp & y1 = yc+rad+ystp
x0 = x0 < xr(1) & x0 = x0 > xr(0) & x1 = x1 < xr(1) & x1 = x1 > xr(0)
y0 = y0 < yr(1) & y0 = y0 > yr(0) & y1 = y1 < yr(1) & y1 = y1 > yr(0)

;find the corner indices
i0 = 0 & h1 = where(x lt x0) & if h1(0) ne -1 then i0 = max(h1)
j0 = 0 & h1 = where(y lt y0) & if h1(0) ne -1 then j0 = max(h1)
i1 = binx-1 & h1 = where(x gt x1) & if h1(0) ne -1 then i1 = h1(0)
j1 = biny-1 & h1 = where(y gt y1) & if h1(0) ne -1 then j1 = h1(0)

;set up random scatter of points if circle is small
di = i1-i0+1 & dj = j1-j0+1 & npt = di*dj
if keyword_set(rand) then begin
  npt = npt*10
  xpt = (x(i1)-x(i0)+1.)*randomu(seed,npt) + x(i0)-0.5
  ypt = (y(j1)-y(j0)+1.)*randomu(seed,npt) + y(j0)-0.5
  rpt = (xpt-xc)^2+(ypt-yc)^2 & h1 = where(rpt le rad^2)
  ix = fix(xpt+0.5) & iy = fix(ypt+0.5)
  if h1(0) ne -1 then begin
    for i=0,n_elements(h1)-1 do begin
      img(ix(h1(i)),iy(h1(i))) = img(ix(h1(i)),iy(h1(i))) + 1
    endfor
  endif
endif else begin
  for i=i0,i1,1 do begin
    z = lindgen(j1-j0+1)+j0
    tmp = (x(i)-xc)^2 + (y(j0:j1)-yc)^2 & h1 = where(tmp le rad^2)
    if h1(0) ne -1 then img(i,z(h1)) = 1
  endfor
endelse

c1 = 'CIRCLE('+strtrim(xc,2)+','+strtrim(yc,2)+','+strtrim(rad,2)+')'
if !quiet gt 1 then print, c1

norm = max(img) & if norm eq 0 then norm = 1
small = img(i0:i1,j0:j1)

return,img
end
