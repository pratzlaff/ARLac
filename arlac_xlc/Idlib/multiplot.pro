pro multiplot,x,y,yup=yup,ydn=ydn,ann=ann,xr=xr,yrup=yrup,yrdn=yrdn,$
	xt=xt,yt=yt,tt=tt,io=io,nmar=nmar
;+
;procedure	multiplot
;		modified from STACKPLOT (Reichert & Candey)
;		use to plot multiple functions of the same variable,
;		WITH error bars if specified
;
;parameters	x	independent variable (of the form x[n])
;		y	dependent variable (of the form y[m,n])
;
;keywords	yup	upper limits to y (of the form y[m,n])
;		ydn	lower limits to y (of the form y[m,n])
;		ann	annotation (string array of the form ann[n])
;		xr	xrange
;		yrup	upper yrange (of the form yrup[m])
;		yrdn	lower yrange (of the form yrdn[m])
;		xt	xtitle (string)
;		yt	ytitle (string)
;		tt	title (string)
;		io	force plot_io if non-zero (of the form io[n])
;		nmar	eliminate horizontal lines delineating plots
;-

message,'THIS IS AN UGLY PIECE OF CODE',/info

npar = n_params(0)
if npar lt 2 then begin
  print, 'Usage: multiplot,x,y,yup=yup,ydn=ydn,ann=ann,yrdn=yrdn,yrup=yrup,xt=xt,yt=yt,tt=tt,io=io,nmar=nmar'
  print, '  Uses !p.title, !x.title, and !x.tickname only once for the page'
  return
endif

sz = size(y) & m = sz(1) & n = sz(2)

if not keyword_set(yup) then yup = y
if not keyword_set(ydn) then ydn = y-(yup-y)
if not keyword_set(ann) then ann=strarr(n) else ann=string(ann)
if not keyword_set(xr) then xr=[min(x),max(x)]
if not keyword_set(yrup) then yrup=yup*10.
if not keyword_set(yrdn) then yrdn=ydn*0.1
if not keyword_set(xt) then xt=strarr(m)+'X' else xt=string(xt)
if not keyword_set(yt) then yt='Y'+strtrim(indgen(m)+1,2) else yt=string(yt)
if not keyword_set(tt) then tt='' else tt=string(tt)
if not keyword_set(io) then io=intarr(m)
if not keyword_set(nmar) then nmar=0

;store current system variables
xtitle = !x.title & ytitle = !y.title & mtitle = !p.title
xtickname = !x.tickname
ymargin = !y.margin & yomargin = !y.omargin
pmulti = !p.multi & charsize = !p.charsize

;reset syetem variables
!x.title = '' & !p.title = tt
;!x.tickname = replicate(' ',n*2)
!x.tickname[*] = ' '
!y.margin = [nmar,nmar] & !y.omargin = [10,10]
!p.multi = [0,1,m] & !p.charsize = (m - 1.)/4. + 1.

for jj=0,m-1 do begin
  !y.title = yt(jj) & lilo = io(jj)
  yy=y(jj*m:(jj+1)*m+n-1) & ypl=yrup(jj) & ymn=yrdn(jj)
  if jj eq m-1 then begin				; last plot
    if n_elements(ann) lt n_elements(!x.tickname) then !x.tickname = ann
    if n_elements(xt) gt 1 then !x.title = xt[jj] else !x.title=xt[0]
  endif
  if lilo eq 0 then plot,x,yy,xrange=xr,yrange=[ymn,ypl],psym=1,$
	ystyle=1,xstyle=1
  if lilo eq 1 then plot_io,x,yy,xrange=xr,yrange=[ymn,ypl],psym=1,$
	ystyle=1,xstyle=1
  for ii=0,n-1 do oplot,x(ii)*[1.,1.],[yup(jj,ii),ydn(jj,ii)]
  !p.title = ''
endfor

;set system variables back to old ones
!x.title = xtitle & !y.title = ytitle & !p.title = mtitle
!x.tickname = xtickname
!y.margin = ymargin & !y.omargin = yomargin
!p.multi = pmulti & !p.charsize = charsize

return
end
