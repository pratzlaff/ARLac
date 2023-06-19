pro posalfbt,c1,pos
;+
;procedure	posalfbt,c1,pos
;		gives the position of an alphabet.
;parameters	c1	letter
;		pos	position in the alphabet list (1-26)
;-

if n_params(0) lt 2 then begin
  print, 'Usage: posalfbt,c1,pos'
  print, 'gives the position of an alphabet [eg: a=1, z=26, etc]'
  return
endif

alfbt = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',$
	  'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',$
	  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',$
	  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' ]

pos = where(c1 eq alfbt) & pos = pos(0) & pos = pos+1

if pos gt 26 then pos = pos-26

done:

return
end
