	pro monteint,lx,ly,a,b,dx,dy,f
;+
;---this procedure calculates the fraction,f of the area of an ellipse
;---(with semi-axes a & b, and centered at (dx,dy)) that overlaps a box
;---(with sides 2*lx & 2*ly and centered at (0,0)) by a method that for
;---some reason reminds me of monte-carlo integration.
;---the ellipse is always oriented with axes parallel to the x- & y-axes.

;---initialization:
	numhit = 10000. & flag = 0
;---first take care of simple cases
;---(i) ellipse "way" outside box.
	if (abs(lx) + a) lt abs(dx) or (abs(ly) + b) lt abs(dy) then begin
	  f = 0.
	  return
	endif
;---(ii) box fully inside ellipse
	sc = fltarr(4) & llx = sc & lly = sc
	llx(0) = lx & llx(1) =  lx & llx(2) = -lx & llx(3) = -lx
	lly(0) = ly & lly(1) = -ly & lly(2) =  ly & lly(3) = -ly
	sc = ((llx-dx)/a)^2 + ((lly-dy)/b)^2
	simple = n_elements(where(sc le 1.))
	if simple eq 4 then begin
	  f = 1.
	  return
	endif
;---(iii) all corners of box outside ellipse
	simple = n_elements(where(sc gt 1.))
	if simple eq 4 then begin
;---ellipse enclosed by box
	  f = !pi*a*b / (4.*lx*ly)
;---ellipse outside box, but not taken care of by case (i)
	  if dx gt  lx or dy gt  ly then f = 0.
	  if dx gt  lx or dy lt -ly then f = 0.
	  if dx lt -lx or dy gt  ly then f = 0.
	  if dx lt -lx or dy lt -ly then f = 0.
;---box corners outside, but overlap isn't perfect
	  if 2*a gt 2*abs(lx) or 2*b gt 2*abs(ly) then goto,force
	  return
	endif

force:	;---ok, now you need brute force.
	rx = lx * ( 2.*randomu(seed,numhit) - 1.)
	ry = ly * ( 2.*randomu(seed,numhit) - 1.)
;---for the case when the ellipse is so thin that the sampling is bad:
	if a lt abs(lx) and a + abs(dx) le abs(lx) then begin
	  flag = 1 & astore = a & a = abs(lx) - abs(dx)
	endif
	rs = ((rx-dx)/a)^2 + ((ry-dy)/b)^2
	count = float( n_elements(where(rs le 1.)) )
	f = count/numhit
	if flag ne 0 then begin
	  f = f*(astore/a) & a = astore & flag = 0
	endif
	return

	end
