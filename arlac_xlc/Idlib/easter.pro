;+
;procedure	eastr	calculates day of easter (first sunday after the
;			14th day after the first new moon after march 21st)
;parameters	year	input year (float)
;		day	output date of easter (string)
;keywords	debug	if set, stops at the end of procedure to allow
;			debugging
;-
pro division,a,b,c,d,e
;procedure	division	divide a by b = c
;parameters	a	numerator
;		b	denominator
;		c	a/b
;		d	fix(c)
;		e	remainder, = (c-d)*b

a = float(a) & b = float(b)

c = a/b & d = fix(c) & e = fix((c-d)*b+0.5)

return
end

pro easter,year,day,debug=debug
;procedure	eastr	calculates day of easter (usually the first sunday
;			after the 14th day after the first new moon after
;			march 21st)
;parameters	year	input year (float)
;		day	output date of easter (string)
;keywords	debug	if set, stops at the end of procedure to allow
;			debugging

if n_params(0) eq 0 then begin
  print, 'Usage: eastr,year,date'
  print, '  calculates date of easter for given year'
  return
endif

division,year,19.,v1,v2,a
division,year,100.,v1,b,c
division,b,4.,v1,d,e
division,(b+8.),25.,v1,f
division,(b-f+1.),3.,v1,g
division,(19.*a+b-d-g+15.),30.,v1,v2,h
division,c,4.,v1,i,k
division,(32.+2.*e+2.*i-h-k),7.,v1,v2,l
division,(a+11.*h+22.*l),451.,v1,m
division,(h+l-7.*m+114.),31.,v1,n,p

hm = where(n eq 3) & ha = where(n eq 4) & month = string(n)
if hm(0) ne -1 then month(hm) = ' March'
if ha(0) ne -1 then month(ha) = ' April'

day = strcompress(fix(p+1.5)) + month + strcompress(fix(year))

if n_params(0) eq 1 then print, day

if keyword_set(debug) then stop
return
end
