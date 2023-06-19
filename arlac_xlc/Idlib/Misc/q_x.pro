function q_x,x,rosner=rosner
;+
;function	q_x
;		returns the value of the geometric Q-factor which corrects
;		the luminosity from a shell of plasma surrounding an opaque
;		star
;
;parameters	x	l/R = thickness of shell/radius of star
;
;keywords	rosner	if set, uses Bob's formula (whose derivation is
;			unfortunately lost).  the default is to use the
;			exact expression from Kashyap et al. 1992, ApJ 391,
;			684, modified to correct the thin-shell.
;
;description
;	Lx = 4 \pi R^2 l <n^2 P(T)> ff Q(x)
;	where R=stellar radius, l=thickness of shell~loop length,
;	      ff=filling fraction, <n^2 P(T)>=average emission, and
;	default Q(x) = 0.5*(x + x^2 + (1/3)*x^3 + (1/3)*(2*x+x^2)^(3/2))/x
;	else	Q(x) = (1/3)*((1/2)+2*x+x^2)*(1+(1/x)-(1/x)/(1+x)^2)
;-

if n_params(0) lt 1 then begin
  print, 'Usage: Q = q_x(x [,/rosner])'
  print, '  computes the geometric correction factor' & return,0L
endif

z = x > 1e-12

if keyword_set(rosner) then begin
  q = (1./3.)*(0.5+2.*z+z^2)*(1.+(1./z)-(1./z)/(1.+z)^2)
endif else q = 0.5*(z + z^2 + (1./3.)*z^3 + (1./3.)*(2.*z+z^2)^(1.5))/z

return,q
end
