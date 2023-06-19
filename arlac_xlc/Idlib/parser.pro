pro parser,line,sep,wrds,last=last
;+
;procedure	parser,line,sep,wrds,last=last
;		given a string [line], and a 'separator' [sep], comes out with
;		a string array of 'words' separated by the given separator
;parameters	line:	input string
;		sep:	input separator (eg: ' ', '|', etc)
;		wrds:	output string array containing all the pieces
;keywords	last:	if set, assumes that the last character in line is sep
;-

if n_params(0) lt 3 then begin
  print, 'Usage: parser,line,sep,words'
  print, '  breaks a given character string into pieces separated by sep'
  return
endif

charr = line & c1 = strmid(charr,0,1) & linlen = strlen(charr)

;search and identify the positions of all the separators
nh = 0 & h1 = [ -1 ]
for i=0,linlen-1 do begin
  c1 = strmid(charr,i,1)
  if c1 eq sep then begin
    if nh eq 0 then h1 = [ i ]
    if nh gt 0 then h1 = [h1,i]
    nh = nh + 1
  endif
endfor

;break up line into pieces
i0 = 0 & nw = nh+1 & if keyword_set(last) then nw = nh & wrds = strarr(nw)
if h1(0) ne -1 then begin
  for i=0,nh-1 do begin
    len = h1(i) - i0 & c1 = strmid(charr,i0,len)
    if c1 ne '' then begin
      wrds(i) = c1
    endif
    i0 = h1(i) + 1
  endfor
  if not keyword_set(last) then begin
    len = linlen - i0
    c1 = strmid(charr,i0,len)
    if c1 ne '' then begin
      wrds(nh) = c1
    endif
  endif
endif else wrds = [ charr ]

return
end
