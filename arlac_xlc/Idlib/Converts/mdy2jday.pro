pro mdy2jday,m,d,y,jd
;converts the given month/day/year to Julian day number (based on JULDAY.F
;from Numerical Recipes, by Press et al.)

if n_params(0) lt 4 then begin
  print, 'Usage: mdy2jday,m,d,y,jd'
  print, 'converts given date (month/day/year) to Julian day number'
  return
endif

igreg = 15 + 31*long(10+12*1582)	;gregorian calendar adopted 10/15/1582

if y eq 0. then begin
  print, 'there is no year zero, dummy!'
  print, 'assuming 1 A.D.' & y = 1
endif

if y lt 0. then y = y + 1

if m gt 2 then begin
  jy = y & jm = m+1
endif
if m le 2 then begin
  jy = y - 1 & jm = m + 13
endif

jd = long(365.25*jy) + long(30.60001*jm) + long(d) + 1720995

if d+31*long(m+12*y) ge igreg then begin
  ja = fix(0.01*jy) & jd = jd + 2 - ja + fix(0.25*ja)
endif

return
end
