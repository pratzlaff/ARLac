pro gal2eqt,ll,bb,ra,dec,rad=rad
;+
;procedure	gal2eqt
;	converts galactic coordinates (l,b) to equatorial coordinates (RA,Dec)
;
;parameters
;	l	[INPUT; required] longitude (output, in degrees)
;	b	[INPUT; required] latitude (output, in degrees)
;	ra	[OUTPUT] RA (in hours, unless specified otherwise)
;	dec	[OUTPUT] Dec (in degrees, unless specified otherwise)
;
;keywords
;	rad	[INPUT] if set, l & b are taken to be in radians
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) lt 2 then begin
  print, 'Usage: gal2eqt,l,b,RA,Dec,rad=rad'
  print, '  converts galactic coordinates to equatorial coordinates'
  return
endif

ra0 = 192.25 & dec0 = 27.4 & l0 = 33.
ra0 = ra0*!pi/180. & dec0 = dec0*!pi/180. & l0 = l0*!pi/180.

l = ll & b = bb
if not keyword_set(rad) then begin
  l = l*!pi/180. & b = b*!pi/180.
endif

l = l - l0
cb = cos(b) & sb = sin(b) & cl = cos(l) & sl = sin(l)
cd0 = cos(dec0) & sd0 = sin(dec0)

sdec = cb*cd0*sl + sb*sd0 & y = cb*cl & x = sb*cd0 - cb*sd0*sl
arctan,y,x,ra,/radian & ra = ra + ra0

dec = asin(sdec)*180./!pi & ra = ra*180./!pi
if ra gt 360. then ra=ra-360. & if ra lt 0. then ra=ra+360. & ra=ra/15.

c1 = '(l,b) = ('+strcompress(ll)+','+strcompress(bb)+')'
c1 = c1 + '--> (RA,Dec) = ('+strcompress(ra)+','+strcompress(dec)+')'
if n_params(0) lt 4 then print, c1

return
end
