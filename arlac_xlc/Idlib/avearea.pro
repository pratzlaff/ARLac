pro avearea,area,emin,emax,kev,ar,iar
;+
;pro avearea,area,emin,emax,kev,ar,iar
;computes an average effective area over the energy range emin-emax keV
;for an instrument with given effective area ar(iar) v/s kev(iar),
;assuming a photon spectrum of E^-1.4 ph/keV/...
;-

alf = -1.4 & alp = alf + 1

area = 0. & normalize = (emax^(alp)-emin^(alp))/alp

imin = where(kev ge emin) & imax = where(kev le emax)
if imin(0) eq -1 or imax(0) eq -1 then return

nmin = min(imin) & nmax = max(imax) & spec = kev^(alf)

dE = kev(nmin)-emin
if nmin eq 0 then arx = ar(0) + (ar(0)-ar(1))*(emin-kev(0))/(kev(0)-kev(1))
if nmin gt 0 then arx = ar(nmin-1) + (ar(nmin-1)-ar(nmin))*$
	(kev(nmin-1)-emin)/(kev(nmin-1)-kev(nmin))
area = arx*emin^(alf)*dE

if nmax gt nmin then begin
  for i=nmin,nmax-1 do begin
    if i lt iar-1 then dE = kev(i+1) - kev(i)
    area = area + ar(i)*spec(i)*dE
  endfor
endif

dE = emax-kev(nmax)
if nmax eq iar-1 then arx = ar(nmax) + (ar(iar-2)-ar(nmax))*$
	(kev(nmax)-emax)/(kev(iar-2)-kev(nmax))
if nmax lt iar-1 then arx = ar(nmax) + (ar(nmax)-ar(nmax+1))*$
	(kev(nmax)-emax)/(kev(nmax)-kev(nmax+1))
area = area + arx*emax^(alf)*dE

area = area/normalize
print, emin,emax,area

return
end
