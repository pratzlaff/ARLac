pro jday2mdy,jd,m,d,y
;converts the given Julian date to calendar date month/day/year (based on
;CALDAT.F from Numerical Recipes, by Press et al.)

if n_params(0) lt 2 then begin
  print, 'Usage: jday,jd,m,d,y'
  print, 'converts given Julian day number to month/day/year'
  return
endif

igreg = 2299161				;crossover to gregorian calendar

if jd ge igreg then begin
  jalpha = fix(((jd-1867216)-0.25)/36524.25)
  ja = jd + 1 + jalpha - fix(0.25*jalpha)
endif
if jd lt igreg then ja = jd

jb = long(ja + 1524)       
jc = fix(6680.+((jb-2439870)-122.1)/365.25)
jdd = long(365)*jc+fix(0.25*jc+ 0.5)  
je = fix((jb-jdd)/30.6001)
d = jb-jdd-long(30.6001*je)
m = je-1
if m gt 12 then m = m - 12 
y = jc - 4715
if m gt 2 then y = y - 1   
if y le 0 then y = y - 1

return
end
