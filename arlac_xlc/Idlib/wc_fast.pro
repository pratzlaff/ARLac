function wc_fast,file,word=word,char=char,h=h
;+
;FUNCTION	wc_fast
;		obtains the number of lines, words or characters in the
;		specified file, using the UNIX wc command
;
;PARAMETERS	file		name of file(s)
;				NO UNIX wildcards are allowed.
;				multiple files should be in a string array
;
;KEYWORDS	word		returns number of words
;		char		returns number of characters
;		h		help
;
;USAGE		lines = wc(files,/word,/char,/h)
;
;NOTES		if input is an array, the output is also an array, but
;		with one extra element at the end, containing the total
;		number of lines, words, or characters found.
;
;HISTORY
;	vinay kashyap (5/23/95)
;	modified from wc.pro to take advantage of /NOSHELL of spawn
;-

if n_params(0) eq 0 then h=1
opsys = !version.os
if opsys eq 'MacOS' or opsys eq 'vms' or opsys eq 'Win32' then h=1

if keyword_set(h) then begin
  print, 'Usage: lines=wc_fast(file(s),/word,/char,/h)'
  print, '  returns number of lines (or words, or characters) in given files'
  print, '  on UNIX systems'
  return,-1L
endif

cmd = 'wc' & arg = '-l
if keyword_set(word) then arg = '-w'
if keyword_set(char) then arg = '-c'

cmdlst = [cmd,arg,file]

spawn,cmdlst,oput,/noshell

val=lonarr(n_elements(oput)) & reads,format="(i10)",oput,val

return,val
end
