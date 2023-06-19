function probsrc,cts,bkg,s,asrc=asrc,abkg=abkg,nstep=nstep, _extra=e
;+
;function	probsrc
;	based on Loredo, T.J. (1992, in Statistical Challenges in Modern
;	Astronomy, eds. E.D.Feigelson and G.J.Babu, Springer-Verlag, New
;	York, pp.275-297), returns the probability of the source strength
;	marginalized over background for given measurement.
;
;parameters
;	cts	[INPUT; required] observed counts in source region/bin
;	bkg	[INPUT; required] observed counts in background region/bin
;	s	[I/O] model parameter source counts/[region,bin]
;		* if defined on input, returns p(S|CTS)
;		* if S=0 on input, gets recalculated within the program
;
;keywords
;	asrc	[INPUT; default=1.] area/size of source region/bin
;	abkg	[INPUT; default=1.] area/size of background region/bin
;	nstep	[INPUT; default=101] number of elements in S if it has
;		to be calculated in situ
;
;history
;	vinay kashyap (May98)
;-

;	usage
nct=n_elements(cts) & nbg=n_elements(bkg) & ns=n_elements(s)
if nct ne 1 or nbg ne 1 then begin
  print,'Usage: p=probsrc(Nct,Nbg,s,asrc=asrc,abkg=abkg)'
  print,'  returns p(s|Nct), marginalized over background'
  return,-1L
endif

;	relative collection areas of CTS and BKG
if keyword_set(asrc) then sar=float(asrc(0)) else sar=1.
if keyword_set(abkg) then bar=float(abkg(0)) else bar=1.

;	define model parameter space
if ns ne 0 then ss=s else begin
  ns=1 & ss=0
endelse
if ns eq 1 and ss(0) eq 0 then begin
  ;smean=((cts-bkg*sar/bar)/sar) > (bkg/bar)
  smean=((cts-bkg*sar/bar)/sar) > 0
  if smean eq 0 then smean=1e-4
  smin=0.01*smean & smax=100.*smean
  if keyword_set(nstep) then ns=long(nstep)+1 else ns=101L
  ds=(alog10(smax)-alog10(smin))/(ns-1.)
  ss=findgen(ns)*ds+alog10(smin) & ss=10.^(ss)
endif
s=ss

;	now get the coefficients for the series (Loredo 1992, 5.14)
ci=dblarr(cts+1) & frac=1.+(bar/sar) & ii=lindgen(cts+1L)
ci=ii*alog(frac)+lngamma(cts+bkg-ii+1.)-lngamma(cts-ii+1.)
;for i=0L,long(cts) do ci(i)=i*alog(frac)+lngamma(cts+bkg-i+1)-lngamma(cts-i+1)
mci=max(ci) & ci=ci-mci+10
ci=exp(ci>(-60)) & ci=ci/total(ci)

;	now get the background marginalized probability (Loredo 1992, 5.13)
p=dblarr(ns) & ii=lindgen(cts+1)
for i=0L,ns-1L do begin			;{for each source strength
  if ss(i) gt 0 then begin
    tmp=alog(ci*sar)+(ii)*alog((ss(i)*sar))-ss(i)*sar-lngamma(ii+1) > (-70)
  endif else tmp=[alog(ci(0))]
  p(i)=total(exp(tmp))
endfor					;I=0,NS-1}

return,p
end
