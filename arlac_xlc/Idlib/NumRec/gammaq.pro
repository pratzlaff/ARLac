;+
;FUNCTION 	GAMMAQ
;		Returns the value of the incomplete Gamma Function, Q(a,x)
;
;PARAMETERS
;		a	"a" in Q(a,x)
;		x	"x" in Q(a,x)
;
;KEYWORDS
;		inx	if set, computes Q(a,x) for all x specified with inx
;			(does NOT override the parameter X)
;
;SUBROUTINES
;	GAMMLN	returns the log_e of the Gamma function
;	GSER	Returns the incomplete Gamma function, P(a,x), evaluated
;		by its series representation			<<INCLUDED>>
;	GCF	Returns the incomplete Gamma function, Q(a,x), evaluated
;		by its continued fraction representation	<<INCLUDED>>
;
;DESCRIPTION
;	this set of routines are translated from pp 157-162 of Numerical
;	Recipes, by Press et al. (1986), so comments will be held to a minimum.
;	GAMMAQ returns the incomplete gamma function,
;		Q(a,x) = (gamma(a))^-1 * int {x->inf} (exp(-t)*t^(a-1)*dt)
;-

;-----------------------------------------------------------------------

function gser,a,x,gln
;series representation of P(a,x)

itmax = 100 & eps = 3e-7

if x le 0. then return,0.

ap = a & sum = 1./a & del = sum
for n=0,itmax do begin
  ap = ap+1. & del=del*x/ap & sum=sum+del
  if abs(del) lt abs(sum)*eps then goto, out
endfor
print, 'a(',a,') or x(',x,') too large; itmax(',itmax,') too small'
out: gamser = sum * exp(-x+a*alog(x)-gln)

return,gamser
end

;-----------------------------------------------------------------------

function gcf,a,x,gln
;continued fraction representation of Q(a,x)

itmax = 100 & eps = 3e-7

gold = 0. & a0 = 1. & a1 = x & b0 = 0. & b1 = 1. & fac = 1.
for n=0,itmax do begin
  an=float(n+1) & ana=an-a & a0=(a1+a0*ana)*fac & b0=(b1+b0*ana)*fac
  anf=an*fac & a1=x*a0+anf*a1 & b1=x*b0+anf*b1
  if a1 ne 0. then begin
    fac=1./a1 & g=b1*fac
    if abs((g-gold)/g) lt eps then goto, out
    gold=g
  endif
endfor
print, 'a(',a,') or x(',x,') too large; itmax(',itmax,') too small'
out: gammcf = exp(-x+a*alog(x)-gln)*g

return,gammcf
end

;-----------------------------------------------------------------------

function gammaq,a,x,inx=inx
;incomplete gamma function, Q(a,x)

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: q = gammaq(a,x [,inx=inx])'
  print, '  Returns the incomplete gamma function, Q(a,x)'
  print, '  (cf. Numerical Recipes, pp 157-162)' & return,0L
endif

xin = a*(findgen(101)/50.)^2 & if keyword_set(inx) then xin = inx
if np eq 1 then x = xin

gln = gammln(a) & nstp = n_elements(x) & q = x*0.

for i=0,nstp-1 do begin
  xx = x(i) & c1 = 'in GAMMAQ: x ='+strcompress(xx)+' & a ='+strcompress(a)
  if xx lt 0 or a le 0 then stop, c1
  if xx lt (a+1.) then q(i) = 1.0 - gser(a,xx,gln)
  if xx ge (a+1.) then q(i) = gcf(a,xx,gln)
endfor

inx = x

return,q
end
