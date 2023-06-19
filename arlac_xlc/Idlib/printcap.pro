pro printcap,hint,root=root,epsfil=epsfil,verbose=verbose,oldname=oldname,$
	_extra=e
;+
;procedure	printcap
;	set up special plot printing format, and is essentially a
;	wrapper to the DEVICE procedure
;
;	generally to be used to make special types of postscript plots.
;
;parameters
;	hint	[INPUT] string describing the operation needed
;		* for a list of possible inputs, do
;		  	printcap,'help'
;
;keywords
;	root	[INPUT] root name of the output file
;		* default is 'idl'
;	epsfil	[INPUT] if set, and does not conflict with HINT,
;		output is written to encapsulated postscript.
;		* default is to write to plain postscript unless
;		  HINT says otherwise
;	verbose	[INPUT] controls verbosity
;	oldname	[OUTPUT] the value of !D.NAME before it got changed
;
;	_extra	[INPUT] pass defined keywords to DEVICE
;
;history
;	vinay kashyap (1994)
;	majorly rewritten (VK; MarMM)
;-

;	check input
nh=n_elements(hint) & szh=size(hint) & nszh=n_elements(szh) & todo='help'
if nh eq 0 then todo='Usage' else $
 if nh gt 1 then todo='help' else $
  if szh(nszh-2) ne 7 then todo='help' else $
	todo=strlowcase(strtrim(hint,2))

;	keywords
nr=n_elements(root) & szr=size(root) & nszr=n_elements(szr)
if nr eq 1 and szr(nszr-2) eq 7 then froot=strtrim(root[0]) else froot='idl'
;
v=0 & if keyword_set(verbose) then v=fix(verbose[0]) > 1
;
oldname=!D.NAME
;
n_e=n_tags(e)
if n_e gt 0 then begin
  etags=strupcase(tag_names(e)) & DEV_KEY=strjoin(etags,',')
endif else DEV_KEY=''

;	initialize
usage=[	'Usage: printcap,hint,root=root,/epsfil,verbose=v,oldname=!d.name,',$
	'       DEVICE_KEYWORDS',$
	'    set up special plot print formats']
if v ge 1 then help=[Usage,'','HINT may be:'] else help=['HINT :==']

;{	analyze the hint

flag=todo					;default
		;display usage?
i0=strpos(todo,'Usage',0)
if i0 ge 0 then flag='usage'
		;display help?
i0=strpos(todo,'help',0) & i1=strpos(todo,'?',0) & i2=strpos(todo,'hint',0)
if i0 ge 0 or i1 ge 0 or i2 ge 0 then flag='help'
		;make gif file?
help=[help,"'gif': dump gif file from current window"]
i0=strpos(todo,'gif',0)
if i0 ge 0 then flag='gif'
		;make unadorned portrait plot
help=[help,"'simple/normal portrait': make a normal IDL portrait plot"]
if todo eq '' then i0=0L else i0=-1L
i1=strpos(todo,'norm',0) & i2=strpos(todo,'simp',0) & i3=strpos(todo,'port',0)
if i0 ge 0 then flag='portrait'
if i1 ge 0 and i3 ge 0 then flag='portrait'
if i2 ge 0 and i3 ge 0 then flag='portrait'
		;make unadorned landscape plot
help=[help,"'simple/normal landscape': make a normal IDL landscape plot"]
i0=strpos(todo,'norm',0) & i1=strpos(todo,'simp',0) & i2=strpos(todo,'land',0)
if i0 ge 0 and i2 ge 0 then flag='landscape'
if i1 ge 0 and i2 ge 0 then flag='landscape'
		;full page portrait
help=[help,"'full page portrait': portrait mode, occupying entire page"]
i0=strpos(todo,'full',0) & i1=strpos(todo,'page',0) & i2=strpos(todo,'port',0)
if i0 ge 0 and i2 ge 0 then flag='fullport'
if i0 ge 0 and i1 ge 0 then flag='fullport'
if i1 ge 0 and i2 ge 0 then flag='fullport'
		;S-plus aspect
    		;plot with xsize=8.3cm, ysize=8.5 cm (compare micela et al.)
help=[help,"'S-plus aspect': S-plus style portrait mode, cf. Micela et al."]
i0=strpos(todo,'plus',0) & i1=strpos(todo,'+',0)
i2=strpos(todo,'micela',0) & i3=strpos(todo,'aspect',0)
if i0 ge 0 or i1 ge 0 or i2 ge 0 then flag='splus'
		;JGR style
		;Yu-Qing's compromise for JGR (x=21cm, y=26cm, yoff=1.2cm)
help=[help,"'JGR': JGR style, portrait mode, as made by Yu-Qing"]
i0=strpos(todo,'jgr',0)
i1=strpos(todo,'yu-qing',0) & i2=strpos(todo,'yuqing',0)
if i0 ge 0 or i1 ge 0 or i2 ge 0 then flag='jgr'
		;UChicago Thesis plot, portrait mode
help=[help,"'UChicago thesis portrait': UChicago thesis plot, portrait mode"]
i0=strpos(todo,'uchi',0) & i1=strpos(todo,'thes',0)
i2=strpos(todo,'port',0)
if i0 ge 0 and i2 ge 0 then flag='theport'
if i1 ge 0 and i2 ge 0 then flag='theport'
		;UChicago Thesis plot, landscape mode
help=[help,"'UChicago thesis landscape': UChicago thesis plot, landscape mode"]
i0=strpos(todo,'uchi',0) & i1=strpos(todo,'thes',0)
i2=strpos(todo,'land',0)
if i0 ge 0 and i2 ge 0 then flag='theland'
if i1 ge 0 and i2 ge 0 then flag='theland'
		;ApJ 1-column mode
help=[help,"'ApJ 1-column': to fit into an ApJ column"]
i0=strpos(todo,'apj',0) & i1=strpos(todo,'colum',0)
i2=strpos(todo,'1',0) & i3=strpos(todo,'one',0)
if i0 ge 0 then flag='ApJ1'
if i1 ge 0 and (i2 ge 0 or i3 ge 0) then flag='ApJ1'
		;square plots
help=[help,"'square': As square as we can make 'em"]
i0=strpos(todo,'squa',0)
if i0 ge 0 then flag='square'
		;portrait, with 2-inch clearance for caption
help=[help,"'2-inch clear': portrait with clearance for caption"]
i0=strpos(todo,'2',0) & i1=strpos(todo,'two',0)
i2=strpos(todo,'inch',0)
i3=strpos(todo,'clear',0)
i4=strpos(todo,'caption',0)
if (i0 ge 0 or i1 ge 0) and i2 ge 0 then flag='caption'
if i3 ge 0 or i4 ge 0 then flag='caption'

;	done analyzing the hint}

