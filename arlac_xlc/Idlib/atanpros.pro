pro atanpros,y,x,deg,r
;given the point (x,y), obtains the angle that the line joining (x,y) and
;(0,0) makes with the +ve Y-axis.

if n_params(0) lt 3 then begin
  print, 'Usage: atanpros,y,x,deg,r'
  print, 'obtains angle made by line joining (x,y) and (0,0) with +ve Y axis'
  return
endif

xx = y & yy = -x & if xx eq 0. then xx = 1e-5

if xx ge 0. and yy ge 0. then r = atan(yy/xx)
if xx lt 0. and yy ge 0. then r = atan(yy/xx) + !pi
if xx lt 0. and yy lt 0. then r = atan(yy/xx) + !pi
if xx ge 0. and yy lt 0. then r = atan(yy/xx) + !pi*2.

deg = r*180./!pi

return
end
