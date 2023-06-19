;+
;CALEN.PRO
;prints out the dates in the format year month day in a specified interval.
;-

mm = 0 & dd = 0 & yy = 0 & m1 = 0 & d1 = 0 & y1 = 0
print, 'type starting month,day,year (eg: 12 31 1991)' & read, mm,dd,yy
print, 'type ending month,day,year (eg: 12 31 2001)' & read, m1,d1,y1
print, 'type output filename [(-) for STDOUT]' & c1 = '' & read,c1
if c1 ne '-' then openw,1,c1

while ( dd ne d1 or mm ne m1 or yy ne y1 ) do begin
  leap = 0 & if (float(yy)/4.)-float((yy/4)) eq 0. then leap = 1
  dmax = 30
  if mm eq 2 then begin
    dmax = 28 & if leap eq 1 then dmax = 29
  endif
  if (mm-1)*(mm-3)*(mm-5)*(mm-7)*(mm-8)*(mm-10)*(mm-12) eq 0 then dmax = 31
  if dd gt dmax then begin
    dd = 1 & mm = mm + 1 & if mm eq 13 then mm = 1
    if dd eq 1 and mm eq 1 then yy = yy + 1
  endif
  if c1 eq '-' then print, yy,mm,dd 
  if c1 ne '-' then printf,1, yy,mm,dd
  dd = dd + 1
endwhile

close,1
end
