pro crsec0,e1,e2,sigma
;+
;procedure	crsec0,e1,e2,sigma
;		calculates the cross-section of absorption by the ISM,
;		averaged over the given bandwidth using the analytical
;		expression of Tanaka & Bleeker (1977) and the modification
;		to it due to molecular hydrogen (Kashyap et al. 1991) it
;		is assumed that e1(keV) < e2(keV), and at high latitudes,
;		N(H2) = 0.26 * N(HI) 
;		the analytical expression is
;		 sigma = 0.65 * 1e-22 * e^-3 + 0.16 * f(H2) * 1e-22 * e^-3.54
;						0.0124 < e < 0.28
;		 sigma = 0.65 * 1e-22 * e^-3
;						0.28   < e < 0.53
; 		 sigma = 2.0  * 1e-22 * e^-2.5
;						0.53   < e < 5.0
; 		 sigma = 0.
;						5.0    < e
;
;superseded by ISMABS.PRO
;-

e3 = 0. & e4 = 0. & sigma = 0. & fh2 = 0.26
if e1 lt 0.0124 then e1 = 0.0124
if e2 lt 0.0124 then e2 = 0.0124
if e1 gt 5.0    then e1 = 5.0
if e2 gt 5.0    then e2 = 5.0
if e1 lt 0.28 and e2 gt 0.28 then e3 = 0.28
if e1 lt 0.53 and e2 gt 0.53 then e4 = 0.53

if e3 eq 0. and e4 eq 0. then begin
  sav1 = (e2^(-2.00)-e1^(-2.00)) / ((e2-e1)*(-2.00))
  sav2 = (e2^(-2.54)-e1^(-2.54)) / ((e2-e1)*(-2.54))
  sav3 = (e2^(-1.50)-e1^(-1.50)) / ((e2-e1)*(-1.50))
  if e2 le 0.28 then begin
    sigma = 0.65 * 1e-22 * sav1 + 0.16 * fh2 * 1e-22 * sav2 
  endif
  if e2 le 0.53 and e2 gt 0.28 then begin
    sigma = 0.65 * 1e-22 * sav1
  endif
  if e2 le 5.00 and e2 gt 0.53 then begin
    sigma = 2.00 * 1e-22 * sav3
  endif
endif

if e3 eq 0. and e4 ne 0. then begin
  sav1 = (e4^(-2.00)-e1^(-2.00)) / (-2.00)
  sav3 = (e2^(-1.50)-e4^(-1.50)) / (-1.50)
  sigma = 1e-22 * (0.65 * sav1 + 2.0 * sav3) / (e2-e1)
endif

if e3 ne 0. and e4 eq 0. then begin
  sav1 = (e2^(-2.00)-e1^(-2.00)) / (-2.00)
  sav2 = (e3^(-2.54)-e1^(-2.54)) / (-2.54)
  sigma = 1e-22 * (0.65 * sav1 + 0.16 * fh2 * sav2) / (e2-e1)
endif

if e3 ne 0. and e4 ne 0. then begin
  sav1 = (e4^(-2.00)-e1^(-2.00)) / (-2.00)
  sav2 = (e3^(-2.54)-e1^(-2.54)) / (-2.54)
  sav3 = (e2^(-1.50)-e4^(-1.50)) / (-1.50)
  sigma = 1e-22 * (0.65 * sav1 + 0.16 * fh2 * sav2 + 2.0 * sav3) / (e2-e1)
endif

return
end
