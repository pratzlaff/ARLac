function old_probsrc,cts,bkg,s,asrc=asrc,abkg=abkg, _extra=e
;+
;function	old_probsrc
;	based on Loredo (1989), returns the probability of the source
;	strength parameter marginalized over background for given measurement.
;
;parameters
;	cts	[INPUT; required] observed counts in source region/bin
;	bkg	[INPUT; required] observed counts in background region/bin
;	s	[I/O] model parameter source counts/[region,bin]
;		* if defined on input, returns p(S|CTS)
;		* if S(0)=0 on input, gets recalculated within the program
;
;keywords
;	asrc	[INPUT; default=1.] area/size of source region/bin
;	abkg	[INPUT; default=1.] area/size of background region/bin
;
;history
;	vinay kashyap (May98)
;-

;	usage
nct=n_elements(cts) & nbg=n_elements(bkg) & ns=n_elements(s)
if nct ne 1 or nbg ne 1 then begin
  print,'Usage: p=old_probsrc(Nct,Nbg,s,asrc=asrc,abkg=abkg)'
  print,'  returns p(s|Nct), marginalized over background'
  return,-1L
endif

;	relative collection areas of CTS and BKG
if keyword_set(asrc) then sar=float(asrc(0)) else sar=1.
if keyword_set(abkg) then bar=float(abkg(0)) else bar=1.

;	define model parameter space
if ns ne 0 then ss=s else ss=0
if ss(0) eq 0 then begin
  smean=((cts-bkg*sar/bar)/sar) > (bkg/bar)
  if smean eq 0 then smean=0.1
  smin=0.01*smean & smax=100.*smean & ns=1001
  ds=(alog10(smax)-alog10(smin))/(ns-1.)
  ss=findgen(ns)*ds+alog10(smin) & ss=10.^(ss)
endif
s=ss

;	stupid user tricks
if cts eq 0 or bkg eq 0 then begin
  ;if cts eq 0 then ss=findgen(100)*0.1+0.1 else ss=findgen(100)*0.1+cts*0.5
  if bkg eq 0 then bb=findgen(100)*0.1+0.1 else bb=findgen(100)*0.1+bkg*0.5
  pp=old_probsrcbkg(cts,bkg,ss,bb,asrc=sar,abkg=bar, _extra=e)	;pp(NS,NB)
  pnorm=fltarr(100) & ds=ss(1:*)-ss
  for i=0,100-1 do pnorm(i)=total(pp(*,i)*ds)	;integrate over S
  pnorm=total(pnorm)*0.1			;integrate over B
  pp=pp/pnorm
  p=dblarr(ns) & for i=0,ns-1 do p(i)=total(pp(i,*)*0.1)	;marginalize
  return,p
endif

;	now get the coefficients for the series (Loredo 1989, eqn 47)
ci=dblarr(cts) & frac=1.+(bar/sar)
for i=1,cts do ci(i-1)=i*alog(frac)+lngamma(cts+bkg-i)-lngamma(cts-i+1)
ci=exp(ci) & ci=ci/total(ci)

;	now get the marginalized background (Loredo 1989, eqn 46)
p=dblarr(ns) & ii=lindgen(cts)+1
for i=0L,ns-1L do begin			;{for each source strength
  tmp=alog(ci)+alog(sar)+(ii-1)*alog((ss(i)*sar))-ss(i)*sar-lngamma(ii) > (-70)
  p(i)=total(exp(tmp))
endfor					;I=0,NS-1}

return,p
end
