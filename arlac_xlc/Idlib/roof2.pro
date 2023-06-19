function roof2,n,floor=floor,pwr=pwr
;+
;function	roof2
;		returns the next integer that is a power of 2
;
;parameters	n	(input) integer for which the next power of 2 is needed
;
;keywords	floor	if set, returns the largest integer < n that is a
;			power of 2.
;			if NOT set, returns the smallest integer > n that is a
;			power of 2.
;		pwr	(output) the appropriate index [2^(PWR)]
;
;history
;	vinay kashyap (April 1995)
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: nroof = roof2(n,pwr=pwr) & nfloor = roof2(n,/floor,pwr=pwr)'
  print, '  returns an integer next to N which is a power of 2'
  return,0L
endif

nn = long(abs(n))

if nn ge 2L^30 or nn lt 0 then begin
  print, 'sorry, IDL cannot handle such large numbers' & pwr=30 & return,n
endif

n0 = 1L & k = 0 & diff = nn-n0

while diff gt 0 do begin
  k = k + 1 & n0 = n0*2 & diff = nn-n0
endwhile
pwr = k

if keyword_set(floor) then n0 = n0/2
if keyword_set(floor) then pwr = pwr-1

return,n0
end
