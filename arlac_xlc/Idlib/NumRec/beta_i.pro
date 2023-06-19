function beta_i,a,b,x
;+
;function	beta_i	returns the incomplete beta function, I_x(a,b)
;			(from Numerical Recipes, Press et al. 1986, p167)
;parameters	a
;		b
;		x
;description
;	I_x(a,b) = B_x(a,b)/B(a,b), and
;	B_x(a,b) = \int{0}{x} t^{a-1} (1-t)^{b-1} dt
;	I_0(a,b) = 0, I_1(a,b) = 1, I_x(a,b) = 1 - I_{1-x}(b,a)
;also,
;       I_x(a,b) = {{x^a (1-x)^b} \over {a B(a,b)}}
;                  \left(1 + \Sum_{n=0}^{\inf}
;                  {B(a+1,n+1) \over B(a+b,n+1)} x^{n+1} \right)
;-

if x lt 0 or x gt 1 then stop, 'bad argument X in BETAI',x
if x eq 0. or x eq 1. then begin
  bt = 0.
endif else begin
  bt = exp(gammln(a+b)-gammln(a)-gammln(b)+a*alog(x)+b*alog(1.-x))
endelse
if x lt (a+1.)/(a+b+2.) then begin
  val = bt*beta_cf(a,b,x)/a & return,val
endif else begin
  val = 1.-bt*beta_cf(b,a,1.-x)/b & return,val
endelse

return,val
end
