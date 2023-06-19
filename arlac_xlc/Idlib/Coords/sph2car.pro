pro sph2car,r,th,ph,x,y,z,radian=radian
;+
;procedure	sph2car
;	converts spherical coordinates to cartesian ones
;
;parameters
;	r,th,ph	[INPUT; required] spherical coordinates
;	x,y,z	[OUTPUT] cartesian coordinates (X is required)
;
;keywords
;	radian	[INPUT] if set, assumes that theta and phi are given
;		in radians.  degrees otherwise
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) lt 4 then begin
  print, 'Usage: sph2car,r,theta,phi,x,y,z[,/radian]' & return
endif

tht = th & phi = ph
if not keyword_set(radian) then begin
  tht = tht*!pi/180. & phi = phi*!pi/180.
endif

costh = cos(tht) & sinth = sin(tht) & cosph = cos(phi) & sinph = sin(phi)

x = r*sinth*cosph
y = r*sinth*sinph
z = r*costh

return
end
