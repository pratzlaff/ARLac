function rad,x,deg=deg,min=min,sec=sec,dms=dms,inv=inv
;+
;function	rad
;		converts angles to or from radians, from or to the
;		specified unit (def: degrees --> radians)
;
;parameters	x	input (def: assumed to be degrees)
;
;keywords	deg	degree (default)
;		min	arcmin
;		sec	arcsec
;		dms	[d,m,s]
;		inv	implies input is in radians, and should be converted
;			to specified unit
;-

if n_params(0) eq 0 then begin
  print, 'Usage: y = rad(x,/min,/sec,/dms,/inv)'
  print, '  to convert angles to and from radians'
  return,0
endif

scale = !pi/180.

if keyword_set(dms) then begin 
  min = 0 & sec = 0
  if not keyword_set(inv) then begin
    sz = size(x) & val = fltarr(sz(1))
    if sz(0) eq 1 and sz(1) eq 3 then val = x(0)+x(1)/60.+x(2)/3600.
    x = val
  endif
endif
if keyword_set(min) then scale = scale/60.
if keyword_set(sec) then scale = scale/3600.
if keyword_set(inv) then scale = 1./scale

val = x*scale

if keyword_set(dms) and keyword_set(inv) then begin
  d = fix(val) & min = 60.*(val-d) & m = fix(min) & s = 60.*(min-m)
  val = [d,m,s]
endif

return,val
end
