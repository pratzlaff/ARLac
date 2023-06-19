pro applypm,ra,dec,rapm,decpm,ora,odec,fepoch=fepoch,tepoch=tepoch,$
	verbose=verbose, _extra=e
;+
;procedure	applypm
;	apply proper motion to coordinates
;
;parameters [all required]
;	ra	[INPUT] RA as sexagesimal string at original epoch
;	dec	[INPUT] DEC as sexagesimal string at original epoch
;	rapm	[INPUT] proper motion in RA [mas/yr]
;	decpm	[INPUT] proper motion in Dec [mas/yr]
;	ora	[OUTPUT] RA at new epoch as sexagesimal string
;	odec	[OUTPUT] Dec at new epoch as sexagesimal string
;
;keywords
;	fepoch	[INPUT] epoch of original coordinates
;		* default: 2000.0
;	tepoch	[INPUT] epoch of new coordinates
;		* default: now
;	verbose	[INPUT] controls chatter
;	_extra	[JUNK] here only to prevent crashing the program
;
;subroutines
;	SKYPOS
;
;history
;	vinay kashyap (2007.2805)
;-

ok='ok' & np=n_params() & nra=n_elements(ra) & ndec=n_elements(dec)
nrp=n_elements(rapm) & ndp=n_elements(decpm)
if np lt 6 then ok='Insufficient parameters' else $
 if nra eq 0 then ok='RA is undefined' else $
  if ndec eq 0 then ok='DEC is undefined' else $
   if nrp eq 0 then ok='RA proper motion is undefined' else $
    if ndp eq 0 then ok='DEC proper motion is undefined' else $
     if nra ne ndec then ok='RA and DEC are incompatible' else $
      if nra ne nrp then ok='RA and RA proper motion are incompatible' else $
       if nra ne ndp then ok='RA and DEC proper motion are incompatible' else $
	if size(RA,/type) ne 7 then ok='RA must be a sexagesimal string' else $
	 if size(DEC,/type) ne 7 then ok='DEC must be a sexagesimal string' else $
	  if size(rapm,/type) gt 5 then ok='RA proper motion must be a number' else $
	   if size(decpm,/type) gt 5 then ok='DEC proper motion must be a number'
if ok ne 'ok' then begin
  print,'Usage: applypm,ra,dec,rapm,decpm,ora,odec,fepoch=fepoch,tepoch=tepoch,verbose=vv'
  print,' apply proper motion to coordinates'
  if np ne 0 then message,ok,/informational
  return
endif

;	keywords
vv=0L & if keyword_set(verbose) then vv=long(verbose[0])>1
;
if not keyword_set(fepoch) then fromepoch=2000.0 else fromepoch=float(fepoch[0])
year=fix(fromepoch) & month=1+fix(12*(fromepoch-year))
mm=[31,28,31,30,31,30,31,31,30,31,30,31]
if 4.*long(year/4.) eq year then begin
  mm[1]=29
  if 100*long(year/100.) eq year and 400*long(year/400.) ne year then mm[1]=28
endif
tmm=total(mm,/cumul)-mm[0]
day=1+fix(365*(fromepoch-fix(fromepoch)))-tmm[month-1]
jdfro=julday(month,day,year)	;need this only if TEPOCH is not defined
if vv gt 100 then print,'fromepoch==',fromepoch,' ==> month,day,year ==',month,day,year
;
if not keyword_set(tepoch) then begin
  jdto=systime(/julian)
  yrshift=(jdto-jdfro)/365.25	;and thus to calculate how many years to elapse
endif else begin
  toepoch=float(tepoch[0])
  yrshift=toepoch-fromepoch	;and thus to calculate how many years to elapse
  ;year=fix(toepoch) & month=1+fix(12*(toepoch-year))
  ;mm=[31,28,31,30,31,30,31,31,30,31,30,31]
  ;if 4.*long(year/4.) eq year then begin
  ;  mm[1]=29
  ;  if 100*long(year/100.) eq year and 400*long(year/400.) ne year then mm[1]=28
  ;endif
  ;tmm=total(mm,/cumul)-mm[0]
  ;day=1+fix(365*(toepoch-fix(toepoch)))-tmm[month-1]
  ;jdto=julday(month,day,year)
  ;if vv gt 100 then print,'toepoch==',toepoch,' ==> month,day,year ==',month,day,year
endelse

if vv gt 10 then print,yrshift,' years in passing'

;	convert input RA,Dec to degrees
skypos,ra,dec,o1,o2,/i24

;	compute proper motion shift
dra=cos(o2[0]*!pi/2.)*rapm[0]*1e-3*yrshift/3600.
ddec=decpm[0]*1e-3*yrshift/3600.
if vv gt 10 then print,'delta RA = '+strtrim(dra[0],2)
if vv gt 10 then print,'delta Dec = '+strtrim(ddec[0],2)

;	convert new RA,Dec to sexagesimal
skypos,o1[0]+dra,o2[0]+ddec,o3,o4,/osxg

ora=o3[0] & odec=o4[0]
if vv gt 10 then print,ora+','+odec
if vv gt 1000 then stop,'HALTing; type .CON to continue'

return
end
