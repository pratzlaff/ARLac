pro magdist,app,abs,dist,v=v,mv=mv,r=r
;+
;procedure:	magdist,app,abs,dist,v=v,mv=mv,r=r
;		given two of v, Mv and r, obtains the last
;
;parameters:	app	apparent magnitude
;		abs	absolute magnitude
;		dist	distance to source, in parsecs
;
;keywords:	v	if set, calculates app and exits
;		mv	if set, calculates abs and exits
;		r	if set, calculates dist and exits
;-

n1 = n_params(0)
if not keyword_set(v) and not keyword_set(mv) and not keyword_set(r) then n1=0

if n1 eq 0 then begin
  print, 'Usages: magdist,app,abs,dist,[/v | /mv | /r]'
  ;print, '        magdist,abs,dist,/v'
  ;print, '        magdist,app,dist,/mv'
  ;print, '        magdist,app,abs,/r'
  print, '        magdist,abs,dist,/mv'
  print, '        magdist,app,dist,/v'
  print, '        magdist,abs,app,/r'
  print, '        given two of v, Mv and r, obtains the last'
  return
endif

if keyword_set(v)  then begin
  if n1 eq 1 then begin
    abs = app & dist = 10.
  endif
  if n1 eq 2 then begin
    dist = abs & abs = app
  endif
  app  = abs - 5. + 5.*alog10(dist)
  if n1 lt 3 then print, 'apparent magnitude:',app
  return
endif
if keyword_set(mv) then begin
  if n1 eq 1 then dist = 10.
  if n1 eq 2 then dist = abs
  abs  = app + 5. - 5.*alog10(dist)
  if n1 lt 3 then print, 'Absolute Magnitude:',abs
  return
endif
if keyword_set(r)  then begin
  if n1 eq 1 then abs = app
  dist = 10. * 10^((app-abs)/5)
  if n1 lt 3 then print, 'distance (pc):',dist
  return
endif

return
end
