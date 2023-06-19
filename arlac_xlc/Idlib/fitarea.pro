pro fitarea,skev,area,nsp,aev,aar,iar
;+
;pro fitarea,skev,area,nsp,aev,aar,iar
;interpolates the array aar(iar) v/s aev(iar) onto the points represented by
;skev(nsp) and places the output in area(nsp)
;-

area = 0.*skev

for i=0,nsp-1 do begin
  if i lt nsp-1 then begin
    bin = skev(i+1)-skev(i)
    ee = (skev(i)+skev(i+1))*0.5
  endif
  if i eq nsp-1 then ee = bin + (skev(nsp-1)+skev(nsp-2))*0.5
  area(i) = -1. 
  if ee lt 0.1 or ee gt 6.5 then area(i) = 0.
  if area(i) lt 0. then begin
    hit = where(ee ge aev)
    if hit(0) eq -1 then stop & mhit = max(hit)
    if ee eq aev(mhit) then area(i) = aar(mhit)
    if ee ne aev(mhit) then begin
      if mhit eq iar-1 then area(i) = aar(iar-1)
      if mhit lt iar-1 then area(i) = aar(mhit) + $
      (aar(mhit+1)-aar(mhit)) * (ee-aev(mhit)) /$
      (aev(mhit+1)-aev(mhit))
    endif				;end ee ne aev(mhit)
  endif					;end area(i) lt 0.
endfor

return
end
