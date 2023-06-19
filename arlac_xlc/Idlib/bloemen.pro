pro bloemen,b,nh1,nh2,dist
;+
;calculates the HI & H2 column densities to a preset distance using the 3
;component model of Bloemen, J.B.G.M., 1987, ApJ, 322, 694 for the given
;latitude.
;
;cold HI:	n(z)   = 0.30*exp(-0.5*(z/135)^2) cm^-3
;warm HI:	n(z)   = 0.07*exp(-0.5*(z/135)^2) + 0.1*exp(-z/400) cm^-3
;molecular H2:	nh2(z) = 0.30*exp(-0.5*(z/70)^2)
;
;parameters:	b	galactic latitude [degrees]
;		nh1	column density of HI [/cm^2]
;		nh2	molecular H column density [/cm^2]
;		dist	limiting distance (optional) [pc]
;
;usage:		bloemen,b,nh1,nh2[,dist]
;
;-

if n_params(0) eq 0 then begin
  print, 'Usage: bloemen,b,nh1,nh2[,dist]'
  print, '  Obtains HI & H2 column densities according to Bloemen model
  print, '  of gas distribution in the Galaxy'
  return
endif

if b lt 0. then b = -b & sinb = sin(!pi*b/180.)
if b ne 0. then r = 8000./sinb else r = 20000.
if n_params(0) eq 4 then r = dist

alpha = sinb/(135.*sqrt(2.)) & beta = sinb/400.
alfa2 = sinb/(70.*sqrt(2.))  & bet2 = sinb/128.

nexp = (0.1/beta)*(1.-exp(-r*beta))
ngauss = (0.37*sqrt(!pi)/(alpha*2.))*errorf(alpha*r)
nh2 = (0.3*sqrt(!pi)/(alfa2*2.))*errorf(alfa2*r)*3.1d18
nh1 = (ngauss + nexp)*3.1d18

return
end
