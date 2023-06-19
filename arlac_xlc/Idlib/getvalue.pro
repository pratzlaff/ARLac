function getvalue,prmpt,x0,xr,d=d,l=l,i=i,b=b,com=com,ch=ch
;+
;FUNCTION	getvalue
;		returns value of variable in foolproof manner
;
;PARAMETERS	prmpt	prompt for variable
;		x0	default value (optional input)
;		xr	2-element array defining the valid range of x:
;			[x_low,x_high]. (optional)
;			if input lies outside the given bounds, prompts for
;			value ONCE more.
;
;KEYWORDS	d	x is taken to be double (default: real)
;		l	x is taken to be a long integer
;		i	x is taken to be integer*2
;		b	x is taken to be integer*1
;		com	x is taken to be complex
;		ch	if set, x is taken to be a character string, and
;			no attempt to obtain its numeric value is made.
;			(default is for x to be real)
;
;USAGE		x = getvalue(prmpt,[x0,[xr]][,/d|,/l|,/i|,/b|,/com|,/ch])
;
;RESTRICTIONS
;		range is not checked for complex and charcter inputs
;		does not check if the default is of the right type
;
;EXAMPLES
;	print, getvalue('type a character','z',/ch)
;	x0 = !pi & print, getvalue('type a real number',x0)
;	print, getvalue('type a long integer',200068,/l)
;	print, getvalue('type an integer',0,/i)
;	print, getvalue('type a short integer',0,[0,2],/b)
;
;						-- vinay kashyap (3/23/93)
;-

on_error,2

c1 = '' & n1 = n_params(0) & type = 0 & chkrng = 1 & chkdef = 1
d1 = string("12b) & d2 = string("15b) & d3 = ' ' & d4 = ''
conv = [ 'float','double','long','fix','byte','complex','string' ]

if n1 lt 3 then chkrng=0
if n1 lt 2 then chkdef=0 
if n1 lt 1 then prmpt = 'type value of variable'

if keyword_set(d) then type=1
if keyword_set(l) then type=2
if keyword_set(i) then type=3
if keyword_set(b) then type=4
if keyword_set(com) then type=5
if keyword_set(ch) then type=6

if not chkdef then begin
  x0 = 0 & if type eq 6 then x0 = 'n'
  x0 = call_function(conv(type),x0)
endif
prmpt = prmpt + ' {' + strtrim(x0,2) + '}'
if not chkrng then begin
  if type eq 0 then begin & xr=(2.^127-1.)*[-1.,1.] & chkrng=1 & endif
  if type eq 2 then begin & xr=[2L^31,2L^31-1] & chkrng=1 & endif
  if type eq 3 then begin & xr=[2^15,2^15-1] & chkrng=1 & endif
  if type eq 4 then begin & xr=[0,255] & chkrng=1 & endif
endif
if type eq 5 or type eq 6 then chkrng = 0

print, form="($,a,'"+prmpt+"')",string("15b) & read,c1

if c1 ne d1 and c1 ne d2 and c1 ne d3 and c1 ne d4 then begin
  ;if input non-trivial value then
  if chkrng then begin
    ;if bounds are set then
    y = double(c1)
    if y lt xr(0) or y gt xr(1) then begin
      ;if value lies outside bounds then
      c1 = 'valid range is ['+strtrim(xr(0),2)+':'+strtrim(xr(1),2)+']; {'+$
	strtrim(y,2)+'}'
      format = "($,a,'"+c1+"')" & print, form=format,string("15b)
      read,c1
      if c1 ne d1 and c1 ne d2 and c1 ne d3 and c1 ne d4 then begin
	;if non-trivial input then
	x = call_function(conv(type),c1)
      endif else begin
	;else ok, warned ya
	x = call_function(conv(type),y)
      endelse
    endif else begin
      ;else value within bounds? ok.
      x = call_function(conv(type),y)
    endelse
  endif else begin
    ;else no way to compare value with bounds, which are not set
    x = call_function(conv(type),c1)
  endelse
endif else begin
  ;else use default
  x = call_function(conv(type),x0)
endelse

return,x
end
