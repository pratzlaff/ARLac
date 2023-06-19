function grep,s,x,m,nocase=nocase,slide=slide, _extra=e
;+
;function	grep
;	returns the indices of all locations where a substring is
;	found within a string.  if no matches are found, returns -1L
;
;parameters
;	s	[INPUT; required] string in which to search
;		* must be scalar or 1-element array
;	x	[INPUT; required] substring to search for
;		* must be scalar or 1-element array
;	m	[OUTPUT] number of matches found
;
;keywords
;	nocase	[INPUT] if set, ignores case
;	slide	[INPUT] if set, ignores the fact that X may have
;		multiple characters (so that searching for "xx" in
;		"xxx" will return [0,1] instead of the usual [0])
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap (MIM.XII)
;-

;	usage
ok='ok' & m=0L
ns=n_elements(s) & szs=size(s) & nszs=n_elements(szs)
nx=n_elements(x) & szx=size(x) & nszx=n_elements(szx)
if ns eq 0 then ok='undefined string' else $
 if nx eq 0 then ok='undefined substring' else $
  if szs(nszs-2) ne 7 then ok='input not a string' else $
   if szx(nszx-2) ne 7 then ok='substring not a string' else $
    if ns gt 1 then ok='input must be a scalar or 1-element array' else $
     if nx gt 1 then ok='substring must be scalar or 1-element array'
if ok ne 'ok' then begin
  print,'Usage: gg=grep(s,x,m,/nocase,/slide)'
  print,'  return indices of all matches of substring'
  return,-1L
endif
ss=s(0) & xx=x(0) & ls=strlen(ss) & lx=strlen(xx)

;	keywords
if keyword_set(nocase) then begin
  ss=strlowcase(ss) & xx=strlowcase(xx)
endif
if keyword_set(slide) then lx=1

;	outputs
ii=-1L & m=0L

;	search
l=0L & i=0L
while l lt ls do begin			;{step through the string
  i=strpos(ss,xx,i)
  if i lt 0 then l=ls else begin
    if ii(0) eq -1 then ii=[i] else ii=[ii,i]
  endelse
  i=i+lx
endwhile				;L<LS}

if ii(0) ne -1 then m=n_elements(ii) else m=0L	;number of matches

return,ii
end
