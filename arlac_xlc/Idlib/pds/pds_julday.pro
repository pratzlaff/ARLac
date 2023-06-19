function pds_julday,dd,mm,yy,jday=jday,$
	_extra=e
;+
;function	pds_julday
;	calculates the number of days elapsed since the epoch 1900 January 0.5
;	(noon at Greenwich on 31 December 1899)
;
;syntax
;	.run pds_julday
;	djd=pds_julday(dd,mm,yy,jday=jday)
;
;parameters
;	dd	[INPUT; required] day of month
;	mm	[INPUT; required] month of year
;	yy	[INPUT; required] year in common usage
;		* BC is represented as -ve numbers and there is no year zero
;		  BC .. -3, -2, -1, 1, 2, 3 .. AD
;		* prior to 1582 Oct 15, the Julian calendar is assumed, i.e.,
;		  1582 Oct 15 is preceded by 1582 Oct 4
;		* if the array sizes of DD,MM,YY match, output will be
;		  of same size
;		* if array sizes don't match, calculations will be performed
;		  for all possible combinations of {DD x MM x YY}
;
;keywords
;	jday	[OUTPUT] the Julian Day number, which is just an
;		offset to the primary output by 2415020
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;	a basic building block of P.D.-S.'s routines, converts
;	calendar date to Julian Day
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1100
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params() & nd=n_elements(dd) & nm=n_elements(mm) & ny=n_elements(yy)
if np lt 3 then ok='Insufficient parameters' else $
 if nd eq 0 then ok='DD is undefined' else $
  if nm eq 0 then ok='MM is undefined' else $
   if ny eq 0 then ok='YY is undefined'
if ok ne 'ok' then begin
  print,'Usage: jd=pds_julday(day,month,year,jday=jday)'
  print,'  calculates days elapsed since 1900 Jan 0.5'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	define output
djd=dblarr(nd) & nout=nd	;default -- if array sizes match
if nd ne nm or nd ne ny then begin
  djd=dblarr(nd,nm,ny) & nout=nd*nm*ny	;if array sizes don't match
endif
jday=djd

;	inputs
if nd ne nm or nd ne ny then begin
  dy=dblarr(nd,nm,ny) & for i=0L,nd-1L do dy[i,*,*]=dd[i]
  mn=intarr(nd,nm,ny) & for j=0L,nm-1L do mn[*,j,*]=mm[j]
  yr=intarr(nd,nm,ny) & for k=0L,ny-1L do yr[*,*,k]=yy[k]
endif else begin
  dy=[dd] & mn=[mm] & yr=[yy]
endelse
mn1=mn & yr1=yr
ax=long(0*dd) & bx=ax & cx=ax & dx=ax
;
om=where(yr1 lt 0,mom) & if mom gt 0 then yr1[om]=yr1[om]+1
op=where(yr1 gt 0,mop)
o3=where(mn lt 3,mo3) & if mo3 gt 0 then begin
  mn1[o3]=mn[o3]+12 & yr1[o3]=yr1[o3]-1
endif
ax=long(yr1/100.) & bx=2-ax+long(ax/4.)

;	the Julian to Gregorian correction
oz=where((yr lt 1582) or (yr eq 1582 and mn lt 10) or (yr eq 1582 and mn eq 10 and dy lt 15),moz)
if moz gt 0 then bx[oz]=0

if mop gt 0 then cx[op]=long(365.25*yr1[op])-694025d
if mom gt 0 then cx[om]=-long(abs(365.25*yr1[om]-0.75))-694025d
dx=long(30.6001*(mn1+1.))
djd=bx+cx+dx+dy-0.5
jday=djd+2415020d

;	correct the output size for scalar inputs
if nout eq 1 then begin
  djd=djd[0] & jday=jday[0]
endif

return,djd

end

;	handling program for PDS_JULDAY

jnk=pds_julday()
print,'' & print,''
ans='convert calendar date to Julian Days? [N/Y]' & read,prompt=ans,ans
c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

while go_on do begin
  read,prompt='input calendar date [D,M,Y] > ',dd,mm,yy
  djd=pds_julday(dd,mm,yy,jday=jday)
  print,'	J days since 1900 Jan 0.5: ',djd
  print,'	Julian date..............: ',jday
  print,'	compare to IDL JULDAY()..: ',julday(mm,dd,yy)
  ;
  ans='Again? [Y/N] ' & read,prompt=ans,ans
  c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0
endwhile

end
