;+
;mk_calfig.pro
;	makes an xfig readable file that displays the yearly calendar
;	a la Leon Golub
;
;usage
;	dayofyear=1
;	.run mk_calfig
;
;	-- will produce a file in $cwd named cal.fig
;	-- open with xfig, edit as needed, export to postscript,
;	   and print on pstabloid with
;	   cprint -d pstabloid -scale 1.6 cal.ps
;
;Vinay Kashyap (8Jan2008)
;-

openw,uc,'cal.fig',/get_lun

;	preamble
printf,uc,'#FIG 3.2'
printf,uc,'Portrait'
printf,uc,'Center'
printf,uc,'Inches'
printf,uc,'Letter'
printf,uc,'100.00'
printf,uc,'Single'
printf,uc,'-2'
printf,uc,'1200 2'

xoffset=600
;	verticle bars for day of week separation
for i=1,6 do begin
  printf,uc,'2 1 0 1 0 7 52 -1 -1 0.000 0 0 -1 0 0 2'
  xloc=xoffset+900+(i-1)*600
  printf,uc,'         '+strtrim(xloc,2)+' 600 '+strtrim(xloc,2)+' '+strtrim(600+53*225,2)
endfor

;	boxes for week separation
for iwk=1,53 do begin
  printf,uc,'2 2 0 1 0 7 52 -1 -1 0.000 0 0 -1 0 0 5'
  xloc1=xoffset+300 & xloc2=xoffset+4500
  yloc1=600+(iwk-1)*225 & yloc2=600+iwk*225
  printf,uc,'         '+strtrim(xloc1,2)+' '+strtrim(yloc1,2)+' '+strtrim(xloc2,2)+' '+strtrim(yloc1,2)+' '+strtrim(xloc2,2)+' '+strtrim(yloc2,2)+' '+strtrim(xloc1,2)+' '+strtrim(yloc2,2)+' '+strtrim(xloc1,2)+' '+strtrim(yloc1,2)
endfor

;	big box to contain everything
printf,uc,'2 4 0 1 31 7 53 -1 -1 0.000 0 0 7 0 0 5'
printf,uc,'         8400 13200 0 13200 0 0 8400 0 8400 13200'
printf,uc,'4 0 31 53 -1 19 12 0.0000 4 135 255 8025 13175 vlk\001'

;	calendar for which year?
caldat,julday(),mm,dd,yyyy & if mm gt 10 then yyyy=yyyy+1
case yyyy of
  2006: begin & jan1=1 & leapyr=1 & end	;sunday
  2007: begin & jan1=2 & leapyr=1 & end	;monday
  2008: begin & jan1=3 & leapyr=1 & end	;tuesday
  2009: begin & jan1=5 & leapyr=0 & end	;thursday
  2010: begin & jan1=6 & leapyr=0 & end	;friday
  2011: begin & jan1=7 & leapyr=0 & end	;saturday
  2012: begin & jan1=1 & leapyr=1 & end	;sunday
  2013: begin & jan1=3 & leapyr=0 & end	;tuesday
  2014: begin & jan1=4 & leapyr=0 & end	;wednesday
  2015: begin & jan1=5 & leapyr=0 & end	;thursday
  2016: begin & jan1=6 & leapyr=1 & end	;friday
  2017: begin & jan1=1 & leapyr=0 & end	;sunday
  2018: begin & jan1=2 & leapyr=0 & end	;monday
  2019: begin & jan1=3 & leapyr=0 & end	;tuesday
  2020: begin & jan1=4 & leapyr=1 & end	;wednesday
  2021: begin & jan1=6 & leapyr=0 & end	;friday
  2022: begin & jan1=7 & leapyr=0 & end	;saturday
  2023: begin & jan1=1 & leapyr=0 & end	;sunday
  2024: begin & jan1=2 & leapyr=1 & end	;monday
  else: begin
    if yyyy gt 2008 then $
      jan1=1+((3+((yyyy-2008)+(fix(yyyy-1)-2008)/4)) mod 7) else $
      message,'Year '+strtrim(yyyy,2)+' not understood',/informational
  end
