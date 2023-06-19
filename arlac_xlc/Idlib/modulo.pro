function modulo,a,b
;+
;function	modulo
;		returns x = A mod(B)
;
;parameters	a
;		b
;
;keywords	none
;
;restrictions
;	if A and B are arrays, their sizes MUST match
;	A and B should be +ve
;	B MUST be > 0
;							vinay kashyap (1/23/94)
;-

np = n_params(0)
if np lt 2 then begin
  print, 'Usage: x = modulo(a,b)'
  print, '  returns the modulus of A wrt B' & return,0L
endif

;case 1: A and B are both scalar
;case 2: A is a vector, B is scalar
;case 3: A is scalar, B is a vector
;case 4: A and B are both vectors

sza = size(a) & szb = size(b) & na = 1 & nb = 1 & icase = 0
if sza(0) eq 0 and szb(0) eq 0 then icase = 1
if sza(0) eq 1 and szb(0) eq 0 then icase = 2
if sza(0) eq 0 and szb(0) eq 1 then icase = 3
if sza(0) eq 1 and szb(0) eq 1 then icase = 4

c1 = 'sorry, MODULO.PRO cannot handle multi-D arrays'
if icase eq 0 then begin & print, c1 & return,a & endif

if icase eq 2 or icase eq 4 then na = sza(1)
if icase eq 3 or icase eq 4 then nb = szb(1)
c1 = 'MODULO: A and B must be of the same length'
if icase eq 4 and na ne nb then begin & print,c1 & return,a & endif

if icase eq 1 or icase eq 2 then begin
  y = float(a)/float(b) & x = a & h1 = [-1]
  if icase eq 1 then begin
    if y ge 1. then x = a - fix(y)*b
  endif
  if icase eq 2 then begin
    h1 = where(y ge 1.) & if h1(0) ne -1 then x(h1) = a(h1) - fix(y(h1))*b
  endif
endif

if icase eq 3 or icase eq 4 then begin
  x = float(a)/float(b) & h1 = where(x ge 1.) & h2 = where(x lt 1.)
  if icase eq 3 then begin
    if h1(0) ne -1 then x(h1) = a - fix(x(h1))*b(h1)
    if h2(0) ne -1 then x(h2) = 0*b(h2) + a
  endif
  if icase eq 4 then begin
    if h1(0) ne -1 then x(h1) = a(h1) - fix(x(h1))*b(h1)
    if h2(0) ne -1 then x(h2) = a(h2)
  endif
endif

return,x
end
