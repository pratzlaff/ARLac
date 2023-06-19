function pds_gtime,hour,minute,sec,day=day,mon=mon,year=year,$
	getut=getut,getst=getst,gtm=gtm, _extra=e
;+
;function	pds_gtime
;	converts Universal Time (UT) into Greenwich Mean Sidereal Time (GMST)
;	on the specified day, and vice versa.  the output is returned as a
;	structure with fields {HOUR,MINUTE,SEC}
;
;syntax
;	.run pds_gtime
;	gmst=pds_gtime(hour,minute,sec,day=day,mon=mon,year=year,/getst,gtm=gtm)
;	ut=pds_gtime(hour,minute,sec,day=day,mon=mon,year=year,/getut,gtm=gtm)
;
;parameters
;	hour	[INPUT; required] hour of day
;	minute	[INPUT; required] minute of hour
;	sec	[INPUT; required] second of minute
;		* if the array sizes match, output will be of same size
;		* if array sizes don't match, calculations will be performed
;		  for all possible combinations of {HOUR x MINUTE x SEC}
;
;keywords
;	day	[INPUT] day of month (default: today)
;	mon	[INPUT] month of year (default: this month)
;	year	[INPUT] year in common usage (default: this year)
;		* BC is represented as -ve numbers and there is no year zero
;		  BC .. -3, -2, -1, 1, 2, 3 .. AD
;		* prior to 1582 Oct 15, the Julian calendar is assumed, i.e.,
;		  1582 Oct 15 is preceded by 1582 Oct 4
;		* {DAY,MON,YEAR} shouldn't be vectors -- if they are, only
;		  the first element is used
;	getut	[INPUT; default=1] if set, converts from GMST to UT
;	getst	[INPUT; default=0] if set, converts from UT to GMST
;		* GSTST overrides GETUT
;	gtm	[OUTPUT] UT or GMST in decimal hours
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;	* UT equiv GMT, the time reckoned wrt the 'mean Sun' at
;	  Greenwich (365.25 days/yr)
;	* GMST is the time reckoned wrt the 'fixed heavens' at
;	  Greenwich (366.25 days/yr)
;	* the position of the mean Sun coincides with the true
;	  Sun each year at vernal equinox
;	* the sidereal day is shorter than the solar day by ~4 minute
;	* UT0 is actually determined from the diurnal motion of stars,
;	  and becomes UT1 after correction for longitude
;	* both UT and ST are affected by slight irregularities in
;	  the rotation of the Earth, so for precise timekeeping,
;	  use International Atomic Time (TAI)
;	* Coordinated Universal Time (UTC) differs from TAI by
;	  an integral number of seconds, and is maintained within
;	  0.9 of UT1 by introducing occassional leap seconds.
;	* note that occassionaly the same GMST times occur twice
;	  within a single UT day, and this is handled correctly
;	  only in the period before midnight, not in the period
;	  after midnight, when the ambiguity must be resolved by
;	  other means
;
;subroutines
;	PDS_CALDAY()
;	PDS_MINSEC()
;	PDS_JULDAY()
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1300
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params()
nhour=n_elements(hour) & nmin=n_elements(minute) & nsec=n_elements(sec)
nday=n_elements(day) & nmon=n_elements(mon) & nyear=n_elements(year)
if np lt 3 then ok='Insufficient parameters' else $
 if nhour eq 0 then ok='HOUR is undefined' else $
  if nmin eq 0 then ok='MINUTE is undefined' else $
   if nsec eq 0 then ok='SEC is undefined'
if ok ne 'ok' then begin
  print,'Usage: ut=pds_gtime(hour,minute,sec,day=day,mon=mon,year=year,/getut,gtm=gtm)'
  print,'       st=pds_gtime(hour,minute,sec,day=day,mon=mon,year=year,/getst,gtm=gtm)'
  print,'  converts mean Solar time (UT) to Sidereal time (GMST)'
  print,'  and vice versa'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	define outputs
nout=nhour & zhr=intarr(nhour) & zmm=intarr(nmin) & zss=intarr(nsec)
if nhour ne nmin or nhour ne nsec then begin
  nout=nhour*nmin*nsec
  zhr=intarr(nhour,nmin,nsec)
  zmm=intarr(nhour,nmin,nsec)
  zss=fltarr(nhour,nmin,nsec)
endif

;	inputs
tim=pds_minsec(hour,minute,sec)
dmy=pds_calday(systime(/julian),/julday)
if keyword_set(day) then xdy=day[0] else xdy=dmy.DAY
if keyword_set(mon) then xmn=mon[0] else xmn=dmy.MON
if keyword_set(year) then xyr=year[0] else xyr=dmy.YEAR
xdjd=pds_julday(xdy,xmn,xyr)
xdjd2=pds_julday(0*xdy,0*xmn+1,xyr)
tt=xdjd2/36525.
rr = 6.6460656D + (5.1262d-2 + (tt*2.581d-5))*tt
r1 = 2400.*(tt-((xyr-1900.)/100.))
bb = 24. - rr - r1
t0 = ((xdjd-xdjd2)*6.57098d-2) - bb

if keyword_set(getst) then begin
  gtm = (tim*1.002737908D) + t0
  gtm = (gtm+24) mod 24
  st=pds_minsec(gtm)
  return,st
endif else begin
  t0 = (t0+24) mod 24
  gtm = tim - t0
  gtm = (gtm+24) mod 24
  gtm = gtm * 0.9972695677D
  ut=pds_minsec(gtm)
  return,ut
endelse

end

;	handling program for PDS_GTIME
jnk=pds_gtime()
print,'' & print,''
ans='Greenwich time conversion? [N/Y] ' & read,prompt=ans,ans & c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

while go_on do begin
  ans='... from UT to GMST [Y/N] > ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 eq '' or strmid(strupcase(c1),0,1) eq 'Y' then begin
    read,prompt='	Date (D,M,Y) > ',dy,mn,yr
    read,prompt='	and time (H,M,S) > ',xd,xm,xs
    st=pds_gtime(xd,xm,xs,day=dy,mon=mn,year=yr,/getst)
    print,'	GST: ',strtrim(st.D,2)+':'+strtrim(st.M,2)+':'+strtrim(st.S,2)
  endif else begin
    read,prompt='	Date (D,M,Y) > ',dy,mn,yr
    read,prompt='	and time (H,M,S) > ',xd,xm,xs
    ut=pds_gtime(xd,xm,xs,day=dy,mon=mn,year=yr,/getut)
    print,'	GMT: ',strtrim(ut.D,2)+':'+strtrim(ut.M,2)+':'+strtrim(ut.S,2)
  endelse
  ;
  ans='Again? [Y/N] ' & read,prompt=ans,ans
  c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0
endwhile

end
