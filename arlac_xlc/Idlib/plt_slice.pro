pro plt_slice,x,y,z,binz=binz,zmin=zmin,nz=nz, _extra=e
;+
;procedure 	plt_slice
;	plots Y(X) for various slices of Z
;
;parameters
;	X	[INPUT; required] list of X-values
;	Y	[INPUT; required] list of Y-values
;	Z	[INPUT; required] list of Z-values
;
;keywords
;	nz	[INPUT; default=10] number of bins to group Z into
;	zmin	[INPUT; default=min(Z)] start Z-binning from this value
;	binz	[INPUT; default=(max(Z)-ZMIN)/NZ] width of each Z bin
;
;	_extra	[INPUT] use to specify keywords to SURFACE
;
;side-effects
;	plots to graphics window
;
;history
;	vinay kashyap (Feb98)
;-

;	usage
mx=n_elements(x) & my=n_elements(y) & mz=n_elements(z)
if mx eq 0 or my eq 0 or mz eq 0 then begin
  print,'Usage: plt_slice,x,y,z,binz=binz,zmin=zmin,nz=nz'
  print,'  plot Y(X) for various slices in Z'
  return
endif

;	input consistency check
ok='ok'
if mx eq 1 then ok='cannot plot one element!' else $
  if my ne mx then ok='Y does not match X' else $
    if mz ne my then ok='Z does not match Y'
if ok ne 'ok' then begin message,ok,/info & return & endif

;	define keywords
if not keyword_set(nz) then iz=10 else iz=long(nz)>1
if not keyword_set(zmin) then minz=min(Z) else minz=zmin & maxz=max(Z)
if not keyword_set(binz) then zbin=abs((maxz-minz)/iz) else zbin=binz

;	set up plot
;	NOTE: for purposes of SURFACE, X-->X, Y-->Z, and Z-->Y
minx=min(X,max=maxx) & miny=min(Y,max=maxy)
xr=[minx,maxx] & yr=[miny,maxy] & zr=[minz,maxz]
surface,fltarr(2,2),/nodata,xrange=xr,yrange=zr,zrange=yr,/save, _extra=e

;	draw the 2D plots
for i=0,iz-1 do begin
  z0=minz+i*zbin & z1=z0+zbin
  oo=where(Z ge z0 and Z lt z1,moo)
  if moo eq 1 then plots,[minx,x(oo),x(oo),x(oo),maxx],$
	0.5*(z0+z1)+fltarr(5), [miny,miny,y(oo),miny,miny], /t3d
  if moo gt 1 then begin
    xx=X(oo) & yy=Y(oo) & zz=fltarr(moo)+0.5*(z0+z1)
    ox=sort(xx) & xx=xx(ox) & yy=yy(ox)
    xx=[minx,xx(0),xx,xx(moo-1),maxx]
    yy=[miny,miny,yy,miny,miny] & zz=[zz(0),zz(0),zz,zz(0),zz(0)]
    plots,xx,zz,yy,/t3d
  endif
endfor

end
