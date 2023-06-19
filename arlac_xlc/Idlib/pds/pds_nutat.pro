function pds_nutat,dd,mm,yy,jday=jday,deps=deps,dpsi=dpsi,$
	verbose=verbose, _extra=e
;+
;procedure	pds_nutat
;	calculates the nutation in ecliptic longitude and in the
;	obliquity of the ecliptic for a given calendar date.  the
;	output is returned both as a structure {DEPS,DPSI} and
;	via keywords of the same name.
;
;syntax
;	.run pds_nutat
;	nut=pds_nutat(dd,mm,yy,jday=jday,deps=deps,dpsi=dpsi,verbose=vv)
;
;parameters
;	dd	[INPUT; required] day of month
;	mm	[INPUT; required] month of year
;	yy	[INPUT; required] year in common usage
;		* DD,MM,YY are passed directly to PDS_JULDAY()
;
;keywords
;	jday	[OUTPUT] julian day number
;	deps	[OUTPUT] effect of nutation on obliquity of the ecliptic
;	dpsi	[OUTPUT] effect of nutation on ecliptic longitude
;	verbose	[INPUT] controls chatter
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;
;subroutines
;	PDS_JULDAY()
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 2700
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params() & nd=n_elements(dd) & nm=n_elements(mm) & ny=n_elements(yy)
if np lt 3 then ok='Insufficient parameters' else $
 if nd eq 0 then ok='DD is undefined' else $
  if nm eq 0 then ok='MM is undefined' else $
   if ny eq 0 then ok='YY is undefined'
if ok ne 'ok' then begin
  print,'Usage: nutat_degree=pds_nutat(day,month,year,jday=jday,deps=deps,dpsi=dpsi)
  print,'  calculates the effect of nutation on the obliquity of the ecliptic (DEPS)'
  print,'  and on the ecliptic longitude (DPSI)'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

vv=0L & if keyword_set(verbose) then vv=long(verbose[0])>1

djd=pds_julday(dd,mm,yy,jday=jday)
tt=djd/36525.
tt2=tt*tt
if vv ge 1 then print,'djd,tt,tt2',djd,tt,tt2
aa=1.000021358d2 * tt & bb=360.*(aa-floor(aa))
ls=2.7969678d2 + 3.03d-4 * tt2 + bb & if vv ge 1 then print,'aa,bb,ls',aa,bb,ls
aa=1.336855231d3 * tt & bb=360.*(aa-floor(aa))
ld=2.704342d2 - 1.133d-3 * tt2 + bb & if vv ge 1 then print,'aa,bb,ld',aa,bb,ld
aa=9.999736056d1 * tt & bb=360.*(aa-floor(aa))
ms=3.584758d2 - 1.5d-4 * tt2 + bb & if vv ge 1 then print,'aa,bb,ms',aa,bb,ms
aa=1.325552359d3 * tt & bb=360.*(aa-floor(aa))
md=2.961046d2 + 9.192d-3 * tt2 + bb & if vv ge 1 then print,'aa,bb,md',aa,bb,md
aa=5.372616667d * tt & bb=360.*(aa-floor(aa))
nm=2.591833d2 + 2.078d-3 * tt2 + bb & if vv ge 1 then print,'aa,bb,nm',aa,bb,nm
tls=2.*(!dpi/180.D)*ls & nm=(!dpi/180.D)*nm
tnm=2.*(!dpi/180.D)*nm & ms=(!dpi/180.D)*ms
tld=2.*(!dpi/180.D)*ld & md=(!dpi/180.D)*md
if vv ge 1 then print,'ls,tls,nm,tnm,ms,ld,tld,md',ls,tls,nm,tnm,ms,ld,tld,md

dpsi = (-17.2327D - 1.737e-2 * tt)*sin(nm) +$
	(-1.2729d-1 - 1.3d-4 * tt)*sin(tls) +$
	2.088d-1 * sin(tnm) - 2.037d-1 * sin(tld) +$
	(1.261d-1 - 3.1d-4 * tt)*sin(ms) +$
	6.75d-2 * sin(md) -$
	(4.97d-2 - 1.2d-4 * tt)*sin(tls+ms) -$
	3.42d-2 * sin(tld-nm) - 2.61d-2 * sin(tld+md) +$
	2.14d-2 * sin(tls-ms) -$
	1.49d-2 * sin(tls-tld+md) +$
	1.24d-2 * sin(tls-nm) + 1.14d-2 * sin(tld-md)
if vv ge 1 then print,'dpsi=',dpsi

deps = (9.21D + 9.1d-4 * tt)*cos(nm) +$
	(5.522d-1 - 2.9d-4 * tt)*cos(tls) -$
	9.04d-2 * cos(tnm) + 8.84d-2 * cos(tld) +$
	2.16d-2 * cos(tls+ms) + 1.83d-2 * cos(tld-nm) +$
	1.13d-2 * cos(tld+md) - 9.3d-3 * cos(tls-ms) -$
	6.6d-3 * cos(tls-nm)
if vv ge 1 then print,'deps=',deps

dpsi = dpsi/3600.
deps = deps/3600.
nut = create_struct('DEPS',deps,'DPSI',dpsi)

if vv gt 1000 then stop,'HALTing; type .CON to continue'

return,nut

end

;	handling program for PDS_NUTAT
jnk=pds_nutat()
print,'' & print,''
ans='calculate nutation corrections? [N/Y] ' & read,prompt=ans,ans & c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

while go_on do begin
  read,prompt='Date [D,M,Y] > ',dy,mon,yr
  nut=pds_nutat(dy,mon,yr,jday=jday,epsr=epsr,verbose=1001)
  dms=pds_minsec(nut.DPSI)
  print,'	The nutation in longitude [D,M,S] = '+strtrim(dms.D,2)+':'+strtrim(dms.M,2)+':'+strtrim(dms.S,2)
  dms=pds_minsec(nut.DEPS)
  print,'	The nutation in obliquity [D,M,S] = '+strtrim(dms.D,2)+':'+strtrim(dms.M,2)+':'+strtrim(dms.S,2)

  ans='Again? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0
endwhile

end
