pro intersect,lis1,lis2,y1y2,y1n2,n1y2,val=val,verbose=verbose, _extra=e
;+
;procedure	intersect
;		procedure to obtain common elements of two sorted numeric
;		arrays
;
;syntax
;	intersect,lis1,lis2,y1y2,y1n2,n1y2,/val,verbose=verbose
;
;parameters
;	lis1	[INPUT; required] input list #1, array
;	lis2	[INPUT; required] input list #2, array
;	y1y2	[OUTPUT; required] elements in lis1 also in lis2
;	y1n2	[OUTPUT] elements in lis1 that are not in lis2
;	n1y2	[OUTPUT] elements not in lis1 that are in lis2
;
;keywords
;	val	[INPUT] if set, returns the actual values in x1x2 rather
;		than the array position numbers
;	verbose	[INPUT] controls chatter
;	_extra	[JUNK] here only to prevent crashing the program
;
;description
;	y1y2 contains array numbers of elements of lis1 that are
;	common to both lis1 and lis2.  y1n2 contains array numbers
;	of elements of lis1 that are not in lis2.  n1y2 contains
;	array numbers of elements of lis2 that are not in lis1.
;	if y1y2/y1n2/n1y2 is empty, it is set equal to [ -1L ].
;	if keyword VAL is set, the actual array elements are returned
;	instead of array numbers, and if y1y2/y1n2/n1y2 is empty,
;	it is set equal to -!pi
;
;history
;	algorithm by mala viswanath
;	idl version by vinay kashyap (8/27/1992)
;	added keyword VAL (3/26/93)
;	added keyword VERBOSE (4/14/02)
;-

;	usage
ok='ok' & np=n_params() & n1=n_elements(lis1) & n2=n_elements(lis2)
if np lt 2 then ok='Insufficient input parameters' else $
 if n1 eq 0 then ok='LIS1 is undefined' else $
  if n2 eq 0 then ok='LIS2 is undefined' else $
   if not arg_present(y1y2) then ok='Y1Y2 absent, why bother running this?'
if ok ne 'ok' then begin
  print, 'Usage: intersect,lis1,lis2,y1y2,y1n2,n1y2,/val,verbose=verbose'
  print, '  returns common and non-common elements of 2 sorted numeric lists'
  if np ne 0 then message,ok,/info
  return
endif

;	keywords
getval = 0 & if keyword_set(val) then getval = 1
vv = 0 & if keyword_set(verbose) then vv=long(verbose(0)) > 1

y1y2 = [ -1L ] & y1n2 = y1y2 & n1y2 = y1y2
if getval then y1y2 = y1y2*!pi & if getval then y1n2 = y1n2*!pi
if getval then n1y2 = n1y2*!pi

i = 0 & j = 0 & k = 0 & i1 = 0 & i2 = 0

if vv gt 0 then begin
  print,'# elements in LIS1: '+strtrim(n1,2)
  print,'# elements in LIS2: '+strtrim(n2,2)
endif

;first, get y1y2
i = 0 & i1 = 0 & i2 = 0
while i1 lt n1 and i2 lt n2 do begin
  if vv gt 5 and i eq 1000L*long(i/1000) then print,form="($,a)",'.'
  x = lis1(i1) - lis2(i2)
  case 1 of
    x lt 0: i1=i1+1L
    x gt 0: i2=i2+1L
    else: begin
      if i eq 0 and getval eq 0 then y1y2 = [ i1 ]
      if i eq 0 and getval eq 1 then y1y2 = [ lis1(i1) ]
      if i gt 0 and getval eq 0 then y1y2 = [y1y2,i1]
      if i gt 0 and getval eq 1 then y1y2 = [y1y2,lis1(i1)]
      i1=i1+1L & i2=i2+1L & i=i+1L
    end
  endcase
endwhile
if vv gt 2 then message,'Y1Y2: done',/info

if np eq 3 then return
;now, get y1n2
i=0 & i1 = 0 & i2 = 0 & flag = 1
while flag do begin
  if vv gt 5 and i eq 100L*long(i/100) then print,form="($,a)",strtrim(i,2)
  x = lis1(i1) - lis2(i2)
  case 1 of
    x eq 0: begin
      i1=i1+1L & i2=i2+1L
    end
    x lt 0: begin
      if i eq 0 and getval eq 0 then y1n2 = [ i1 ]
      if i eq 0 and getval eq 1 then y1n2 = [ lis1(i1) ]
      if i gt 0 and getval eq 0 then y1n2 = [y1n2,i1]
      if i gt 0 and getval eq 1 then y1n2 = [y1n2,lis1(i1)]
      i1=i1+1L & i=i+1L
    end
    else: i2=i2+1L
  endcase
  if i2 eq n2 and i1 lt n1 then begin
    flag = 0
    if i eq 0 and getval eq 0 then y1n2 = indgen(n1)
    if i eq 0 and getval eq 1 then y1n2 = lis1
    if i gt 0 and getval eq 0 then y1n2 = [y1n2,indgen(n1-i1)+i1]
    if i gt 0 and getval eq 1 then y1n2 = [y1n2,lis1(i1:*)]
  endif
  if i1 eq n1 then flag = 0
endwhile
if vv gt 2 then message,'Y1N2: done',/info

if np eq 4 then return
;finally, get n1y2
i=0 & i1 = 0 & i2 = 0 & flag = 1
while flag do begin
  if vv gt 5 and i eq 100L*long(i/100) then print,form="($,a)",strtrim(i,2)
  x = lis2(i2) - lis1(i1)
  case 1 of
    x eq 0: begin
      i2=i2+1L & i1=i1+1L
    end
    x lt 0: begin
      if i eq 0 and getval eq 0 then n1y2 = [ i2 ]
      if i eq 0 and getval eq 1 then n1y2 = [ lis2(i2) ]
      if i gt 0 and getval eq 0 then n1y2 = [n1y2,i2]
      if i gt 0 and getval eq 1 then n1y2 = [n1y2,lis2(i2)]
      i2=i2+1L & i=i+1L
    end
    else: i1=i1+1L
  endcase
  if i1 eq n1 and i2 lt n2 then begin
    flag = 0
    if i eq 0 and getval eq 0 then n1y2 = indgen(n1)
    if i eq 0 and getval eq 1 then n1y2 = lis2
    if i gt 0 and getval eq 0 then n1y2 = [n1y2,indgen(n2-i2)+i2]
    if i gt 0 and getval eq 1 then n1y2 = [n1y2,lis2(i2:*)]
  endif
  if i2 eq n2 then flag = 0
endwhile
if vv gt 2 then message,'N1Y2: done',/info

return
end
