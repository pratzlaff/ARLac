pro crsec1,e1,e2,sigma
;+
;pro crsec1,e1,e2,sigma
;calculates the cross-section of absorption by the ISM, averaged over the
;given bandwidth using the analytical expression of Morrison & McCammon,
;1983, ApJ, 270, 119, and the modification to it due to molecular hydrogen
;(Cruddace et al. 1977, ApJ, 187, 497; Kashyap et al. 1991)
;it is assumed that e1(keV) < e2(keV), and at high latitudes,
;N(H2) = 0.26 * N(HI)
;the analytical expression is
;  sigma = 1e-24 * (c0 + c1*e + c2*e*e) * e^-3 + sigma(H2)
;  sigma(H2) = 0.16 * f(H2) * 1e-22 * e^-3.54
;
;superseded by ISMABS.PRO
;-

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

pint = c0*((1./el^2)-(1./eh^2)) + c1*(1./el-1./eh) + c2*alog(eh/el)
fh2 = 0.26 & sig0 = 1e-24 & pint = pint*sig0

for j=0,n_elements(el)-1 do begin
  if e1 ge el(j) and e1 lt eh(j) then j1 = j
  if e2 ge el(j) and e2 lt eh(j) then j2 = j
endfor

if j1 eq j2 then begin
  i = j1
  sigma = c0(i)*((1./e1^2)-(1./e2^2))+c1(i)*(1./e1-1./e2)+c2(i)*alog(e2/e1)
endif
if j1 ne j2 then begin
  sav1 = c0(j1)*((1./e1^2)-(1./eh(j1)^2))+c1(j1)*(1./e1-1./eh(j1))+$
  c2(j1)*alog(eh(j1)/e1)
  sav2 = c0(j2)*((1./el(j2)^2)-(1./e2^2))+c1(j2)*(1./el(j2)-1./e2)+$
  c2(j2)*alog(e2/el(j2))
  sigma = sav1 + sav2
  if j2-j1 gt 1 then begin
    for i=j1+1,j2-1,1 do begin
    sigma = sigma + pint(i)
    endfor
  endif
endif

sh2 = 0.16*fh2*((1./e1^(2.54))-(1./e2^(2.54)))/2.54
sigma = sigma*sig0 + sh2*sig0*100.
sigma = sigma/(e2-e1)
print, e1,e2,j1,j2,(sh2*sig0*100.)/(e2-e1),sigma

return
end
