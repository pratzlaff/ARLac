pro car2sph,x,y,z,r,th,ph,radian=radian
;+
;procedure	car2sph
;	converts cartesian coordinates to spherical ones
;
;parameters
;	x,y,z	[INPUT; required] cartesian coordinates
;	r,th,ph	[OUTPUT] spherical coordinates (R is required)
;
;keywords
;	radian	[INPUT] if set, THETA, PHI in radians.  degrees otherwise.
;
;subroutines
;	ARCTAN
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) lt 4 then begin
  print, 'Usage: car2sph,x,y,z,r,th,ph,[/radian]' & return
endif

rho = sqrt(x^2+y^2)
if rho eq 0. then begin
  th = 90. & ph = 0. & if keyword_set(radian) then th = !pi/2. & return
endif
r = sqrt(z^2+rho^2) & th = atan(z/rho) & arctan,x,y,ph

if z lt 0. then th = th + !pi
if not keyword_set(radian) then begin
  th = th*180./!pi & ph = ph*180./!pi
endif

return
end
