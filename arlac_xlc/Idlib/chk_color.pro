pro chk_color,border=border
;+
;procedure chk_color
;
;to help decide on setting color levels for any standard loaded color table
;
;usage:		chk_color[,border=border]
;
;parameters:			none
;
;keywords:	border		color level of the plot border 
;-

if not keyword_set(border) then bord = 225 else bord = border
loadct,0
plot,findgen(2),xrange=[0.,257.],yrange=[0.,1.],color=bord,/nodata
x = fltarr(2) & j = 0
for i=1,256 do begin
  y1 = 1.-0.05*j & y0 = 0.7-0.05*j
  j = j + 1 & if j eq 10 then j = 0
  y = [y0,y1] & x(*) = float(i)
  oplot,x,y,color=i
endfor

color_tab

return
end
