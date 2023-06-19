pro chakra,x,y,color=color,psize=psize,pthick=pthick, _extra=e
;+
;procedure	chakra
;	plot an Ashoka Chakra
;
;syntax
;	chakra,x,y,color=color,psize=psize,pthick=pthick
;
;parameters
;	x	[INPUT] X-positions of points at which to plot
;	y	[INPUT] Y-positions of points at which to plot
;
;keywords
;	color	[INPUT] color number in color table
;		* default is 1
;	psize	[INPUT] size of symbols
;		* default is 10
;	pthick	[INPUT] thickness of lines
;		* default is 3
;	_extra	[INPUT ONLY] pass defined keywords to PLOTS
;
;example
;	peasecolr,verbose=50 & !p.background=255
;	plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,2.1],yr=[0,2.1]
;	polyfill,[0,2.1,2.1,0,0],[1.4,1.4,2.1,2.1,1.4],col=81
;	polyfill,[0,2.1,2.1,0,0],[0,0,0.7,0.7,0],col=31
;	chakra,1,1.05,psize=6
;
;history
;	vinay kashyap (Jun2005)
;-

;	usage
ok='ok' & np=n_params() & nx=n_elements(x) & ny=n_elements(y)
if np lt 2 then ok='Insufficient parameters' else $
 if nx eq 0 then ok='X is undefined' else $
  if ny eq 0 then ok='Y is undefined' else $
   if nx ne ny then ok='X and Y are incompatible'
if ok ne 'ok' then begin
  print,'Usage: chakra,x,y,color=color,psize=psize,pthick=pthick'
  print,'  plot an Ashoka chakra'
  if np ne 0 then message,ok,/informational
  return
endif

;	keywords
col=1 & if keyword_set(color) then col=color[0]
psz=10. & if keyword_set(psize) then psz=psize[0]
pth=3. & if keyword_set(pthick) then pth=pthick[0]

;	first, the wheel
poaintsym,'circle',psize=4*psz,pthick=4*pth,color=col
plots,x,y,psym=8, _extra=e

;	then, the inner circle
poaintsym,'circle',/pfill,psize=0.5*psz,pthick=pth,color=col
plots,x,y,psym=8, _extra=e

;	the spokes
tht=360.*findgen(24)/23.
for i=0,24-1 do begin
  poaintsym,'spoke',psize=2*psz,pthick=pth,/pfill,color=col,aspect=0.5,$
	angle=tht[i]
  plots,x,y,psym=8, _extra=e
endfor

return
end
