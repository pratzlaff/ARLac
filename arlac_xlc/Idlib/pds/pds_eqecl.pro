function pds_eqecl,xx,yy,day=day,mon=mon,year=year,nutat=nutat,$
	GetEQ=GetEQ,GetECL=GetECL, _extra=e
;+
;procedure	pds_eqecl
;	converts geocentric ecliptic latitude and longitude into equatorial
;	RA,Dec and vice versa for a specified day.  the output is returned
;	in a structure of the form {RA,DEC} or {LAT,LON}
;
;syntax
;	.run pds_eqecl
;	eqstr=pds_eqecl(lat,lon,day=day,mon=mon,year=year,nutat=nutat,/GetEQ)
;	eclstr=pds_eqecl(RA,Dec,day=day,mon=mon,year=year,nutat=nutat,/GetECL)
;
;parameters
;	xx	[INPUT; required] ecliptic longitude XOR right ascension
;		in [degrees]
;		* assumed to be RA if GetECL is set
;	yy	[INPUT; required] ecliptic latitude XOR declination in [degrees]
;		* assumed to be Dec if GetECL is set
;
;keywords
;	day	[INPUT] day of the month
;	mon	[INPUT] month of the year
;	year	[INPUT] year of the epoch
;		* if not given, DAY,MON,YEAR are set to current day
;	nutat	[INPUT] nutation correction to the obliquity
;	GetEQ	[INPUT; default=1] if set, converts from ecliptic lat,lon
;		to equatorial RA,Dec
;	GetECL	[INPUT; default=0] if set, converts from equatorial RA,Dec
;		ecliptic lat,lon
;		* GetECL overrides GetEQ
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;
;subroutines
	PDS_NUTAT
	PDS_OBLIQ
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1800
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params() & nx=n_elements(xx) & ny=n_elements(yy)
xname='LON' & if keyword_set(GetECL) then xname='RA'
yname='LAT' & if keyword_set(GetECL) then yname='DEC'
mx=n_tags(xx) & my=n_tags(yy)
if np lt 3 then ok='Insufficient parameters' else $
 if nx eq 0 then ok=xname+' is undefined' else $
  if ny eq 0 then ok=yname+' is undefined' else $
   if mx gt 0 then ok=xname+' is a structure; use pds_minsec()' else $
    if my gt 0 then ok=yname+' is a structure; use pds_minsec()'
if ok ne 'ok' then begin
  print,'Usage: eqstr=pds_eqecl(lon,lat,/GetEQ)'
  print,'       eclstr=pds_eqecl(RA,DEC,/GetECL)'
  print,'  converts ecliptic longitude,latitude to equatorial RA,Dec
  if np ne 0 then message,ok,/informational
  return,-1L
endif

djd=pds_julday(dd,mm,yy,jday=jday)
tt=djd/36525.
cc=( ( (-1.81d-3 * tt) + 5.9d-3 ) * tt + 46.845D ) * tt
eps = 23.45229444D - (cc/3600.)
epsr = eps * 1.745329252d-2

return,eps

end

;	handling program for PDS_EQECL
jnk=pds_eqecl()
print,'' & print,''
ans='calculate obliquity of the ecliptic? [N/Y] ' & read,prompt=ans,ans & c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

while go_on do begin
  read,prompt='Date [D,M,Y] > ',dy,mon,yr
  obl=pds_eqecl(dy,mon,yr,jday=jday,epsr=epsr)
  dms=pds_minsec(obl)
  print,'	The mean obliquity [D,M,S] = '+strtrim(dms.D,2)+':'+strtrim(dms.M,2)+':'+strtrim(dms.S,2)

  ans='Again? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0
endwhile

end
