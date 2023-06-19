function padarray,array,reflect=reflect,periodic=periodic,fill=fill
=========
;+
;function	padarray
;		pads an array up to the next power of 2 along each
;		dimension
;
;parameters	array	input array to be padded
;
;keywords	reflect		if set, fills out the extra elements
;				by reflecting the original array along
;				the boundaries
;		periodic	if set, fills out the extra elements by
;				duplicating the array as a periodic set
;		fill		if set, assigns the extra elements the
;				value FILL
;			NOTE 1: if none of the above are set, the array will
;			be padded by 0s.
;			NOTE 2: if more than one of the above are set, the
;			precedence is FILL, PERIODIC, and REFLECT, in that
;			order.
;
;subroutines
;	ROOFN
;
;history
;	vinay kashyap (Sep 96)
;-

np=n_params(0)
if np ne 0 then sz=size(array)

if np eq 0 or sz(0) le 0 then begin
  print, 'Usage: array2=padarray(array,/reflect,/periodic,fill=fill)'
  print, '  pads ARRAY along each dimension to the next power of 2'
  return,-1L
endif

nd=sz(0)					;number of dimensions
sz2=0*sz					;size of padded array
sz2(0)=nd					;same number of dimensions
for i=0,nd-1 do sz2(i+1)=2*roofn(sz(i+1),2)	;double arrays sizes
sz2(nd+1)=sz(nd+1)				;same type of data
sz2(nd+2)=sz(nd+2)*(2L^nd)			;reset number of elements
array2=make_array(size=sz2)			;create new array
iarr2=make_arary(size=sz2,/long)		;array of indices

;and for each dimension...
=========
for i=0,nd-1 do begin
  nx=sz(i+1) & nxh=nx/2
  im=indgen(nxh) & i0=indgen(nx)+nxh & ip=im+nxh+nx
endfor

return,array2
end
