pro dblpt,ix,ox,last=last
;+
;procedure	dblpt	duplicates the given array points such that when
;			plotted with connecting straight-line segments,
;			shows up like a histogram.
;parameters	ix	input values (n element array)
;		ox	output values (2*n+1 element array)
;keywords	last	if set, anchors at last value (does not duplicate
;			last value).  default is to anchor at first value.
;example		[1,2,3] becomes [1,2,2,3,3] or [1,1,2,2,3]
;			IDL> a = findgen(10) & b = a^2
;			IDL> double,a,a1 & double,b,b1,/last
;			IDL> plot,a,b,linestyle=1 & oplot,a1,b1
;-

n1 = n_params(0)
if n1 lt 2 then begin
  print, 'Usage: dblpt,ix,ox,last=last'
  print, '  duplicates the intermediate values of an array' & return
endif

il = 1 & if keyword_set(last) then il = 0

in = n_elements(ix) & on = 2*in-1 & ox = replicate(ix(0),on)

h1 = indgen(in) & h2 = 2*h1 & ox(h2) = ix(h1)
h1 = indgen(in-1)+il & h2 = 2*indgen(in-1)+1 & ox(h2) = ix(h1)

return
end
