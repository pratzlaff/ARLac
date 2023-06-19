function q_factor,l,R
;+
;returns the geometric volume correction factor
;	q(x) = x + x^2 + (1/3)*x^3 + (1/3)*(2*x+x^2)^(3/2)
;where
;	x = l/R
;and
;	L_x = 2*!pi*n_e^2*P(T)*R^3*q(x)
;-

if n_params(0) lt 1 then begin
  print, 'Usage: qx = q(l,R)'
  return,0L
endif

if n_params(0) eq 1 then R = l

x = alog10(l) - alog10(R) & x = 10^x

var = x + x^2 + (x^3 + (2.*x + x^2)^(1.5)) / 3.

return,var
end
