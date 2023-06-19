pro gser,gammp,a,x
;+
;returns the incomplete gamma function P(a,x) evaluated by its series
;representation.  from Press et al, p162

itmax = 100 & eps = 3.e-7 & gln = gamma(a)
ap = a & sum = 1./a & del = sum
for n=0,itmax-1 do begin
  ap = ap + 1. & del = del*x/ap & sum = sum + del
  if abs(del) lt abs(sum)*eps then goto, out
endfor
print, a,'(a) too large,',itmax,'(itmax) too small'
out:	gammp = sum*exp(-x+a*alog(x)-gln)

return
end

pro gcf,gammp,a,x
;returns the incomplete gamma function P(a,x) evaluated by its continued
;fraction representation.  from Press et al, p162

itmax = 100 & eps = 3.e-7 & gln = gamma(a)
gold = 0. & a0 = 1. & a1 = x & b0 = 0. & b1 = 1. & fac = 1.
for n=0,itmax-1 do begin
  an = float(n) & ana = an-a & a0 = (a1+a0*ana)*fac
  b0 = (b1+b0*ana)*fac & anf = an*fac
  a1 = x*a0 + anf*a1 & b1 = x*b0 + anf*b1
  if a1 ne 0 then begin
    fac = 1./a1 & g = b1*fac
    if abs((g-gold)/g) lt eps then goto,out
    gold = g
  endif
endfor
print, a,'(a) too large,',itmax,'(itmax) too small'

out:	gammp = exp(-x+a*alog(x)-gln)*g

return
end

pro fit,x,y,ndata,sig,mwt,a,b,siga,sigb,chi2,q
;given a set of points x(ndata) & y(ndata) with std. deviations sig(ndata),
;fits them to a straight line y = a + b*x by minimizing chi-square.  if mwt
;is 0 on input, sig(*) are assumed to be unavailable: q (the goodness of fit
;probability) is returned as 1.0 and the normalization of chi2 is to unit
;standard deviation on all points.  translated from Numerical Recipes
;(Press et al. 1986).

sx = 0. & sy = 0. & st2 = 0. & b = 0.

if mwt ne 0 then begin
  ss = 0.
  for i = 0,ndata-1 do begin
    wt = sig(i)^(-2) & ss = ss + wt & sx = sx + x(i)*wt & sy = sy + y(i)*wt
  endfor
endif
if mwt eq 0 then begin
  ss = float(ndata) & sig(*) = 1.0
  for i=0,ndata-1 do begin
    sx = sx + x(i) & sy = sy + y(i)
  endfor
endif

sxoss = sx/ss
for i = 0,ndata-1 do begin
  t = (x(i)-sxoss)/sig(i) & st2 = st2 + t*t & b = b + t*y(i)/sig(i)
endfor

b = b/st2 & a = (sy-sx*b)/ss & siga = sqrt((1.+sx*sx/(ss*st2))/ss)
sigb = sqrt(1./st2)

chi2 = 0.
for i=0,ndata-1 do chi2 = chi2 + ((y(i)-a-b*x(i))/sig(i))^2
if mwt eq 0 then begin
  q = 1. & sigdat = sqrt(chi2/(ndata-2))
  siga = siga*sigdat & sigb = sigb*sigdat
endif
if mwt ne 0 then begin
  ;q = gammq(0.5*(ndata-2),0.5*chi2)
  ga = 0.5*(ndata-2) & gx = 0.5*chi2
  if gx lt ga+1 then begin
    gser,gammp,ga,gx & q = 1. - gammp
  endif else begin
    gcf,gammp,ga,gx & q = gammp
  endelse
endif

return
end
