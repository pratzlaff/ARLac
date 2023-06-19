function gapt,t,tbeg=tbeg,tend=tend,delt=delt,gaps=gaps
;+
;function	gapt
;		returns the time series with either the gaps removed or
;		reinserted
;
;parameters	t	(input) array of [photon arrival] times
;			NOTE: T *must* be sorted in increasing order!
;
;keywords	tbeg	(input) array of beginning times of Good Time Intervals
;		tend	(input) array of ending times of Good Time Intervals
;		delt	(output) outputT = inputT + delt
;		gaps	if set, REINSERTS gaps into the time series according
;			to DELT
;
;history
;	vinay kashyap (ASC/UC 1995)
;-

;consistency checks
np = n_params(0)
if np eq 0 then begin
  print, 'Usage: newT = gapt(T,tbeg=tbeg,tend=tend,delt=delt,gaps=gaps)'
  print, '  returns the time series with either the gaps removed or reinserted'
  return,-1L
endif
nt = n_elements(t)
if keyword_set(tbeg) and not keyword_set(tend) then return,t
if not keyword_set(tbeg) and keyword_set(tend) then return,t
if not keyword_set(tbeg) and not keyword_set(tend) then begin
  tbeg = [t(0)] & tend = [t(nt-1)]
endif
if n_elements(tbeg) ne n_elements(tend) then return,t

if keyword_set(gaps) then begin
  if keyword_set(delt) then begin
    if n_elements(delt) ne nt then return,t
    tt = t-delt & return,tt
  endif
  tt = t + tbeg(0)
  for i=1,n_elements(tbeg)-1 do begin
    dt = tbeg(i)-tend(i-1)
    h1 = where(tt ge tend(i-1))
    if h1(0) ne -1 then tt(h1) = tt(h1)+dt
  endfor
  return,tt
endif

delt = 0.*t & dt = 0.D
for i=1,n_elements(tbeg)-1 do begin
  h1 = where(t ge tbeg(i) and t le tend(i))
  dt = tbeg(i)-tend(i-1)+dt
  if h1(0) ne -1 then delt(h1) = -dt
endfor

delt = delt-tbeg(0)
tt = t+delt

return,tt
end
