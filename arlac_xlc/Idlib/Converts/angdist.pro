pro angdist,ang,arc,dist,angl=angl,arcl=arcl,r=r,adim=adim
;+
;procedure:	angdist
;		given 2 of [angle, arclength, distance] calculates the other
;
;parameters:	ang	opening angle
;		arc	length of arc subtending angle ANG
;		dist	distance to arc
;			ARC and DIST have the same dimensions
;
;keywords:	angl	if set, calculates ANG and exits
;		arcl	if set, calculates ARC and exits
;		r	if set, calculates DIST and exits
;		adim	dimension of ANG
;			0: radians, 1: degrees, 2: arcmin, 3: arcsec
;
;subroutines
;	RAD
;
;history
;	vinay kashyap (2/3/95)
;-

np = n_params(0)
if not (keyword_set(angl) or keyword_set(arcl) or keyword_set(r)) then np=0

if np lt 2 then begin
  print, 'Usages: angdist,ang,arc,dist,[/angl|/arcl|/r],adim=adim'
  print, '        angdist,arc,dist,/angl,adim=adim'
  print, '        angdist,ang,dist,/arcl,adim=adim'
  print, '        angdist,ang,arc,/r,adim=adim'
  print, '          adim:[0=radians,1=degrees,2=arcmin,3=arcsec]'
  print, '        given 2 of ang, arc, and r, obtains the last'
  return
endif

ADEG=0 & AMIN=0 & ASEC=0
if keyword_set(adim) then begin
  if adim eq 1 then ADEG=1
  if adim eq 2 then AMIN=1
  if adim eq 3 then ASEC=1
endif

if keyword_set(angl) then begin
  if np eq 2 then begin & ll=ang & rr=arc & th=0. & endif
  if np eq 3 then begin & ll=arc & rr=dist & endif
  if rr eq 0. then begin
    print, 'what, angles at zero distance?  i think not!' & return
  endif
  th = double(ll)/double(rr)
  if keyword_set(adim) then th = rad(th,deg=ADEG,min=AMIN,sec=ASEC,/inv)
  c1='Opening angle = '+strtrim(th,2)
  if ADEG then c1=c1+' [deg]'
  if AMIN then c1=c1+' [arcmin]'
  if ASEC then c1=c1+' [arcsec]'
  if np lt 3 then print, c1 else ang=th
endif

if keyword_set(arcl) then begin
  if np eq 2 then begin & th=ang & rr=arc & ll=0. & endif
  if np eq 3 then begin & th=ang & rr=dist & endif
  if keyword_set(adim) then th=rad(th,deg=ADEG,min=AMIN,sec=ASEC)
  ll = th*rr
  c1='Arc length = '+strtrim(ll,2)+' [same units as distance to arc]'
  if np lt 3 then print, c1 else arc=ll
endif

if keyword_set(r) then begin
  if np eq 2 then begin & th=ang & ll=arc & rr=0. & endif
  if np eq 3 then begin & th=ang & ll=arc & endif
  if keyword_set(adim) then th=rad(th,deg=ADEG,min=AMIN,sec=ASEC)
  if ll eq 0. then begin
    print, 'what, distance to zero distance?  i think not!' & return
  endif
  rr = double(th)/double(ll)
  c1='Distance to arc = '+strtrim(rr,2)+' [same units as length of arc]'
  if np lt 3 then print,c1 else dist=rr
endif

return
end
