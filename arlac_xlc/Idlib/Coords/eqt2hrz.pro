pro eqt2hrz,rghta,decl,tim,latd,az,alt,rad=rad
;+
;procedure	eqt2hrz
;	converts equatorial coordinates (RA,Dec) to horizon coordinates
;	(Altitude, Azimuth)
;
;parameters
;	rghta	[INPUT; required] RA (in hours, unless specified otherwise)
;	decl	[INPUT; required] Dec (in degrees, unless specified otherwise)
;	tim	[INPUT; required] local sidereal time (in hours)
;	latd	[OUTPUT; required] latitude of observation (same units as Dec)
;	az	[OUTPUT] azimuth (output, in degrees)
;	alt	[OUTPUT] altitude (output, in degrees)
;
;keywords
;	rad	[INPUT] if set, RA & Dec are taken to be in radians
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) le 4 then begin
  print, 'Usage: eqt2hrz,RA,Dec,LSdT,latitude,azimuth,altitude,rad=rad'
  print, '  converts equatorial coordinates to horizon coordinates for'
  print, '  given latitude at given Local Sidereal Time'
  return
endif

ra = rghta & dec = decl & lat = latd*!pi/180.
if not keyword_set(rad) then dec = dec*!pi/180. else ra = ra*180./(!pi*15.)

ha = tim - ra & ha = ha*15.*!pi/180.

sdec=sin(dec) & slat=sin(lat) & cdec=cos(dec) & clat=cos(lat)
cha = cos(ha) & sha = sin(ha)

salt = sdec*slat + cdec*clat*cha & calt = sqrt(1.-salt^2)
caz = (sdec - slat*salt)/(clat*calt)

alt = asin(salt)*180./!pi & az = acos(caz)*180./!pi

if sha gt 0. then az = 360.-az

c1 = '(RA,Dec) = ('+strcompress(rghta)+','+strcompress(decl)+')'
c1 = c1 + '--> (Alt,Azm) = ('+strcompress(alt)+','+strcompress(az)+')'
if n_params(0) lt 6 then print, c1

return
end
