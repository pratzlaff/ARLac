function findfn,y1,x2,x1
;+
;function	findfn
;		interpolate values of irregularly spaced arrays based on
;		the values of their X-coordinates
;parameters	y1	y-coordinate values of reference function
;		x2	x-coordinate values of output array (units must
;			match that of x1)
;		x1	x-coordinate values of reference function (optional
;			input)
;keywords	none
;
;description	given an array x1 of m elements, and a function y1(x1),
;		for each value of input array x2 of n (!=m) elements,
;		calculates the function y2(x2).  first, interpolates of
;		x2 in x1 are obtained, and these interpolated values are
;		used to calculate y2.
;-

np = n_params(0)

if np eq 0 then begin
  print, 'Usage: y2 = findfn(y1,x2,x1)'
  print, '  interpolate values of irregularly spaced arrays'
  return,0L
endif

if np eq 1 then begin
  print, 'Usage: y2 = findfn(y1,x2,x1)'
  print, '  interpolate values of irregularly spaced arrays'
  return,y1
endif

if np eq 2 then begin
  print, 'assuming x2 = array position indices'
  x1 = indgen(n_elements(y1))
endif

n1 = n_elements(y1) & n2 = n_elements(x2)

nx2 = fltarr(n2) & y2 = x2 & i = -1
next: i = i + 1
x0 = x2(i) & j0 = 1 & j1 = n1-1

;---	case 1: x < min(x1) ==> y extrapolated from 1st 2 points of y1.
if x0 lt x1(0) then begin
  nx2(i) = (x0-x1(0))/(x1(1)-x1(0))
  if i ne (n2-1) then goto, next
  if i eq (n2-1) then goto, done
endif

;---	case 2: x > max(x1) ==> y extrapolated from last 2 points of y1.
if x0 gt x1(n1-1) then begin
  nx2(i) = n1-1 + (x0-x1(n1-1))/(x1(n1-1)-x1(n1-2))
  if i ne (n2-1) then goto, next
  if i eq (n2-1) then goto, done
endif

;---	case 3: min(x1) < x < max(x1) ==> y interpolated from y1.
for j = j0,j1 do begin
  if x0 le x1(j) then begin
    nx2(i) = j + (x0-x1(j))/(x1(j)-x1(j-1))
    j0 = j
    if i ne (n2-1) then begin
      if x2(i+1) lt x2(i) then begin
        j0 = 1 & j1 = j
      endif
    endif
    if i ne (n2-1) then goto,next
    if i eq (n2-1) then goto,done
  endif
endfor

done:	inx2 = fix(nx2)
for i=0,n2-1 do begin
  if inx2(i) lt 0 then y2(i) = 0.				;case 1
  if inx2(i) ge 0 then begin
    if inx2(i) ge n1-1 then begin				;case 2
      step = (nx2(i)-inx2(i))*(y1(n1-1)-y1(n1-2))
      y2(i) = y1(n1-1) + step
    endif
    if inx2(i) lt n1-1 then begin				;case 3
      step = (nx2(i)-inx2(i))*(y1(inx2(i)+1)-y1(inx2(i)))
      y2(i) = y1(inx2(i)) + step
    endif
  endif
endfor

return,y2
end
