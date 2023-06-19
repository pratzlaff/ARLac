function cm,x,mtr=mtr,mu=mu,ang=ang,au=au,ly=ly,pc=pc,hz=hz,sol=sol,$
	inch=inch,ft=ft,mile=mile,nmil=nmil,inv=inv,cs=cs
;+
;function	cm
;	converts given input to cm, or if input is cm, to specified unit
;
;parameters
;	x	[INPUT; required] value to change units of
;		* may be anything numeric
;
;keywords
;	inv	[INPUT] if set, implies input is in [CM], and the output
;		will be in the specified unit
;
;	mtr	[INPUT] if set, input is [meter]
;	ang	[INPUT] if set, input is [angstrom]
;	mu	[INPUT] if set, input is [micron]
;	au	[INPUT] if set, input is [A.U.]
;	ly	[INPUT] if set, input is [light year]
;	pc	[INPUT] if set, input is [parsec]
;	hz	[INPUT] if set, input is [Hz]
;		* uses keyword CS
;	sol	[INPUT] if set, input is [solar radius]
;	cs	[INPUT] wave speed in [cm/s] (for use in conversions to
;		and from frequency)
;		* default is to use the speed of light
;	inch	[INPUT] if set, input is [imperial standard inch]
;	ft	[INPUT] if set, input is [imperial standard feet]
;	mile	[INPUT] if set, input is [imperial standard mile]
;	nmil	[INPUT] if set, input is [US standard nautical mile]
;
;examples
;	(light) [Ang]->[Hz] : hz=cm(cm(ang,/ang),/inv,/hz)
;	(sound) [Hz]->[cm] : ang=cm(hz,/hz,cs=330e2)
;	[pc]->[AU] : AU=cm(cm(pc,/pc),/inv,/au)
;	[knots]->[mph]: mph=cm(cm(knots,/nmil),/inv,/mile)
;
;see also
;	ERG.PRO
;
;history
;	vinay kashyap (1994)
;	added inches, miles, etc. (VK; 1998)
;-

nx=n_elements(x)
if nx eq 0 then begin
  print, 'Usage: y = cm(x,/mtr,/ang,/mu,/au,/ly,/pc,/hz,/sol,$
  print, '           /inch,/ft,/mile,/nmil,/inv,cs=cs)'
  print, '  convert from specified unit to cm (reverse if INV is set)'
  return,0
endif

c = 2.99792458e10

scale = 1.
vs = c & if keyword_set(cs) then vs = cs

if keyword_set(mtr) then scale = 1e2
if keyword_set(ang) then scale = 1e-8
if keyword_set(mu) then scale = 1e-4
if keyword_set(au) then scale = 1.495985e13
if keyword_set(ly) then scale = c*365.2422*24.*60.*60.
if keyword_set(pc) then scale = 3.26*c*365.2422*24.*60.*60.
if keyword_set(sol) then scale = 6.969e10
if keyword_set(hz) then begin & val = vs/x & return,val & endif
if keyword_set(inch) then scale = 1./2.54
if keyword_set(ft) then scale = 1./(2.54*12.)
if keyword_set(mile) then scale = 1./(2.54*12.*5280.)
if keyword_set(nmil) then scale = 1./(2.54*12.*6076.11549)

if keyword_set(inv) then scale = 1./scale

val = x*scale

if keyword_set(hz) then val = 1./val

return,val
end
