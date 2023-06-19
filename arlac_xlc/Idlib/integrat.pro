pro integrat,y,x,n,x0,x1,intydx
;+
;___pro integrat,y,x,n,x0,x1,intydx
;___purpose in life: to integrate the function y(x) from x0 to x1.
;___intydx = int from x0 to x1 y * delta(x)
;___x is an array of n numbers, NOT spaced regularly.
;___the integration is by simple quadrature.
;-

	intydx = 0. & i0 = 0 & i1 = -1

	for i=0,n-1 do begin
	  if x0 ge x(i) then i0 = i
	  if x1 ge x(i) then i1 = i
	  if x1 lt x(i) then goto, out1
	endfor

out1:	if i1 lt 0 then return			;y(x) = 0 for x < x(0)

	if x0 ge x(n-1) then begin		;extrapolate
	  xa = x0 & xb = x1
	  ya = y(n-1) + (xa-x(n-1))*(y(n-1)-y(n-2))/(x(n-1)-x(n-2))
	  yb = y(n-1) + (xb-x(n-1))*(y(n-1)-y(n-2))/(x(n-1)-x(n-2))
	  dx = abs(xa-xb) & dy = ya-yb
	  intydx = 0.5*dx*dy + dx*yb
	  return
	endif

	if x0 eq x(i0) then begin
	  xa = x(i0) & ya = y(i0)
	endif
;---if lower integration limit does not coincide with x(i0), then
;---interpolate for y:
	if x0 ne x(i0) then begin
	  if x0 lt x(0) then begin
	    xa = x(0) & ya = y(0)
	  endif
	  if x0 gt x(i0) then begin
	    xa = x0
	    ya = y(i0) + (xa-x(i0))*(y(i0+1)-y(i0))/(x(i0+1)-x(i0))
	  endif
	endif

;---integrate:
	for i=i0+1,i1 do begin
	  xb = x(i) & yb = y(i)
	  dx = abs(xa-xb) & dy = ya-yb
	  intydx = 0.5*dx*dy + dx*yb + intydx
	  xa = xb & ya = yb
	endfor

;---if upper integration limit does not coincide with x(i1), then
;---interpolate/extrapolate for y:
	if x1 ge x(i1) and i1 lt n-1 then begin
	  xb = x1
	  yb = y(i1) + (xb-x(i1))*(y(i1+1)-y(i1))/(x(i1+1)-x(i1))
	  dx = abs(xa-xb) & dy = ya-yb
	  intydx = intydx + 0.5*dx*dy + dx*yb
	  return
	endif
	if x1 ge x(n-1) then begin
	  xb = x1
	  yb = y(n-1) + (xb-x(n-2))*(y(n-1)-y(n-2))/(x(n-1)-x(n-2))
	  dx = abs(xa-xb) & dy = ya-yb
	  intydx = intydx + 0.5*dx*dy + dx*yb
	  return
	endif

	print, 'hullo? this region is supposed to be sacrosanct!'
	stop
	end
