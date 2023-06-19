pro agram,s
;+
;function anagram
;	generates anagrams of input string
;
;parameters
;	s	[INPUT; required] base string
;
;keywords	NONE
;
;history
;	vinay kashyap (mar99)
;-

;	usage
n=n_elements(s)
if n eq 0 then begin
  print,'Usage: anagram,string'
  print,'  generates anagrams of string'
  return
endif

;	check input
ss=string(s(0))
if n gt 1 then for i=1,n-1 do ss=ss+string(s(i))	;concatenate an array

;	break up into bits
sb=byte(ss) & ns=n_elements(sb)

c=''
while c ne 'q' do begin
  ir=indgen(ns) & ir=scramble(ir)
  print,ss+': '+string(sb(ir))+'  (q to quit)'
  c=get_kbrd(1)
endwhile

end
