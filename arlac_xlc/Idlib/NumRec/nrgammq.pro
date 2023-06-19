function nrgammq,a,x,series=series,cfrac=cfrac,maxit=maxit
;+
;function	nrgammq
;		returns the incomplete Gamma function Q(a,x)
;		IDL translation of GAMMQ.F (Numerical Recipes, Press et al.)
;
;parameters	a
;		x
;
;keywords	series	forces the use of the series representation
;			[equivalent to GSER.F of Press et al.]
;		cfrac	forces the use of continued fraction representation
;			[equivalent to GCF.F of Press et al.]
;			(if both are set, defaults to "best choice")
;		maxit	number of iterations {default = 100}
;
;history
;	vinay kashyap (1/16/95)
;-

np = n_params(0)
if np lt 2 then begin
  print, 'Usage: Q = nrgammq(a,x,/series,/cfrac,maxit=maxit)'
  print, '  returns the incomplete gamma function Q(a,x)'
  return,0.
endif

if x lt 0 or a le 0 then begin
  print, 'baaad argument(s) -- NRGAMMQ('+strtrim(a,2)+','+strtrim(x,2)+')'
  return,0.
endif

gser = 0 & if keyword_set(series) then gser = 1
gcf = 0 & if keyword_set(cfrac) then gcf = 1
itmax = 1000 & if keyword_set(maxit) then itmax = abs(fix(maxit))
eps = 3e-7 & fpmin = 1e-30

if gser+gcf eq 2 or gser+gcf eq 0 then begin
  if x lt a+1. then begin & gser = 1 & gcf = 0 & endif
  if x ge a+1. then begin & gser = 0 & gcf = 1 & endif
endif

idlversion = float(strmid(!version.release,0,3))
if idlversion gt 3.5 then gln = lngamma(a) else gln = gammln(a)

if gser eq 1 then begin
  ap = a & sum = 1./a & del = sum
  for i=1,itmax do begin
    ap = ap+1. & del = del*x/ap & sum = sum+del
    if abs(del) lt abs(sum)*eps then goto, sdone
  endfor
  print,'SER: A='+strtrim(a,2)+' too large,ITMAX='+strtrim(itmax,2)+' too small'
  sdone: gamser = sum*exp(-x+a*alog(x)-gln)
  gammq = 1.-gamser
endif

if gcf eq 1 then begin
  b = x+1.-a & c = 1./fpmin & d = 1./b & h = d
  for i=1,itmax do begin
    an = -i*(i-a) & b = b+2. & d = an*d+b
    if abs(d) lt fpmin then d = fpmin
    c = b+an/c
    if abs(c) lt fpmin then c = fpmin
    d = 1./d
    del = d*c & h = h*del
    if abs(del-1.) lt eps then goto, fdone
  endfor
  print,'CF: A='+strtrim(a,2)+' too large,ITMAX='+strtrim(itmax,2)+' too small'
  fdone: gammcf = exp(-x+a*alog(x)-gln)*h
  gammq = gammcf
endif

return,gammq
end
