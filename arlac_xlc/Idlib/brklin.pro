pro brklin,line,wrds,dot=dot,bracket=bracket
;+
;procedure	brklin,line,wrds,dot=dot,bracket=bracket
;		line is a character string which is broken up into words
;		separated by the designated marks.
;parameters	line:	input string
;		wrds:	string array containing all words
;keywords	dot:	if set, a period (.) is treated as a word separator
;		bracket:if set, brackets ((,),[,],{,}) are treated as word
;			separators.
;the output will NOT contain the word separators
;-

if n_params(0) lt 2 then begin
  print, 'Usage: brklin,line,wrds,dot=dot,bracket=bracket'
  print, '  breaks a given character string into words'
  return
endif

;first define all the word separators
wsep = [',', ';', ':', '!', '	'] & charr = line
if keyword_set(bracket) then wsep = [wsep, '(',')','[',']','{','}']
if keyword_set(dot) then wsep = [wsep, '.']
np = n_elements(wsep)

;set all the word separators to ' '
for i=0,np-1 do begin
  c1 = wsep(i) & h1 = strpos(charr,c1,0)
  if h1(0) ne -1 then begin
    for j=0,n_elements(h1)-1 do begin
      i1 = h1(j) & strput,charr,' ',i1
    endfor
  endif
endfor

charr = strcompress(charr) & c1 = strmid(charr,0,1) & linlen = strlen(charr)
if c1 eq ' ' then charr = strmid(charr,1,linlen-1) & linlen = strlen(charr)

;search and identify the positions of all the word separators
nh = 0 & h1 = [ -1 ]
for i=0,linlen-1 do begin
  c1 = strmid(charr,i,1)
  if c1 eq ' ' then begin
    if nh gt 0 then h1 = [h1,i]
    if nh eq 0 then h1 = [ i ]
    nh = nh + 1
  endif
endfor

;break up line into words
i0 = 0 & wrds = strarr(nh+1)
if h1(0) ne -1 then begin
  for i=0,nh-1 do begin
    len = h1(i) - i0 & c1 = strmid(charr,i0,len)
    if c1 ne '' then begin
      wrds(i) = c1
    endif
    i0 = h1(i) + 1
  endfor
  len = linlen - i0
  c1 = strmid(charr,i0,len)
  if c1 ne '' and c1 ne ' ' then begin
    wrds(nh) = c1
  endif
endif else wrds = [ line ]

hsp = where(wrds ne '' and wrds ne ' ')
if hsp(0) ne -1 then begin
  wrds = wrds(hsp)
endif else wrds = [ line ]

return
end
