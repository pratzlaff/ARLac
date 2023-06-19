function simarrt,lc,t,tmin=tmin,tmax=tmax,net=net
;+
;function	simarrt
;		returns a simulated array of photon arrival times for the
;		given light curve template
;
;parameters	lc	input lightcurve (1D array) [cts/s]
;		t	input time coordinate [s]
;			(optional: if not given, t=findgen(n_elements(lc))
;
;keywords	tmin	if set, ignore all t < tmin {default: t(0)}
;		tmax	if set, ignore all t > tmax {default: t(n_elements(t)-1)
;		net	expected number of counts in output.  if set,
;			renormalizes lc
;
;restrictions
;	cannot handle gaps in t
;
;history
;	vinay kashyap (1/17/95)
;-

np = n_params(0)
if np lt 1 then begin
  print, 'Usage: arr_tims = simarrt(lc,t,tmin=tmin,tmax=tmax,net=net)'
  print, '  return simulated photon arrival times for given lc(t)'
  return,[-1]
endif

ltc = lc & nlc = n_elements(ltc)
if np eq 1 then tt = findgen(nlc) else tt = t

t0 = tt(0) & if keyword_set(tmin) then t0 = tmin
t1 = tt(nlc-1) & if keyword_set(tmax) then t1 = tmax
if t1 le t0 then begin
  print, 'SIMARRT: tmin='+strtrim(t0,2)+' > tmax='+strtrim(t1,2)+' !'
  return,[-1]
endif
h1 = where(tt ge t0 and tt le t1)
if h1(0) ne -1 then begin
  tt = tt(h1) & ltc = ltc(h1) & nlc = n_elements(ltc)
endif
dt = tt(1:*) - tt & dt = [dt,dt(nlc-2)] & nph = total(ltc*dt)
t1 = t1+dt(nlc-1)
;note assumption of width of last bin == width of last but one bin
if keyword_set(net) then ltc=ltc*net/nph
nph=fix(total(ltc*dt))

;set up microbins of width such that we expect 1 photon/bin
mubin = (t1-t0)/(nph-1.) & tmu = t0 + findgen(nph)*mubin

;interpolate the light curve to the microbinning scale
tmp = nr_spline(tt,ltc) & lmu = nr_splint(tt,ltc,tmp,tmu) & meanct = lmu*mubin

;generate exponential deviates to determine arrival times
tbeg=t0 & totint=0. & rndm=randomu(seed,nph) & k=0 & karr=0
arrt = fltarr(2*nph) + (t0-1.)
for i=0,nph-1 do begin
  tend = tmu(i)+mubin
  if meanct(i) eq 0. then begin & totint=tend & tbeg=tend & endif
  while totint lt tend and meanct(i) gt 0. do begin
    if k ge nph then begin & rndm=randomu(seed,nph) & k=0 & endif
    arrdist = mubin/meanct(i)
    expdev = -arrdist*alog(rndm(k)) & totint = tbeg+expdev
    if totint lt tend then begin
      tbeg=tbeg+expdev & k=k+1
      if karr ge 2*nph then arrt = [arrt,tbeg] else arrt(karr) = tbeg
      karr=karr+1
    endif
  endwhile
endfor

h1 = where(arrt ge t0) & arrt = arrt(h1)

return,arrt
end