endcase

colmon=[1,4,12,16,22,24,1,4,12,16,22,24]
strmon=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
daysyr=365+leapyr & dayofyr=indgen(daysyr)+1
daymon=[31,28+leapyr,31,30,31,30,31,31,30,31,30,31]
cdaymon=total(daymon,/cumul)
days=dayofyr
for i=1,12-1 do $
  days[cdaymon[i-1]:cdaymon[i]-1]=days[cdaymon[i-1]:cdaymon[i]-1]-cdaymon[i-1]

if not keyword_set(dayofyear) then dayofyear=0

iwk=1L & idesyloc=intarr(12)
for i=1,jan1-1 do begin
  xloc=xoffset+450+(i-1)*600 & yloc=600+iwk*225-25 & dd=31-(jan1-1)+i
  printf,uc,'4 0 0 50 -1 0 12 0.0000 4 135 180 '+strtrim(xloc,2)+' '+strtrim(yloc,2)+' '+strtrim(dd,2)+'\001' 
endfor
dow=jan1 & imon=1
for iday=1,daysyr do begin
  xloc=xoffset+450+(dow-1)*600 & yloc=600+iwk*225-25 & dd=days[iday-1]
  if dd lt 10 then xloc=xloc+75
  if dd gt 99 then xloc=xloc-50
  if keyword_set(dayofyear) then xloc=xloc-30
  ff=10 & if dow eq 1 then ff=11
  printf,uc,'4 0 '+strtrim(colmon[imon-1],2)+' 50 -1 '+strtrim(ff,2)+' 12 0.0000 4 135 180 '+strtrim(xloc,2)+' '+strtrim(yloc,2)+' '+strtrim(dd,2)+'\001' 
  xxloc=xoffset+850+(dow-1)*600 & yyloc=600+iwk*225
  if keyword_set(dayofyear) and iday gt 31 then printf,uc,'4 0 '+strtrim(colmon[imon-1],2)+' 51 -1 7  7 1.5708 4 90 180 '+strtrim(xxloc,2)+' '+strtrim(yyloc,2)+' '+strtrim(iday,2)+'\001'
  dow=dow+1
  if dow eq 8 then begin
    dow=1 & iwk=iwk+1
  endif
  if dd eq 1+daymon[imon-1]/2 then idesyloc[imon-1]=yloc
  if dd eq daymon[imon-1] then imon=imon+1
endfor
for i=dow,7 do begin
  xloc=xoffset+450+(i-1)*600+75 & yloc=600+iwk*225-25 & dd=1+(i-dow)
  printf,uc,'4 0 0 50 -1 0 12 0.0000 4 135 180 '+strtrim(xloc,2)+' '+strtrim(yloc,2)+' '+strtrim(dd,2)+'\001' 
endfor

for i=1,12 do begin
  xloc=xoffset & yloc=idesyloc[i-1]+225	;600+3*i*225
  printf,uc,'4 0 '+strtrim(colmon[i-1],2)+' 51 -1 18 16 1.5708 4 180 495 '+strtrim(xloc,2)+' '+strtrim(yloc,2)+' '+strmon[i-1]+'\001'
endfor

wkday=['sun','mon','tue','wed','thu','fri','sat']
for i=1,7 do begin
  xloc=xoffset+300+(i-1)*600+100 & yloc=600-fix(0.25*225)
  cc=11 ;& if i eq 1 then cc=31
  printf,uc,'4 0 '+strtrim(cc,2)+' 51 -1 18 12 0.0000 4 135 405 '+strtrim(xloc,2)+' '+strtrim(yloc,2)+' '+wkday[i-1]+'\001'
endfor

printf,uc,'4 0 0 50 -1 18 18 0.0000 4 195 600 300 300 '+strtrim(yyyy,2)+'\001'

close,uc & free_lun,uc

end
