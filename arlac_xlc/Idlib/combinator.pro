function combinator,n,m,stirl=stirl,gamm=gamm, _extra=e
;+
;function	combinator
;	returns the combinatorial function nCm = \frac{n!}{m!(n-m)!}
;	as a double-precision number.
;
;parameters
;	n	[INPUT; required] the "n" of nCm
;	m	[INPUT] the "m" of nCm
;		* if not given, output is returned as an (N+1) element
;		  array, with nCm computed for M=0..N
;
;keywords
;	stirl	[INPUT] if set, forces the use of the Stirling approximation
;		* ignored if GAMM is also set
;	gamm	[INPUT] if set, forces the use of the gamma-function to
;		compute factorials
;		* gamma-function is used regardless if
;		  N-max([M,N-M]) > 100
;		  N-long(N) > 0
;
;	_extra	[JUNK] ignore -- here only to prevent crashing the program
;
;history
;	vinay kashyap (mar99)
;-

;	usage
nn=n_elements(n) & ok='ok'
if nn eq 0 then ok='"n" of nCm is missing' else $
 if nn gt 1 then ok='cannot handle an array of "n"s in nCm'
if ok ne 'ok' then begin
  print,'Usage: nCm = combinator(n,m,/stirl,/gamm)'
  print,'  returns nCm = \frac{n!}{m!(n-m)!}'
  return,1.D
endif
;
;	error check
xn=double(n(0))
if xn le 0 then begin
  message,'cannot compute nCm with n<0; returning',/info
  return,1.D
endif

;	check input
nm=n_elements(m)
if nm eq 0 then begin
  xm=lindgen(long(xn)+1) & nm=long(xn)+1
endif else xm=m
;
;	error check
ok='ok'
if nm gt 1 then begin
  oo=where(xm gt xn,moo)
  if moo gt 0 then ok='cannot compute nCm with m>n; forcing max(m)=n'
  oo=where(xm lt 0,moo)
  if moo gt 0 then ok='cannot compute nCm with m<0; forcing min(m)=0'
endif else begin
  if xm(0) gt xn then ok='cannot compute nCm with m>n; forcing max(m)=n'
  if xm(0) lt 0 then ok='cannot compute nCm with m<0; forcing min(m)=0'
endelse
if ok ne 'ok' then begin
  message,ok,/info
  xm = ((xm > 0) < (xn))
endif

;	check keywords
if keyword_set(stirl) then stirling=1 else stirling=0
if keyword_set(gamm) then gammfn=1 else gammfn=0
if xn-long(xn) gt 0 then gammfn=1
for i=0L,nm-1L do if xn-max([xm(i),xn-xm(i)]) gt 100 then gammfn=1
if gammfn then stirling=0		;gamma fn takes precedence

;	output
nCm=0.D*xm+1.D

;	the Stirling approximation
;	N! = sqrt(2 \pi N) * N^N * exp(-N)
;	ln(nCM) = -0.5*ln(2\pi) + 0.5*ln(N/(M*(N-M))) +$
;		(NlnN-N) - (MlnM-M) - ((N-M)ln(N-M)-(N-M))
if stirling then begin				;(STIRLING approx
  fact0=-0.5*alog(2.*!pi)
  for i=0L,nm-1L do begin
    ym=xm(i) & ynm=xn-xm(i)
    if xn le 0 then nfact=fact0 else nfact=xn*alog(xn)-xn+alog(xn)/2.
    if ym le 0 then mfact=fact0 else mfact=ym*alog(ym)-ym+alog(ym)/2.
    if ynm le 0 then nmfact=fact0 else nmfact=ynm*alog(ynm)-ynm+alog(ynm)/2.
    nCm(i) = exp(nfact-mfact-nmfact) / sqrt(2.*!dpi)
  endfor
  return,nCm
endif						;STIRLING)

;	the Gamma-function approximation
;	N! = Gamma(N+1)
;	ln(nCM) = ln(Gamma(N+1)) - ln(Gamma(M+1)) - ln(Gamma(N-M+1))
if gammfn then begin				;(Gamma-fn
  for i=0L,nm-1L do begin
    ym=xm(i) & ynm=xn-xm(i)
    if xn le 0 then nfact=0.D else nfact=lngamma(xn+1.D)
    if ym le 0 then mfact=0.D else mfact=lngamma(ym+1.D)
    if ynm le 0 then nmfact=0.D else nmfact=lngamma(ynm+1.D)
    nCm(i)=exp(nfact-mfact-nmfact)
  endfor
  return,nCm
endif						;Gamma-fn)

;	the brute force calculation
;	nCm = N * N-1 * ... * max([N-M+1,M+1]) / 1 * 2 * ... * min([N-M,M])
for i=0L,nm-1L do begin
  yn=long(xn) & ym=long(xm(i)) & ynm=yn-ym
  ymin=min([ym,ynm]) & tmp=1.D
  for j=0L,ymin-1L do tmp=tmp*double(yn-j)/double(j+1L)
  nCm(i)=tmp
endfor
return,nCm

end
