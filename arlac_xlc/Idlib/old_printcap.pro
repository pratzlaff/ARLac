;PRINTCAP.PRO
;+
;procedure:	printcap
;
;usage:		printcap,flnm,old,stile,fsz=fsz,/help
;
;purpose:	sets up the printing format for postscript files
;
;parameters:	flnm	name of file to recieve output
;		old	string containing the old plotting window name
;		stile	style of printing (note that if this parameter is
;			omitted, then 'old' is assumed to be the style
;			format number)
;
;keywords:	fsz	set font size (default is 12)
;		help	show available printing styles
;
;examples:	printcap,'flnm',old,0	   sets up default & returns old=old
;		a=1 & printcap,'idl.ps',a  sets up style 1 & returns a=old
;		printcap,'flnm',b,3	   sets up style 3 & returns b=old
;		printcap,'flnm',a,2,fsz=8  sets up style 2 at font size 8
;		printcap,'flnm',/help	   shows available styles
;		printcap,3		   style 3, flnm='3.ps'
;		a=3 & printcap,a,2	   style 2, flnm='3.ps'
;-

;------------------------------------------------------------------
pro helprint

c1 = [ 	'Available printing styles',$
	'0: IDL default (portrait mode)',$
	'1: IDL default, but at font specified font size',$
	'2: landscape mode',$
	'3: portrait mode, but occupying the entire page',$
	'4: plot with xsize=8.3cm, ysize=8.5 cm (compare micela et al.)',$
	'5: Yu-Qing"s compromise for JGR (x=21cm, y=26cm, yoff=1.2cm)',$
	'6: Thesis plot, portrait mode',$
	'7: Thesis plot, landscape mode',$
	'8: ApJ 1-column mode',$
	'9: square plots',$
	'10: portrait mode, but with 2 inch clearance for caption',$
	'default font size is 12 and default print mode is 0' ]

for i=0,n_elements(c1)-1 do print, c1(i)

return
end

;------------------------------------------------------------------
pro printcap,flnm,old,stile,fsz=fsz,help=help

n1 = n_params(0)
if n1 eq 0 then begin
  print, 'Usage: printcap,flnm[,old[,stile[,fsz=fsz[,/help]]]]'
  print, '  sets up printing device keywords for IDL postscript plots'
  if keyword_set(help) then helprint
  return
endif
if n1 eq 1 then begin
  style = fix(flnm) & flnm = strtrim(flnm,2) + '.ps'
endif
if n1 eq 2 then begin
  style = fix(old) & flnm = strtrim(flnm,2) + '.ps'
endif
if n1 eq 3 then style = stile
if not keyword_set(fsz) then fsize = 12 else fsize = fsz
if keyword_set(help) then helprint

old = !d.name & set_plot,'ps'

print, 'printing style chosen:', strcompress(style)

case style of
  0: device,file=flnm
  1: device,file=flnm,font_size=fsize
  2: device,file=flnm,/landscape,font_size=fsize
  3: device,file=flnm,ysize=24.,yoffset=2.,font_size=fsize
  4: device,file=flnm,xsize=11.4,ysize=10.6
  5: device,file=flnm,xsize=21.,ysize=26.,yoffset=1.2,font_size=fsize
  6: device,file=flnm,xs=6.,ys=8.,xoff=1.5,yoff=1.5,/inches,font_size=fsize
  7: device,file=flnm,/land,xs=8.5,ys=6.,xoff=1.,yoff=10.,/in,font_size=fsize
  8: device,file=flnm,ys=18.,yoff=4.,xs=9.,xoff=5.,font_size=fsize
  9: device,file=flnm,xs=11.8,ys=10.6,scale=1.5,yoff=6,font_size=fsize
  10: device,file=flnm,ysize=19.,yoffset=7.,font_size=fsize
  else: device,file=flnm
endcase

return
end
