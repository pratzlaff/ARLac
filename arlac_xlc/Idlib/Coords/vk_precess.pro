pro precess,ra1,dec1,jd1,jd2,ra2,dec2,deg=deg,rad=rad
;+
;procedure	precess
;	precess equatorial coordinates from jd1 to jd2
;
;parameters
;	ra1	[INPUT; required] RA at jd1 (in decimal hours)
;	dec1	[INPUT; required] Dec at jd1 (in decimal degrees)
;	jd1	[INPUT; required] Julian day of input
;	jd2	[INPUT; required] Julian day of output
;	ra2	[OUTPUT] RA at jd2 (output in same units as ra1)
;	dec2	[OUTPUT] Dec at jd2 (output in same units as dec2)
;
;keywords
;	deg	[INPUT] if set, BOTH RA and Dec are taken to be in degrees
;	rad	[INPUT] if set, BOTH RA and Dec are taken to be in radians
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) lt 4 then begin
  print, 'Usage: precess,ra1,dec1,jd1,jd2,ra2,dec2[,/[deg|rad]]'
  print, '  precesses (ra1,dec1) on Julian day 1 to (ra2,dec2) on Julian day 2'
  return
endif

if not keyword_set(rad) then begin
  if not keyword_set(deg) then ra = ra1*15.
  ra = ra1*!pi/180. & dec = dec1*!pi/180.
endif

p = dblarr(3,3) & v = dblarr(3) & s = v & w = v

t = (jd1-2451545.D)/36525.D
x = 0.6406161*t + 0.0000839*t^2 + 0.0000050*t^3 & x = x*!pi/180.
y = 0.6406161*t + 0.0003041*t^2 + 0.0000051*t^3 & y = y*!pi/180.
z = 0.5567530*t - 0.0001185*t^2 - 0.0000116*t^3 & z = z*!pi/180.

cx=cos(x) & sx=sin(x) & cy=cos(y) & sy=sin(y) & cz=cos(z) & sz=sin(z)
cra = cos(ra) & cdec = cos(dec) & sra = sin(ra) & sdec = sin(dec)

p(0,0)=cx*cy*cz-sx*sy & p(0,1)=cx*sy*cz+sx*cy & p(0,2)=cx*sz
p(1,0)=-sx*cy*cz-cx*sy & p(1,1)=-sx*sy*cz+cx*cy & p(1,2)=-sx*sz
p(2,0)=-sz*cy & p(2,1)=-sz*sy & p(2,2)=cz
v(0)=cra*cdec & v(1)=sra*cdec & v(2)=sdec
for i=0,2 do s(i)=total(p(i,*)*v(*))

t = (jd2-2451545.D)/36525.D
x = 0.6406161*t + 0.0000839*t^2 + 0.0000050*t^3 & x = x*!pi/180.
y = 0.6406161*t + 0.0003041*t^2 + 0.0000051*t^3 & y = y*!pi/180.
z = 0.5567530*t - 0.0001185*t^2 - 0.0000116*t^3 & z = z*!pi/180.

cx=cos(x) & sx=sin(x) & cy=cos(y) & sy=sin(y) & cz=cos(z) & sz=sin(z)

p(0,0)=cx*cy*cz-sx*sy & p(1,0)=cx*sy*cz+sx*cy & p(2,0)=cx*sz
p(0,1)=-sx*cy*cz-cx*sy & p(1,1)=-sx*sy*cz+cx*cy & p(2,1)=-sx*sz
p(0,2)=-sz*cy & p(1,2)=-sz*sy & p(2,2)=cz
for i=0,2 do w(i) = total(p(i,*)*s(*))

arctan,w(1),w(0),ra2,/radian & dec2 = asin(w(2))

if not keyword_set(rad) then begin
  ra2 = ra2*180./!pi & dec2 = dec2*180./!pi
  if not keyword_set(deg) then ra2 = ra2/15.
endif

jday2mdy,jd1,m,d,y & epoch1=float(y) & jday2mdy,jd2,m,d,y & epoch2=float(y)
c1 = '(RA,Dec)_'+strtrim(epoch1,2)+' : ('+strcompress(ra1)+','
c1 = c1 + strcompress(dec1)+')' + ' (RA,Dec)_'+strtrim(epoch2,2)+' : ('
c1 = c1 + strcompress(ra2)+','+strcompress(dec2)+')'
if n_params(0) lt 6 then print, c1

return
end
