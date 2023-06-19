function erg,x,j=j,ev=ev,kev=kev,gm=gm,kg=kg,me=me,mp=mp,sol=sol,geo=geo,$
	degk=degk,hz=hz,inv=inv
;+
;function	erg
;	converts given input to ergs, or if input is erg, to specified unit
;
;parameters
;	x	[INPUT; required] value to change units of
;		* may be anything numeric
;
;keywords
;	inv	[INPUT] if set, implies input is in [ERGS], and the
;		output will be in the specified unit
;	j	[INPUT] if set, input is [joule]
;	ev	[INPUT] if set, input is [eV]
;	kev	[INPUT] if set, input is [keV]
;	gm	[INPUT] if set, input is [gm]
;	kg	[INPUT] if set, input is [kilogram]
;	me	[INPUT] if set, input is [electron mass]
;	mp	[INPUT] if set, input is [proton mass]
;	sol	[INPUT] if set, input is [solar mass]
;	geo	[INPUT] if set, input is [mass of earth]
;	degk	[INPUT] if set, input is [degrees Kelvin]
;	hz	[INPUT] if set, input is [frequency]
;
;examples
;	[Ang]->[eV]: hz=cm(cm(ang,/ang),/inv,/hz) & eV=erg(erg(hz,/hz),/inv,/eV)
;	[Ang]->[K]: hz=cm(cm(ang,/ang),/inv,/hz) & K=erg(erg(hz,/hz),/inv,/degK)
;	[eV]->[Hz]: K=erg(erg(eV,/eV),/hz)
;	[keV]->[K]: K=erg(erg(keV,/keV),/inv,/degK)
;	[K]->[keV]: keV=erg(erg(K,/degK),/inv,/keV)
;
;see also
;	CM.PRO
;
;history
;	vinay kashyap (1994)
;-

nx=n_elements(x)
if nx eq 0 then begin
  print, 'Usage: y=erg(x,/j,/ev,/kev,/gm,/kg,/me,/mp,/sol,/geo,/degk,/hz,/inv)'
  print,'  convert from specified unit to ergs (reverse in INV is set)'
  return,0
endif

c = 2.99792458d10 & kb = 1.380662d-16 & h = 6.626176d-27
elec = 9.109558d-28 & prot = 1.67248d-24 & sun = 1.989d33 & erth = 5.98d27

scale = 1.

if keyword_set(j) then scale = 1d7
if keyword_set(ev) then scale = 1.6021892d-12
if keyword_set(kev) then scale = 1.6021892d-9
if keyword_set(gm) then scale = c*c
if keyword_set(kg) then scale = 1e3*c*c
if keyword_set(me) then scale = elec*c*c
if keyword_set(mp) then scale = prot*c*c
if keyword_set(sol) then scale = sun*c*c
if keyword_set(geo) then scale = erth*c*c
if keyword_set(degk) then scale = kb
if keyword_set(hz) then scale = h

if keyword_set(inv) then scale = 1./scale

val = x*scale

return,val
end
