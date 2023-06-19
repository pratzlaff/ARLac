function expi,x,nmax=nmax,eps=eps
;+
;function	expi
;	returns the value of the exponential integral,
;		Ei(x) = - \int_{-x}^{\infty} dt e^{-t} / t
;		      = \int_{-\infty}^{x} dt e^{t} / t \,, x > 0
;
;parameters
;	x	[INPUT; required] value for which to compute Ei(.)
;
;keywords
;	nmax	[INPUT; default=100] do not consider terms in series
;		beyond NMAX.
;	eps	[INPUT; default=6e-8] relative error, or absolute error
;		near the zero of Ei at x=0.3725
;
;description
;	for small values of abs(x), uses series expansion (Abramowitz &
;	Stegun, 8.214.[1,2]); for large values, uses the asymptotic
;	expression (A&S, 8.215; NumRec, \S6.3)
;
;history
;	vinay kashyap (May98)
;-

;	usage
nx=n_elements(x)
if nx ne 1 then begin
  print,'Usage: y=expi(x,nmax=nmax,eps=eps)'
  print,'  computes Exponential Integral Ei(x)'
  return,0.
endif

;	initialize
C=0.57721566				;Euler's constant
if not keyword_set(nmax) then nmax=100
if not keyword_set(eps) then eps=6e-8
if not keyword_set(fpmin) then fpmin=1d-30

;	stupid user tricks
if abs(x) le fpmin then return,alog((x>(fpmin/100.)))+C	;too small to bother

;	pick the representation
if abs(x) lt abs(alog(EPS)) then powser=1 else powser=0

;	power series
if powser eq 1 then begin
  xx=abs(x)
  k=1 & y=alog(xx)+C & tmp=y
  while (abs(tmp)/abs(y)) gt eps and k le nmax do begin	;{add up terms
    tmp = k*alog(xx)-alog(k)-lngamma(k+1) & tmp=exp(tmp)
    y=y+tmp*(x/xx)^k & k=k+1
  endwhile					;(Y/TMP)<EPS or K>NMAX}
endif

;	asymptotic expression
if powser eq 0 then begin
  k=1 & tmp=1.0 & y=0.
  while abs(tmp) gt eps and k le nmax do begin	;{add up terms
    otmp=tmp & tmp=tmp*k/x & y=y+tmp & k=k+1
    if tmp gt otmp then begin
      y=y-tmp-otmp
      tmp=eps/10.			 ;diverging -- force quit!
    endif
  endwhile					;TMP>EPS or K>NMAX}
  y=exp(x)*(1.0+y)/x
endif

return,y
end
