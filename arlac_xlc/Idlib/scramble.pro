function scramble,arr,seed=seed, _ref_extra=ex
;+
;function	scramble
;	returns the input array elements in random order
;
;parameters
;	arr	[INPUT; required] input to be scrambled
;
;keywords
;	seed	[I/O] randomizer seed
;	_ref_extra	[JUNK] here only to stop crashing the program
;
;history
;	vinay kashyap (mar99)
;	changed algorithm (VK; 99jul)
;-

;	usage
n=n_elements(arr)
if n le 1 then begin
  print,'Usage: rra=scramble(arr,seed=seed)'
  print,'  return the elements of array in scrambled order'
  if n eq 0 then return,-1L else return,arr
endif

r=randomu(seed,n)
ir=sort(r)
rra=arr(ir)

;{VK:	ugh.  this is what the algorithm used to be..
;
;;	initialize
;ir=lindgen(n) & jr=intarr(n) & kr=lonarr(n)-1L
;;	scramble
;nn=long(n*(n+1.)/2.) & rr=randomu(seed,nn) & k=0L
;for i=0L,n-1L do begin
;  oo=where(jr eq 0,moo)
;  ii=long(rr(k)*moo)
;  kr(oo(ii))=ir(i)
;  jr(oo(ii))=1
;  k=k+1L
;endfor
;rra=arr(kr)
;VK:	..not pretty, nu?}

return,rra
end
