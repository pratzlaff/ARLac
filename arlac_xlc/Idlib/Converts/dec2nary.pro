pro dec2nary,dec,num,binary=binary,octal=octal,hex=hex
;+
;procedure	dec2nary,dec,num
;		converts dec from decimal to n-ary base
;parameters	dec	corresponding decimal number
;		num	n-ary number or string
;keywords	binary	output is in binary notation
;		octal	output is in octal notation
;		hex	output is in hexadecimal notation
;-

n1 = n_params(0)
if n1 eq 0 then begin
  print, 'Usage: dec2nary,dec,num,/binary,/octal,/hex'
  print, '  converts number in decimal to n-ary notation'
  return
endif

if keyword_set(binary) then begin
  base = 2.
endif
if keyword_set(octal) then begin
  base = 8.
endif
if keyword_set(hex) then begin
  base = 16.
endif

dvsor = dec & num = ''
while (dvsor ge base) do begin
  rmndr = dvsor - base*fix(dvsor/base)
  dvsor = fix(dvsor/base) & rmndr = fix(rmndr) & rmndr = strtrim(rmndr,2)
  if keyword_set(hex) then begin
    if rmndr eq '10' then rmndr = 'a'
    if rmndr eq '11' then rmndr = 'b'
    if rmndr eq '12' then rmndr = 'c'
    if rmndr eq '13' then rmndr = 'd'
    if rmndr eq '14' then rmndr = 'e'
    if rmndr eq '15' then rmndr = 'f'
  endif
  num = rmndr + num
endwhile
dvsor = strtrim(dvsor,2)
if keyword_set(hex) then begin
  if dvsor eq '10' then dvsor = 'a'
  if dvsor eq '11' then dvsor = 'b'
  if dvsor eq '12' then dvsor = 'c'
  if dvsor eq '13' then dvsor = 'd'
  if dvsor eq '14' then dvsor = 'e'
  if dvsor eq '15' then dvsor = 'f'
endif
num = dvsor + num

if n1 eq 1 then print, num

return
end
