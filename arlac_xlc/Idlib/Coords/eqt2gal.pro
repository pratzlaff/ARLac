pro eqt2gal,rghta,decl,l,b,rad=rad
;+
;procedure	eqt2gal
;	converts equatorial coordinates (RA,Dec) to galactic coordinates (l,b)
;
;parameters
;	rghta	[INPUT; required] RA (in hours, unless specified otherwise)
;	decl	[INPUT; required] Dec (in degrees, unless specified otherwise)
;	l	[OUTPUT] longitude (output, in degrees)
;	b	[OUTPUT] latitude (output, in degrees)
;
;keywords
;	rad	[INPUT] if set, RA & Dec are taken to be in radians
;
;history
;	vinay kashyap (1994)
;	changed the call from arctan to atan (Mar2008)
;-

if n_params(0) lt 2 then begin
  print, 'Usage: eqt2gal,RA,Dec,l,b,rad=rad'
  print, '  converts equatorial coordinates to galactic coordinates'
  return
endif

ra0 = 192.25 & dec0 = 27.4 & l0 = 33.
ra0 = ra0*!pi/180. & dec0 = dec0*!pi/180. & l0 = l0*!pi/180.

ra = rghta & dec = decl
if not keyword_set(rad) then begin
  dec = dec*!pi/180. & ra = ra*15.*!pi/180.
endif

ra = ra - ra0
cdec = cos(dec) & cra = cos(ra) & sdec = sin(dec) & sra = sin(ra)
cd0 = cos(dec0) & sd0 = sin(dec0)

sb = cdec*cd0*cra + sdec*sd0 & y = sdec - sb*sd0 & x = cdec*sra*cd0
;arctan,y,x,l,/radian & l = l + l0
if keyword_set(radian) then l=atan(y,x) else l=atan(y*!pi/180.,x*!pi/180.)
l = l + l0

b = asin(sb)*180./!pi & l = l*180./!pi
if l ge 360. then l = l - 360. & if l lt 0. then l = l + 360.

c1 = '(RA,Dec) = ('+strcompress(rghta)+','+strcompress(decl)+')'
c1 = c1 + '--> (l,b) = ('+strcompress(l)+','+strcompress(b)+')'
if n_params(0) lt 4 then print, c1

return
end
