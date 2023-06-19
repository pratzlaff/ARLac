function ismabs,kev,fh2=fh2,tb=tb
;+
;function	ismabs
;		returns the ISM absorption cross section [cm^2]
;
;parameters	kev	energy [keV] at which to compute cross section
;
;keywords	fh2	ratio of molecular H to atomic H along line of sight
;		tb	use analytical expression of Tanaka & Bleeker
;
;description
;	this procedure calculates the ISM absorption cross section at the
;	given energy using the analytical expression of Morrison & McCammon
;	1983, ApJ 270, 119, and the modification to it due to molecular
;	hydrogen (Cruddace et al. 1977, ApJ 187, 497; Kashyap et al. 1992,
;	ApJ 391, 667)
;	the absorption cross-section (Morrison & McCammon)
;		sigma = 1e-24 * (c0 + c1*kev + c2*kev*kev) * kev^-3 + sigma(H2),
;	where
;		sigma(H2) = 0.16 * f(H2) * 1e-22 * kev^-3.54,
;		el < kev < eh, and
;		fh2 == f(H2) = N(H2)/N(HI)
;	alternatly according to the simpler expression obtained by Tanaka
;	& Bleeker,
;		sigma = 0.65*1e-22*kev^-3+sigma(H2)	0.0124 < kev < 0.53
;		sigma = 2.0*1e-22*kev^-2.5+sigma(H2)	0.53   < kev < 5.0
;		sigma = 0.				5.0    < kev
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: sigma = ismabs(kev,fh2=fh2 [,/tb])'
  print, '  returns ISM absorption cross section [cm^2]' & return,0L
endif

;Morrison & McCammon fit coefficients

c0 = [ 17.3, 34.6, 78.1, 71.4, 95.5, 308.9, 120.6, 141.3, 202.7, 342.7,$
352.2, 433.9, 629.0, 701.2 ]

c1 = [ 608.1, 267.9, 18.8, 66.8, 145.8, -380.6, 169.3, 146.8, 104.7, 18.7,$
18.7, -2.4, 30.9, 25.2 ]

c2 = [ -2150.0, -476.1, 4.3, -51.4, -61.1, 294.0, -47.7, -31.5, -17.0, 0.0,$
0.0, 0.75, 0.0, 0.0 ]

el = [ 0.030, 0.100, 0.284, 0.400, 0.532, 0.707, 0.867, 1.303, 1.840,$
2.471, 3.210, 4.038, 7.111, 8.331 ]

eh = [ 0.100, 0.284, 0.400, 0.532, 0.707, 0.867, 1.303, 1.840, 2.471,$
3.210, 4.038, 7.111, 8.331, 10.00 ]

if keyword_set(tb) then begin
  sig0 = 1e-22
  if kev lt 0.0124 then sigma = 0.
  if kev ge 0.0124 and kev lt 0.53 then sigma = 0.65*sig0*kev^(-3)
  if kev ge 0.53 and kev lt 5.0 then sigma = 2.0*sig0*kev^(-2.5)
endif else begin
  sig0 = 1e-24 & sigma = 0. & h1 = where(el le kev)
  if h1(0) ne -1 then begin
    i = max(h1) & sigma = sig0*(c0(i)+c1(i)*kev+c2(i)*kev*kev)*kev^(-3)
  endif
endelse

sigma = sigma*1e22

;molecular hydrogen
sigmah2 = 0.
if keyword_set(fh2) then begin
  if fh2 lt 0. then fh2 = 0.26 & sigmah2 = 0.
  if kev lt 1. then sigmah2 = 0.16 * fh2 * kev^(-3.54)
endif

sigma = sigma + sigmah2 & sigma = sigma * 1e-22

return,sigma
end
