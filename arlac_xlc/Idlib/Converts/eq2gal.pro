pro eq2gal,RA,Dec,l2,b2,hours=hours,epoch=epoch, _extra=e
;+
;procedure	eq2gal
;		convert equatorial to galactic coordinates
;
;parameters
;	RA	[INPUT; required] Right Ascension (epoch 2000) in degrees
;	Dec	[INPUT; required] Declination (epoch 2000) in degrees
;	l2	[OUTPUT] Galactic longitude in degrees
;	b2	[OUTPUT] Galactic latitude in degrees
;
;keywords
;	hours	[INPUT] if set, RA is assumed to be in hours
;	epoch	[INPUT] epoch of input (RA,DEC)
;		* NOT IMPLEMENTED!
;		* currently assumed to be 2000.0
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap (1999Feb; based on eq_gal.c of XEPHEM)
;-

;	usage
np=n_params() & nRA=n_elements(RA) & nDec=n_elements(Dec) & ok='ok'
if np lt 2 then ok='' else $
 if nRA eq 0 then ok='RA not defined' else $
  if nDec eq 0 then ok='Dec not defined' else $
   if nRA ne nDec then ok='RA and Dec array sizes do not match'
if ok ne 'ok' then begin
  message,ok,/info
  print,'Usage: eq2gal,RA,Dec,l2,b2,hours=hours,epoch=epoch'
  print,'  convert equatorial to galactic coordinates'
  return
endif

;	inputs
xRA=RA & xDec=Dec

;	initialize
an=33.0D*!DtoR		;Galactic longitude of ascending node on equator
gpr=192.255D*!DtoR	;RA_2000 of North Galactic Pole
gpd=27.40D*!DtoR	;Dec_2000 of NGP
small=1d-20		;a "small" number

;	keywords
if keyword_set(hours) then xRA=xRA*15.	;[hours]->[deg]
if keyword_set(epoch) then message,'EPOCH not implemented, using 2000.0',/info

;	convert inputs to radians
x=xRA*!DtoR & y=xDec*!DtoR

;	the following part simply translated from EQ_GAL.C
cy=cos(y) & sy=sin(y)
a=x-gpr			;a=x-an for the reverse transformation
ca=cos(a) & sa=sin(a)
b=ca			;b=sa for the reverse transformation
cgpd=cos(gpd) & sgpd=sin(gpd)
sq=(cy*cgpd*b)+(sy*sgpd) & q=asin(sq)
;
c=sy-(sq*sgpd)
d=cy*sa*cgpd
oo=where(abs(d) lt small,moo) & if moo gt 0 then d(oo)=small
p=atan(c,d)+an
;
;	the following 3 lines appear to be unnecessary in IDL
;oo=where(d lt 0,moo) & if moo gt 0 then p(oo)=p(oo)+!pi
oo=where(p lt 0,moo) & if moo gt 0 then p(oo)=p(oo)+2*!pi
oo=where(p gt 2*!pi,moo) & if moo gt 0 then p(oo)=p(oo)-2*!pi

;	output
l2=p*180./!pi		;[degrees]
b2=q*180./!pi		;[degrees]
if np lt 4 then for i=0L,nRA-1L do print,$
	'(l_II,b_II) = ('+string(l2(i),'(f7.2)')+','+string(b2(i),'(f7.2)')+')'

return
end
