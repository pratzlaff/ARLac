pro ut2gst,y,m,d,ut,gst
;+
;procedure	ut2gst
;	converts UT to Greenwich Sidereal Time
;
;parameters
;	y	[INPUT; required] year
;	m	[INPUT; required] month
;	d	[INPUT; required] day
;	ut	[INPUT; required] UT in decimal hours
;	gst	[OUTPUT] Greenwich Sidereal Time in decimal hours
;
;keywords	NONE
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) lt 4 then begin
  print, 'Usage: ut2gst,year,month,day,UT,GST'
  print, '  converts UT to Greenwich Sidereal Time' & return
endif

mdy2jday,m,d,y,jd & jd = jd - 0.5D

s=jd-2451545 & t=s/36525.0 & t0=6.697374558+2400.051336*t+0.000025862*t^2
t0 = t0 - fix(t0/24.)*24. & h1 = where(t0 lt 0.)
if h1(0) ne -1 then t0(h1) = t0(h1) + 24.
gst = ut + t0 & gst = gst - fix(gst/24.)*24. & h1 = where(gst lt 0.)
if h1(0) ne -1 then gst(h1) = gst(h1) + 24.

if n_params(0) lt 5 then print, 'UT:',strcompress(ut),' GST:',strcompress(gst)

return
end
