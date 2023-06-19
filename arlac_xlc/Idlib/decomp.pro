function decomp,x,col,ncol=ncol,zil=zil
;+
;function	decomp
;		decomposes the input multi-dimensional array and returns
;		one column
;
;parameters	x	input multi-dimensional array
;		col	desired column number (default = 1)
;		zil	value to fill in undefined values (default = 0.)
;
;keywords	ncol	total number of columns expected to be encoded in x
;			(default = 2)
;
;-

n1 = n_params(0)
if n1 eq 0 then begin
  print, 'Usage: y = decomp(x,col,ncol=ncol)'
  print, '  decomposes the input multi-dimensional array into its'
  print, '  constituent columns and returns the specified column'
  return,0
endif
if n1 eq 1 then col = 1
nc = 2 & if keyword_set(ncol) then nc = ncol
z = 0. & if keyword_set(zil) then z = zil

sz = size(x)

case sz(0) of
  0: return,x
  1: begin
    case nc of
      1: if col gt 1 then val=make_array(size=sz,value=z) else val = x
      else: begin
        ;assume that x is arranged in sequence, row after row
        ;eg: [ a11, a12, a13, a21, a22, a23, a31, a32, a33, ... ]
        nl=sz(1)/nc & if nc*nl lt sz(3) then nl=nl+1 & nt=nc*nl
	h1 = nc*indgen(nl)+(col-1)
        if nt gt sz(3) then x = [x,make_array(nt-sz(3),type=sz(2),value=z)]
	if col gt nc then val = make_array(nl,type=sz(2),value=z)
	;if col le nc then val = x(nl*(col-1):nl*col-1)
	if col le nc then val = x(h1)
      end
    endcase
  end
  2: begin
    if (nc ne sz(1) and nc ne sz(2)) or col gt nc then begin
      val = make_array(sz(4)/2,type=sz(3),value=z)
    endif else begin
      if nc eq sz(1) then begin
	val = reform(x(col-1,*))
      endif else begin
	val = x(sz(1)*(col-1):sz(1)*col-1)
      endelse
    endelse
  end
  else: begin
    k = n_elements(sz)-2
    print, 'not implemented' & val = make_array(sz(1),type=sz(k),value=z)
  end
endcase

return,val
end
