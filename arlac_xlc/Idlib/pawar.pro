pro pawar,spec,skev,emin,emax,power
;+
;pro pawar,spec,skev,emin,emax,power
;integrates spec [units/keV] from emin to emax
;-

nsp = n_elements(spec) & k1 = 0 & k2 = 0 & k3 = nsp & k4 = nsp

for i=0,nsp-1 do begin
  if emin le skev(i) and k2 eq 0 then begin
    k1 = i - 1 & k2 = i
  endif
  if emax le skev(i) and k4 eq nsp then begin
    k3 = i - 1 & k4 = i
  endif
endfor

bit = skev(k2) - emin & bin = skev(1) - skev(0) & power = spec(k1)*bit
for i=k2,k3-1 do begin
  if i ne 0 and i ne nsp-1 then  bin = skev(i) - skev(i-1)
  power = power + spec(i)*bin
endfor
bit = emax - skev(k3) & power = power + spec(k4)*bit

return
end
