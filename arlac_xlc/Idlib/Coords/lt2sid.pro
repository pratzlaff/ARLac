pro lt2sid,y,m,d,local,zone,sdrl
;+
;procedure	lt2sid
;	converts local time to local sidereal time
;
;parameters
;	y	[INPUT; required] year
;	m	[INPUT; required] month
;	d	[INPUT; required] day
;	local	[INPUT; required] local time
;	zone	[INPUT; required] zone correction for UT
;	sdrl	[OUTPUT] local sidereal time
;
;history
;	vinay kashyap (1994)
;-

if n_params(0) lt 5 then begin
  print, 'Usage: lt2sid,y,m,d,local,zone,sdrl'
  print, '  Converts local time to local sidereal time' & return
endif

ut = local - zone & ut2gst,y,m,d,ut,gst & sdrl = gst + zone

if sdrl gt 24. then sdrl = sdrl-24.
if sdrl lt 0. then sdrl = sdrl+ 24.

if n_params(0) lt 6 then print, 'LT:',strcompress(local),' LSdT:',strcompress(sdrl)

return
end
