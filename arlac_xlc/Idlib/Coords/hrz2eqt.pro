pro hrz2eqt,azm,altd,tim,latd,ra,dec,rad=rad
;+
;procedure	hrz2eqt
;	converts horizon coordinates (Altitude, Azimuth) to equatorial
;	coordinates (RA,Dec)
;
;parameters
;	azm	[INPUT; required] azimuth (output, in degrees)
;	altd	[INPUT; required] altitude (output, in degrees)
;	tim	[INPUT; required] local sidereal time (in hours)
;	latd	[OUTPUT; required] latitude of observation (same units as Dec)
;	ra	[OUTPUT] RA (in hours, unless specified otherwise)
;	dec	[OUTPUT] Dec (in degrees, unless specified otherwise)
;
;keywords
;	rad	[INPUT] if set, az and alt are taken to be in radians
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) lt 4 then begin
  print, 'Usage: hrz2eqt,azimuth,altitude,LSdT,latitude,RA,Dec,rad=rad'
  print, '  converts horizon coordinates to equatorial coordinates for'
  print, '  given latitude and given Local Sidereal Time'
  return
endif

az = azm & alt = altd & lat = latd*!pi/180.
if not keyword_set(rad) then begin
  az = az*!pi/180. & alt = alt*!pi/180.
endif

salt=sin(alt) & calt=cos(alt) & caz=cos(az) & saz=sin(az)
slat=sin(lat) & clat=cos(lat)

sdec = salt*slat + calt*clat*caz & cdec = sqrt(1.-sdec^2) & dec = asin(sdec)
cha = (salt - slat*sdec)/(clat*cdec)
if cha gt 1. then cha = 1. & if cha lt -1. then cha = -1.
ha = acos(cha)

dec = dec*180./!pi & ha = ha*180./!pi
if saz gt 0. then ha = 360.-ha

ha = ha/15. & ra = tim - ha
if ra lt 0. then ra = ra + 24. & if ra gt 24. then ra = ra - 24.

c1 = '(Azm,Alt) = ('+strcompress(azm)+','+strcompress(altd)+')'
c1 = '(Azm,Alt) = ('+strcompress(az)+','+strcompress(altd)+')'
c1 = c1 + '--> (RA,Dec) = ('+strcompress(ra)+','+strcompress(dec)+')'
if n_params(0) lt 6 then print, c1

return
end
