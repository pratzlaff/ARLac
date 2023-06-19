function pds_obliq,dd,mm,yy,jday=jday,$
	_extra=e
;+
;procedure	pds_obliq
;	calculates the obliquity of the ecliptic in [degrees]
;	for a given calendar date
;
;syntax
;	.run pds_obliq
;	eps=pds_obliq(dd,mm,yy,jday=jday,epsr=epsr)
;
;parameters
;	dd	[INPUT; required] day of month
;	mm	[INPUT; required] month of year
;	yy	[INPUT; required] year in common usage
;		* DD,MM,YY are passed directly to PDS_JULDAY()
;
;keywords
;	jday	[OUTPUT] julian day number
;	epsr	[OUTPUT] obliquity in radians
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;
;subroutines
;	PDS_JULDAY()
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1700
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params() & nd=n_elements(dd) & nm=n_elements(mm) & ny=n_elements(yy)
if np lt 3 then ok='Insufficient parameters' else $
 if nd eq 0 then ok='DD is undefined' else $
  if nm eq 0 then ok='MM is undefined' else $
   if ny eq 0 then ok='YY is undefined'
if ok ne 'ok' then begin
  print,'Usage: obliq_degree=pds_obliq(day,month,year,jday=jday,epsr=epsr)'
  print,'  calculates the obliquity of the ecliptic'
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

;	handling program for PDS_OBLIQ
jnk=pds_obliq()
print,'' & print,''
ans='calculate obliquity of the ecliptic? [N/Y] ' & read,prompt=ans,ans & c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

while go_on do begin
  read,prompt='Date [D,M,Y] > ',dy,mon,yr
  obl=pds_obliq(dy,mon,yr,jday=jday,epsr=epsr)
  dms=pds_minsec(obl)
  print,'	The mean obliquity [D,M,S] = '+strtrim(dms.D,2)+':'+strtrim(dms.M,2)+':'+strtrim(dms.S,2)

  ans='Again? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0
endwhile

end
