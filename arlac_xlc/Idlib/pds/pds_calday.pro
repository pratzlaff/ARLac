function pds_calday,djd,julday=julday,fracday=fracday,$
	_extra=e
;+
;function	pds_calday
;	converts the number of Julian Days since 1900 January 0.5 (i.e., noon
;	at Greenwich on 31 December 1899) into the calendar date, [day,mon,yr]
;	which is returned as a structure.
;	* see also PDS_JULDAY()
;
;syntax
;	.run pds_calday
;	dmy=pds_calday(djd,/julday,fracday=fracday)
;
;parameters
;	djd	[INPUT; required] number of Julian Days since 1900 Jan 0.5
;		* if keyword JULDAY is set, assumed to be actual JD
;
;keywords
;	julday	[INPUT] if set, assumes that actual Julian Day number is
;		given, and 2415020 is subtracted from the input
;	fracday	[OUTPUT] fraction of a whole day that is left over
;		* same as DMY.DAY-FIX(DMY.DAY)
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;	a basic building block of P.D.-S.'s routines, converts
;	Julian Day to calendar date
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1200
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params() & nd=n_elements(djd)
if np lt 1 then ok='Insufficient parameters' else $
 if nd eq 0 then ok='DJD is undefined'
if ok ne 'ok' then begin
  print,'Usage: dmy=pds_calday(djd,/julday,fracday=fracday)'
  print,'  converts number of Julian days since 1900-jan-0.5 to calendar date'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

dj=[double(djd)]+0.5
if keyword_set(julday) then dj=dj-2415020L
ii=floor(dj)	;replaces function FNLIF()
ff=dj-ii

o1=where(ff eq 1,mo1)
if mo1 gt 0 then begin
  ff[o1]=0 & ii=ii+1
endif

ol=where(ii le -115860L,mol,complement=og,ncomplement=mog)
aa=floor( (ii/36524.25)+0.99835726D ) + 14
if mog gt 0 then ii[og]=ii[og]+1+aa[og]-floor(aa[og]/4.)
bb=floor((ii/365.25) + 0.802601D )
ce=ii-floor((365.25*bb) + 0.750001D ) + 416
gg=floor(ce/30.6001)
mn=gg-1
dy=ce-floor(30.6001*gg)+ff
yr=bb+1899

om=where(gg gt 13.5,mom) & if mom gt 0 then mn[om]=gg[om]-13
oy=where(mn lt 2.5,moy) & if moy gt 0 then yr[oy]=bb[oy]+1900
oy1=where(yr lt 1,moy1) & if moy1 gt 0 then yr[oy1]=yr[oy1]-1

;	correct the output size for scalar inputs
fracday=ff
if nd eq 1 then begin
  yr=yr[0] & mn=mn[0] & dy=dy[0] & fracday=fracday[0]
endif
dmy=create_struct('DAY',dy,'MONTH',mn,'YEAR',yr)

return,dmy

end

;	handling program for PDS_CALDAY

jnk=pds_calday()
print,'' & print,''
ans='convert Julian date to calendar dates? [N/Y]' & read,prompt=ans,ans & c1=strtrim(ans,2)
go_on=0 & if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

while go_on do begin
  ans='convert JD (J) or DJD (D)? [D/J] > ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 eq '' or strmid(strupcase(c1),0,1) eq 'D' then fordjd=1 else fordjd=0

  if keyword_set(fordjd) then begin
    ans='Julian days since 1900 Jan 0.5 > ' & djd=0.D & read,prompt=ans,djd
    dmy=pds_calday(djd,fracday=ff)
    dms=pds_minsec(ff*24.)
    print,'	Calendar date is: ',strtrim(dmy.YEAR,2)+'-'+strtrim(dmy.MONTH,2)+'-'+strtrim(fix(dmy.DAY),2)+$
	' '+strtrim(dms.D,2)+':'+strtrim(dms.M,2)+':'+strtrim(dms.S,2)
    caldat,djd+julday(1,0.5,1900),idl_mon,idl_day,idl_yr,idl_hr,idl_min,idl_sec
  endif else begin
    ans='Julian date > ' & jd=0.D & read,prompt=ans,jd
    dmy=pds_calday(jd,/julday,fracday=ff)
    dms=pds_minsec(ff*24.)
    print,'	Calendar date is: ',strtrim(dmy.YEAR,2)+'-'+strtrim(dmy.MONTH,2)+'-'+strtrim(fix(dmy.DAY),2)+$
	' '+strtrim(dms.D,2)+':'+strtrim(dms.M,2)+':'+strtrim(dms.S,2)
    caldat,jd,idl_mon,idl_day,idl_yr,idl_hr,idl_min,idl_sec
  endelse
  print,'	compare to IDL CALDAT()..: ',strtrim(idl_yr,2)+'-'+strtrim(idl_mon,2)+'-'+strtrim(idl_day,2)+$
	' '+strtrim(idl_hr,2)+':'+strtrim(idl_min,2)+':'+strtrim(idl_sec,2)

  ;
  ans='Again? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0
endwhile

end