stop

;	do somethin..
case flag of					;{FLAG
  'usage': begin
    for i=0,n_elements(usage)-1 do print,usage(i)
    return
  end
  'help': begin
    for i=0,n_elements(help)-1 do print,help(i)
    return
  end

  'gif': begin
    if odname ne 'X' then begin
      message,'Current device has no plot window to dump from',/info
      return
    endif
    dwin=!d.window
    if dwin ge 0 then begin
      outfil=froot+'.gif'
      tvlct,r,g,b,/get & write_gif,outfil,tvrd(),r,g,b
      cmd='tvlct,r,g,b,/get & write_gif,outfil,tvrd(),r,g,b'
      if v ge 1 then message,'Window '+strtrim(dwin,2)+' -> '+outfil,/info
    endif else message,'No plot window to dump',/info
  end

  'portrait': begin
    if keyword_set(epsfil) then begin
      encaps=1 & outfil=froot+'.eps'
    endif else begin
      encaps=0 & outfil=froot+'.ps'
    endelse
    set_plot,'ps'
    device,file=outfil,encapsulated=encaps,landscape=0, _extra=e
    cmd='device,file=outfil,encapsulated=epsfil,landscape=0'
  end

  'landscape': begin
    if keyword_set(epsfil) then begin
      encaps=1 & outfil=froot+'.eps'
    endif else begin
      encaps=0 & outfil=froot+'.ps'
    endelse
    set_plot,'ps'
    device,file=outfil,encapsulated=encaps,/landscape, _extra=e
    cmd='device,file=outfil,encapsulated=epsfil,/landscape'
  end

  'fullport': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,ysize=24.,yoffset=2.,landscape=0,encapsulated=encaps,$
	_extra=e
    cmd='device,file=outfil,ysize=24.,yoffset=2.,landscape=0,encapsulated=0'
  end

  'splus': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,xsize=11.4,ysize=10.6,landscape=0,encapsulated=encaps,$
	_extra=e
    cmd='device,file=outfil,xsize=11.4,ysize=10.6,landscape=0,encaps=0'
  end

  'jgr': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,xsize=21.,ysize=26.,yoffset=1.2,landscape=0,$
	encapsulated=encaps, _extra=e
    cmd='device,file=outfil,xsize=21.,ysize=26.,yoffset=1.2,land=0,encaps=0'
  end

  'theport': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,xsize=6.,ysize=8.,yoffset=1.5,/inches,landscape=0,$
	encapsulated=encaps, _extra=e
    cmd='device,file=outfil,xs=6.,ys=8.,yoff=1.5,/inches,land=0,encaps=0'
  end

  'theland': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,/landscape,xsize=8.5,ysize=6.,xoffset=1.,yoffset=10.,$
	/inches,encapsulated=encaps, _extra=e
    cmd='device,file=outfil,xs=8.5,ys=6.,/in,xoff=1.,yoff=10.,/land,encaps=0'
  end

  'ApJ1': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,ysize=18.,yoffset=4.,xsize=9.,xoffset=5.,landscape=0,$
	encapsulated=encaps, _extra=e
    cmd='device,file=outfil,ys=18.,yoff=4.,xs=9.,xoff=5.,land=0,encaps=0'
  end

  'square': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,xsize=11.8,ysize=10.6,scale=1.5,yoffset=6,$
	landscape=0,encapsulated=encaps, _extra=e
    cmd='device,file=outfil,xs=11.8,ys=10.6,scale=1.5,yoff=6,land=0,encaps=0'
  end

  'caption': begin
    if keyword_set(epsfil) and v ge 1 then message,$
	'Ignoring keyword EPSFIL',/info
    encaps=0 & outfil=froot+'.ps'
    set_plot,'ps'
    device,file=outfil,ysize=19.,yoffset=7.,landscape=0,encapsulated=encaps,$
	_extra=e
    cmd='device,file=outfil,ysize=19.,yoffset=7.,land=0,encaps=0'
  end

  else: begin
    for i=0,n_elements(help)-1 do print,help(i)
    message,'Could not understand HINT='+todo,/info
    return
  end
endcase						;FLAG}

;	chatter
if v ge 1 and keyword_set(outfil) then message,'Output -> '+$
	strtrim(outfil,2),/info
if v ge 2 and keyword_set(cmd) then print,cmd
if v ge 3 and keyword_set(DEV_KEY) then print,DEV_KEY

return
end
