function pds_minsec,dd,mm,ss,dsign=dsign,$
	_extra=e
;+
;function	pds_minsec
;	converts decimal degrees or hours into [deg or hours,minutes,seconds],
;	and vice versa.  [d,m,s] is returned as a structure, and [deg] as a
;	float scalar or array.
;
;syntax
;	.run pds_minsec
;	dms=pds_minsec(decimal_deg_or_hr,dsign=dsign)
;	d=pds_minsec(d,m,s)
;
;parameters
;	dd	[INPUT; required] degrees or hours
;		* if sole input, assumed to be decimal deg or hr
;		* if MM and SS are given, assumed to be part of [d:m:s]
;	mm	[INPUT; required if d:m:s] minutes
;	ss	[INPUT; required if MM is given] seconds
;		* if <0, set the first non-zero of [d:m:s] to negative
;		* if the array sizes of DD,MM,SS match, output will be
;		  of same size
;		* if array sizes don't match, calculations will be performed
;		  for all possible combinations of {DD x MM x SS}
;
;keywords
;	dsign	[OUTPUT] the sign is returned as a '+' or '-'
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;	a basic building block of P.D.-S.'s routines, converts
;	angles to sexagesimal and vice versa
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1000
;	translated to IDL by Vinay Kashyap (Jul2007)
;	  note: original uses a switch to tell which way to convert, and
;	  returns sign as a separate variable.
;-

;	usage
ok='ok' & np=n_params()
nd=n_elements(dd) & nm=n_elements(mm) & ns=n_elements(ss)
if np eq 0 then ok='Insufficient parameters' else $
 if np gt 1 and np lt 3 then ok='Insufficient parameters' else $
  if nd eq 0 then ok='DD is undefined' else $
   if np eq 3 and nm eq 0 then ok='MM is undefined' else $
    if np eq 3 and ns eq 0 then ok='SS is undefined'
if ok ne 'ok' then begin
  print,'Usage: dms=pds_minsec(decimal_deg_or_hr,dsign=dsign)'
  print,'       deg=pds_minsec(d,m,s)'
  print,'  converts decimal degrees or hours into [d,m,s] and vice versa'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

case np of
  1: begin		;(convert deg -> [d,m,s]
     ;	sign
     dsign=strarr(nd)+'+'
     om=where([dd] lt 0,mom)
     if mom gt 0 then dsign[om]='-'

     xp=abs([dd]) & xd=fix(xp)
     a=(xp-xd)*60. & xm=fix(a)
     xs=(a-xm)*60.

     if mom gt 0 then xd[om]=-xd[om]
     oo=where(xd eq 0 and dsign eq '-',moo) & if moo gt 0 then xm[oo]=-xm[oo]
     oo=where(xd eq 0 and xm eq 0 and dsign eq '-',moo) & if moo gt 0 then xs[oo]=-xs[oo]

     dms=create_struct('D',xd,'M',xm,'S',xs)
     if nd eq 1 then dms=create_struct('D',xd[0],'M',xm[0],'S',xs[0])
     return,dms
  end			;deg -> d:m:s)
  3: begin		;(convert d:m:s -> deg
     ;	define the output
     xd=[dd] & xm=[mm] & xs=[ss] & dsign=strarr(nd)+'+'
     if nd ne nm or nd ne ns then begin
       xd=dblarr(nd,nm,ns) & for i=0,nd-1 do xd[i,*,*]=dd[i]
       xm=dblarr(nd,nm,ns) & for j=0,nm-1 do xm[*,j,*]=mm[i]
       xs=dblarr(nd,nm,ns) & for k=0,ns-1 do xs[*,*,k]=ss[i]
       dsign=strarr(nd,nm,ns)+'+'
     endif
     ;	sign
     om=where(xd lt 0 or xm lt 0 or xs lt 0,mom)
     if mom gt 0 then dsign[om]='-'
     xd1=abs(xd) & xm1=abs(xm) & xs1=abs(xs)
     x=((((xs1/60.)+xm1)/60.)+xd1)
     if mom gt 0 then x[om]=-x[om]
     if nd eq 1 then return,x[0] else return,x
  end			;d:m:s -> deg)
  else: message,'BUG: conversion direction not understood'
endcase

end

;	handling program for PDS_MINSEC

jnk=pds_minsec()
print,'' & print,''
ans='Do Degrees/hours conversion? [N/Y] ' & read,prompt=ans,ans
c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

while go_on do begin
  ans='... to mins & secs [Y/N] > ' & read,prompt=ans,ans
  c1=strtrim(ans,2)
  if c1 eq '' or strmid(strupcase(c1),0,1) eq 'Y' then begin
    read,prompt='input decimal deg or hour > ',x
    dms=pds_minsec(x,dsign=dsign)
    print,'	... converts to ',dsign[0],dms.D,dms.M,dms.S
  endif else begin
    read,prompt='input deg or hour, mins, secs > ',xd,xm,xs
    dd=pds_minsec(xd,xm,xs)
    print,'	... converts to ',dd
  endelse
  ;
  ans='Again? [Y/N] ' & read,prompt=ans,ans
  c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0
endwhile

end
