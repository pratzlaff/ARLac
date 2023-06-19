function arctan,y,x,radn=radn
;+
;function	arctan
;		given the point (x,y), obtains the angle that the line
;		joining (x,y) and (0,0) makes with the +ve X-axis.
;
;parameters	y	value of y coordinate
;		x	value of x coordinate
;
;keywords	radn	if set, output is in radians
;-

if n_params(0) lt 2 then begin
  print, 'Usage: z = arctan(y,x,/radn)'
  print, '  obtains angle made by line joining (x,y) and (0,0) with +ve X-axis'
  return,0.
endif

if x eq 0. then x = 1e-32

if x ge 0. and y ge 0. then ang = atan(y/x)
if x lt 0. and y ge 0. then ang = atan(y/x) + !pi
if x lt 0. and y lt 0. then ang = atan(y/x) + !pi
if x ge 0. and y lt 0. then ang = atan(y/x) + !pi*2.

if not keyword_set(radn) then ang = ang*180./!pi

return,ang
end
