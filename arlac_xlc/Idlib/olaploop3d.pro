pro olaploop3d,x0,y0,z0,xb,yb,zb,R,rcs,scale,f,thmin,thmax
;+
;--------------------------------------------------------------------------
;---input:  box with center at (x0,y0,z0) and sides (xb,yb,zb),
;---        cylindrical loop of radius R and radius of cross section rcs,
;---	    and with base at (+-R,0,0) and apex at (0,0,R).
;---	    a scale factor to reduce floating point over/underflows (scale)
;---output: fraction of the volume of the box that overlaps the loop (f)
;---	    range of aspect angles of that part of the loop that overlaps
;---	    the box [thmin,thmax].
;--------------------------------------------------------------------------


;---initialization:
	numhit = 5000 & thmin = 0. & thmax = !pi/2

;---scale everything to manageable magnitudes, viz., approximate box units:
	bx = xb/scale & by = yb/scale & bz = zb/scale
	xa = x0/scale & ya = y0/scale & za = z0/scale
	rlp = R/scale & rad = rcs/scale

;---first take care of simple cases

;---(1) box "way" outside loop.
	maxdim = sqrt(bx^2+by^2+bz^2)
	dpt = sqrt(xa^2+ya^2+za^2)
	if dpt+maxdim/2 lt rlp-rad then begin
	  ;print, 'box WAY outside loop'
	  f = 0. & return
	endif

;---(2) box obviously outside loop.
	cx = fltarr(8) & cy = cx & cz = cx & hit = 0
	cx(0) = xa + bx/2. & cx(1) = cx(0) & cx(2) = cx(0) & cx(3) = cx(0)
	cx(4) = xa - bx/2. & cx(5) = cx(4) & cx(6) = cx(4) & cx(7) = cx(4)
	cy(0) = ya + by/2. & cy(1) = cy(0) & cy(4) = cy(0) & cy(5) = cy(0)
	cy(2) = ya - by/2. & cy(3) = cy(2) & cy(6) = cy(2) & cy(7) = cy(2)
	cz(0) = za + bz/2. & cz(2) = cz(0) & cz(4) = cz(0) & cz(6) = cz(0)
	cz(1) = za - bz/2. & cz(3) = cz(1) & cz(5) = cz(1) & cz(7) = cz(1)
;---	loop edge points are (0/[rlp+rad],+/-rad,0/[rlp+rad])
	if cx(0) gt rlp+rad and cx(4) gt rlp+rad then hit = 1
	if cx(0) lt 0.      and cx(4) lt 0.      then hit = 1
	if cy(0) gt rad     and cy(2) gt rad     then hit = 1
	if cy(0) lt -rad    and cy(2) lt -rad    then hit = 1
	if cz(0) gt rlp+rad and cz(1) gt rlp+rad then hit = 1
	if cz(0) lt 0.      and cz(1) lt 0.      then hit = 1
	if hit ne 0 then begin
	  ;print, 'box outside loop'
	  f = 0. & return
	endif

;---(3) box fully inside loop.
	lx = rlp*cx/sqrt(cx^2+cz^2) & lz = rlp*cz/sqrt(cx^2+cz^2)
	cd = sqrt( (cx-lx)^2 + cy^2 + (cz-lz)^2 ) & hit = where(cd gt rad)
;---	account for the fact that the loop terminates at z=0:
	for i=0,7 do if cz(i) lt 0 then hit(0) = 1
	if hit(0) eq -1 then begin
	  ;print, 'box inside loop'
	  z1 = abs(za)-bz/2. & x1 = abs(xa)+bx/2.
	  z2 = abs(za)+bz/2. & x2 = abs(xa)-bx/2.
	  if x1 eq 0. then thmin = !pi/2.
	  if x2 eq 0. then thmax = !pi/2.
	  if x1 ne 0. then thmin = atan( z1/x1 )
	  if x2 ne 0. then thmax = atan( z2/x2 )
	  f = 1. & return
	endif

;---ok, now you need brute force.
	rx = xa + bx * (2.*randomu(seed,numhit)-1.) / 2.
	ry = ya + by * (2.*randomu(seed,numhit)-1.) / 2.
	rz = za + bz * (2.*randomu(seed,numhit)-1.) / 2.
	rxz = sqrt(rx^2+rz^2)
	rlx = rlp*rx/rxz & rlz = rlp*rz/rxz
	rd1 = sqrt( (rx-rlx)^2 + ry^2 + (rz-rlz)^2 )
;---	account for the fact that the loop terminates at z=0:
	hit = where(rz lt 0) & if hit(0) ne -1 then rd1(hit) = 2.*rad
	hit = where(rd1 le rad) & count = 0
	if hit(0) ne -1 then begin
	  count = n_elements(hit)
	  thmin = acos(max(rx(hit)/rxz(hit)))
	  thmax = acos(min(rx(hit)/rxz(hit)))
	endif
	f = float(count)/float(numhit)

	return
	end
