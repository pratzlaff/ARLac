pro rdvalue,prmpt,x,x0,xr,d=d,l=l,i=i,b=b,com=com,ch=ch
;+
;procedure	rdvalue	reads value of variable in foolproof manner
;
;parameters	prmpt	prompt for variable
;		x	value of variable (output)
;		x0	default value (optional input)
;		xr	2-element array defining the valid range of x:
;			[x_low,x_high]. (optional)
;			if input lies outside the given bounds, prompts for
;			value ONCE more.
;
;keywords	d	x is taken to be double (default: real)
;		l	x is taken to be a long integer
;		i	x is taken to be integer*2
;		b	x is taken to be integer*1
;		com	x is taken to be complex
;		ch	if set, x is taken to be a character string, and
;			no attempt to obtain its numeric value is made.
;			(default is for x to be real)
;
;usage		rdvalue,prmpt,x,[x0,[xr]]
;		[,/d|,/l|,/i|,/b|,/com|,/ch]
;
;restrictions
;	range is not checked for complex and charcter inputs
;	does not check if the default is of the right type
;
;examples
;	rdvalue,'type a character',c,'z',/ch & print,c
;	x0 = !pi & rdvalue,'type a real number',x,x0 & print,x
;	rdvalue,'type a long integer',l,200068,/l & print,l
;	rdvalue,'type an integer',i,0,/i & print,i
;	rdvalue,'type a short integer',b,0,[0,2],/b & print,b
;
;
;history
;	vinay kashyap (3/23/93)
;	modified to include on-the-fly computations and array inputs (VK, 6/95)
;-

on_error,2

;initialize
c1 = '' & n1 = n_params(0) & type = 0 & chkrng = 1 & chkdef = 1
d1 = string("12b) & d2 = string("15b) & d3 = ' ' & d4 = ''
conv = [ 'float','double','long','fix','byte','complex','string' ]

if n1 lt 2 then begin
  print, 'Usage: rdvalue,prompt,x,default,[low,high],/d,/l,/i,/b,/com,/ch'
  print, '  reads in required value (x) in, ahem, foolproof manner'
  return
endif
if n1 lt 4 then chkrng=0
if n1 lt 3 then chkdef=0 

if keyword_set(d) then type=1
if keyword_set(l) then type=2
if keyword_set(i) then type=3
if keyword_set(b) then type=4
if keyword_set(com) then type=5
if keyword_set(ch) then type=6

if not chkdef then begin
  x0 = 0. & if type eq 6 then x0 = 'n'
  x0 = call_function(conv(type),x0)
endif
prmpt = prmpt + ' {' + strtrim(x0,2) + '}'
if not chkrng then begin
  if type eq 0 then begin & xr=(2.^127-1.)*[-1.,1.] & chkrng=1 & endif
  if type eq 2 then begin & xr=[2L^31,2L^31-1] & chkrng=1 & endif
  if type eq 3 then begin & xr=[2^15,2^15-1] & chkrng=1 & endif
  if type eq 4 then begin & xr=[0b,255b] & chkrng=1 & endif
endif
if type eq 5 or type eq 6 then chkrng = 0

print, form="($,a,'"+prmpt(0)+"')",string("15b) & read,c1

if c1 ne d1 and c1 ne d2 and c1 ne d3 and c1 ne d4 then begin
  ;handle arithmetic expressions and other functional forms
  if type ne 5 and type ne 6 then begin
    cmd='c2='+c1+' & c1=strcompress(c2)' & hh=execute(cmd)
  endif
  ;if input non-trivial value then
  if chkrng then begin
    ;if bounds are set then
    y = double(c1)
    if y(0) lt xr(0) or y(0) gt xr(1) then begin
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

return
end
