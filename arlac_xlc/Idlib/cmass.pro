function cmass,img
;+
;function	cmass
;		returns the array coordinates of the center of 'mass' of
;		the given image
;
;parameters	img	input image
;
;keywords	none
;
;restrictions
;	img should not be complex
;	cannot handle more than 3D
;	uses too many for loops for comfort.
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: cpos = cmass(img)'
  print, '  returns array coordinates of center of mass of img'
  return,-1L
endif

sz = size(img)
ndim = sz(0) & if ndim eq 0 then return,img		;return if img is scalar

if ndim eq 1 then begin
  nx = sz(1) & x = findgen(nx)+1.
  xcen = total(x*img)/total(img)
  return, [xcen]
endif

if ndim eq 2 then begin
  nx = sz(1) & ny = sz(2) & x = findgen(nx)+1. & y = findgen(ny)+1.
  xcen = 0. & ycen = 0.
  for i=0,ny-1 do xcen = xcen + total(x*img(*,i))
  for i=0,nx-1 do ycen = ycen + total(y*img(i,*))
  norm = total(img) & cpos = [xcen,ycen]/norm
  return,cpos
endif

if ndim eq 3 then begin
  nx = sz(1) & ny = sz(2) & nz = sz(3)
  x = findgen(nx)+1. & y = findgen(ny)+1. & z = findgen(nz)+1.
  xcen = 0. & ycen = 0. & zcen = 0.
  for i=0,nz-1 do begin
    for j=0,ny-1 do xcen = xcen + total(x*img(*,j,i))
    for j=0,nx-1 do ycen = ycen + total(y*img(j,*,i))
  endfor
  for i=0,nx-1 do begin
    for j=0,ny-1 do zcen = zcen + total(z*img(i,j,*))
  endfor
  norm = total(img) & cpos = [xcen,ycen,zcen]/norm
  return,cpos
endif

return,img
end
