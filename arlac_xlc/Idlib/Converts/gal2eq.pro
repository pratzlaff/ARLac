pro gal2eq,l2,b2,RA,Dec,hours=hours,epoch=epoch, _extra=e
;+
;procedure	gal2eq
;		convert galactic to equatorial coordinates
;
;parameters
;	l2	[INPUT; required] Galactic longitude in degrees
;	b2	[INPUT; required] Galactic latitude in degrees
;	RA	[OUTPUT] Right Ascension (epoch 2000) in degrees
;	Dec	[OUTPUT] Declination (epoch 2000) in degrees
;
;keywords
;	hours	[INPUT] if set, RA will be returned in hours
;	epoch	[INPUT] epoch of output (RA,DEC)
;		* NOT IMPLEMENTED!
;		* currently set to 2000.0
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap (1999Feb; based on eq_gal.c of XEPHEM)
;	corrected initialization values (VK; Dec'02)
;-

;	usage
np=n_params() & nl2=n_elements(l2) & nb2=n_elements(b2) & ok='ok'
if np lt 2 then ok='' else $
 if nl2 eq 0 then ok='l2 not defined' else $
  if nb2 eq 0 then ok='b2 not defined' else $
   if nl2 ne nb2 then ok='l2 and b2 array sizes do not match'
if ok ne 'ok' then begin
  print,'Usage: gal2eq,l2,b2,RA,Dec,hours=hours,epoch=epoch'
  print,'  convert galactic to equatorial coordinates'
  if np gt 0 then message,ok,/info
  return
endif

;	inputs
xl2=l2 & xb2=b2

;	initialize
;an=33.0D*!DtoR		;Galactic longitude of ascending node on equator
an=32.93192D*!DtoR	;Galactic longitude of ascending node on equator
;gpr=192.255D*!DtoR	;RA_2000 of North Galactic Pole
gpr=192.85948D*!DtoR	;RA_2000 of North Galactic Pole
;gpd=27.40D*!DtoR	;Dec_2000 of NGP
gpd=27.12825D*!DtoR	;Dec_2000 of NGP
small=1d-20		;a "small" number

;	keywords
if keyword_set(epoch) then message,'EPOCH not implemented, using 2000.0',/info

;	convert inputs to radians
x=xl2*!DtoR & y=xb2*!DtoR

;	the following part simply translated from EQ_GAL.C
cy=cos(y) & sy=sin(y)
a=x-an			;a=x-gpr for the reverse transformation
ca=cos(a) & sa=sin(a)
b=sa			;b=ca for the reverse transformation
cgpd=cos(gpd) & sgpd=sin(gpd)
sq=(cy*cgpd*b)+(sy*sgpd) & q=asin(sq)
;
c=cy*ca
d=(sy*cgpd)-(cy*sgpd*sa)
oo=where(abs(d) lt small,moo) & if moo gt 0 then d(oo)=small
p=atan(c,d)+gpr
;
;	the following 3 lines appear to be unnecessary in IDL
;oo=where(d lt 0,moo) & if moo gt 0 then p(oo)=p(oo)+!pi
;oo=where(p lt 0,moo) & if moo gt 0 then p(oo)=p(oo)+2*!pi
;oo=where(p gt 2*!pi,moo) & if moo gt 0 then p(oo)=p(oo)-2*!pi

;	output
RA=p*180./!pi		;[degrees]
if keyword_set(hours) then RA=RA/15.	;[deg]->[hours]
Dec=q*180./!pi		;[degrees]
if np lt 4 then for i=0L,nl2-1L do print,$
	'(RA,Dec) = ('+string(RA(i),'(f7.2)')+','+string(Dec(i),'(f7.2)')+')'

return
end
