function old_probsrcbkg,cts,bkg,s,b,asrc=asrc,abkg=abkg,minbg=minbg,prbg=prbg
;+
;function	old_probsrcbkg
;	returns the joint probability distribution of the source strength
;	and background for given measurement.
;	WARNING: the value returned is NOT normalized such that the
;	integral of the joint distribution over source and background
;	strengths is 1.
;
;parameters
;	cts	[INPUT; required] observed counts in source region/bin
;	bkg	[INPUT; required] observed counts in background region/bin
;	s	[INPUT; required] array of source strengths at which to
;		compute p(S,B|CTS,BKG)
;	b	[INPUT; required] array of background strengths at which to
;		compute p(S,B|CTS,BKG)
;		* p(S.lt.0, B.le.0 | CTS, BKG) = 0
;
;keywords
;	asrc	[INPUT; default=1.] area/size of source region/bin
;	abkg	[INPUT; default=1.] area/size of background region/bin
;	minbg	[INPUT] minimum possible value for the background
;		* if not supplied, taken from min(B(where(B gt 0)))
;		* if above does not work, set to 1e-5
;	prbg	[INPUT] if supplied, this is used instead of calculating p(B)
;		* size MUST match that of B, else ignored.
;		* if this is given, MINBG becomes irrelevant
;
;history
;	vinay kashyap (May98)
;-

;	usage
nct=n_elements(cts) & nbg=n_elements(bkg) & ns=n_elements(s) & nb=n_elements(b)
nprb=n_elements(prbg)
if nct ne 1 or nbg ne 1 or ns lt 1 or nb lt 1 then begin
  print,'Usage: p=old_probsrcbkg(Nct,Nbg,s,b,asrc=asrc,abkg=abkg)'
  print,'  returns joint probability distribution p(s,b|Nct,Nbg)'
  return,-1L
endif

;	relative collection areas of CTS and BKG
if keyword_set(asrc) then sar=asrc(0) else sar=1.
if keyword_set(abkg) then bar=abkg(0) else bar=1.

;	recast grid
ss=[s(*)] & bb=[b(*)]

;	figure out minimum background
if nprb ne nbg then begin
  if not keyword_set(minbg) then begin
    oo=where(bb gt 0,moo)
    if moo gt 0 then bgmin=min(bb(oo)) else bgmin=1e-5
  endif else bgmin=minbg
  ;	this is the normalization for p(B|BKG=0), == -Ei(-bgmin*bar)
  b0norm=-expi(-bgmin*bar)
endif

;	output array
prob=fltarr(ns,nb)+0*s(0)

;	step through the grid
for i=0L,nb-1L do begin			;{for each background
  ;
  bg=bb(i)
  if bg gt 0 then begin			;(only for non-zero bkg
    ;	get p(b)
    if nprb ne nbg then begin
      tmp = bg*bar < 60.
      if bkg eq 0 then p_b=(1./bg)*exp(-tmp)/b0norm else begin	;(BKG?0
        p_b=bar*(bg*bar)^(BKG-1)*exp(-tmp)/gamma(BKG)
      endelse							;BKG>0)
    endif else p_b=[prbg(*)]
    ;
    ok=where(ss gt 0,mok)
    if mok ne 0 then begin		;(for src strengths > 0
      ;	get p(s|b)
      p_s_b = 1./(ss(ok)+bg)
      ;	get p(Nct|S,B)
      tmp = bg*(sar+bar) + ss(ok)*sar
      p_nct_sb = CTS*alog(sar*(ss(ok)+bg))-tmp-lngamma(CTS+1)
      p_nct_sb = exp(p_nct_sb)
      ;
      ;	get p(s,b|cts,bkg)
      prob(ok,i)=p_s_b(*)*p_b*p_nct_sb(*)
    endif				;SS>0)
  endif					;BG>0)
endfor					;I=0,NB-1}

return,prob
end
