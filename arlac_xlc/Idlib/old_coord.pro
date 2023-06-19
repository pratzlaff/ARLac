;+
;procedure	get_coord
;		interactively obtains the coordinates of a point of a
;		displayed or specified image
;
;parameters	image	2D image (optional)
;
;keywords 	indx	window number (default: 0)
;		plot	convert device coordinates to plot coordinates
;			in the display
;		noz	if the z-value is not needed, use to speed up the
;			routine
;		help	enter on-line help before quitting
;
;side effects
;	if key 's' is pressed in input mode, creates file coords_tmp in
;	current working directory
;
;history
;5/10/92 - vlk
;5/18/92 - vlk (included direct cursor readout; provision for image input)
;5/25/92 - vlk (included physical plot coordinate readout; installed demo
;		images; increased keyboard options; installed extensive help)
;5/27/92 - vlk (modified to read z values along with x and y; extended help)
;5/31/92 - vlk (modified buffer storage; included shell escape; provision
;		for manually setting the scale factors and zeros for images)
;7/23/93 - vlk (improved calling sequence, added help keyword)
;
;-

pro helpout
;help routine for get_coord				5/25/92 (vlk)

print, 'Use vi type commands to move around the image, x for mouse, q to quit'
print, 'type a key to get a description of its action, q to quit help.'

c1 = 'q' & c2 = '?'

while c2 ne c1 do begin
  case c2 of
    'h': print, 'move left by 1 pixel'
    'j': print, 'move down by 1 pixel'
    'k': print, 'move up by 1 pixel'
    'l': print, 'move right by 1 pixel'
    'e': print, 'move right by an eigth of the image size'
    'E': print, 'move right by a fourth of the image size'
    'b': print, 'move left by an eigth of the image size'
    'B': print, 'move left by a fourth of the image size'
    ' ': print, 'identical to l'
    't': print, 'move right by 8 pixels'
    'T': print, 'move left by 8 pixels'
    'w': print, 'move right by 16 pixels'
    'W': print, 'move left by 16 pixels'
    '': print, 'move up by an eigth of the image size'
    '': print, 'move up by a fourth of the image size'
    '': print, 'move down by an eigth of the image size'
    '': print, 'move down by a fourth of the image size'
    string("12b): print, 'identical to j'
    'v': print, 'move up by 8 pixels'
    'V': print, 'move down by 8 pixels'
    'g': print, 'move up by 16 pixels'
    'G': print, 'move down by 16 pixels'
    'H': print, 'move to top row of present column'
    'M': print, 'move to middle row of present column'
    'L': print, 'move to bottom row of present column'
    '$': print, 'move to end of present row'
    ')': print, 'move to last column of present row (identical to $)'
    '=': print, 'move to middle column of present row'
    '(': print, 'move to first column of present row'
    '^': print, 'reflect across the y-axis centered on the center of image'
    '{': print, 'reflect across the x-axis centered on the center of image'
    '}': print, 'identical to {'
    'r': print,'reflect across the x and y axes centered on the center of image'
    '~': print, 'interchange (x,y)'
    '-': print, 'move to first column of previous row'
    '_': print, 'move to first column of present row'
    '+': print, 'move to first column of next row'
    '>': print, 'move to last row of next column'
    '<': print, 'move to last row of previous column'
    'o': print, 'move to origin of image coordinates, the bottom left corner'
    'c': print, 'move to center of image'
    'u': print, 'move back to previous position'
    '`': print, 'mark position with an alphabet for future reference'
    ',': print, 'return to position marked with given alphabet'
    'x': print, 'enable mouse position readout. press right button to disable'
    'X': begin
      print, 'manually change the scaling of the x and y coordinates.'
      print, '  the routine will prompt for each value, and the default'
      print, '  is presented in square brackets.  hit return for default.'
      print, '  the syntax is {x = (i-zerox)*xfactor + x0, (x --> y)}'
    end
    'S': print, 'reserved for any special transformations that may be needed'
    ':': print, 'manually specify coordinates to which to move to'
    'a': print, 'store coordinates on the screen'
    'i': print, 'identical to a'
    's': print, 'save coordinates in the file coords_tmp'
    '?': begin
      print, 'procedure name: get_coord'
      print, 'parameters:     image (2-D array)'
      print, 'keywords:       indx (window number, def: 0)'
      print, '                plot (read physical coordinates off of plot)'
      print, '                noz (does not read z-values: speeds up routine)'
      print, 'keys used: h j k l e E b B t T w W ^U ^D ^B ^F v V g G H M L'
      print, '<ret> <sp> $ ) ( r ~ - _ + > < o c u ` , x X S : a i s ? ! q'
    end
    '!': print, 'shell escape'
    'q': print, 'exit'
    else: print, 'unused'
  endcase
  c2 = get_kbrd(1)
endwhile

out:

return
end
;---------------------------------------------------------------------
pro get_coord,image,indx=indx,plot=plot,noz=noz,help=help

imgflg = 1
if n_params(0) eq 1 then begin
  sz = size(image) & if sz(0) ne 2 then return
  x = sz(1) & y = sz(2)
  window,/free,xsize=x,ysize=y & tvscl,image & indx = !d.window
endif

get_lun,u & filopn = 0 & snum = 0
zerox = 0 & zeroy = 0 & xfac = 1 & yfac = 1 & plusx = 0 & plusy = 0

if keyword_set(help) then begin
  helpout & return
endif
if keyword_set(plot) then begin
  zerox = !p.clip(0) & zeroy = !p.clip(1) & indx = !d.window
  plusx = !x.crange(0) & plusy = !y.crange(0)
  xfac = (!x.crange(1)-!x.crange(0))/(!p.clip(2)-!p.clip(0))
  yfac = (!y.crange(1)-!y.crange(0))/(!p.clip(3)-!p.clip(1))
  imgflg = 0
endif
if keyword_set(noz) then imgflg = 0
if not keyword_set(noz) and n_params(0) eq 0 then begin
  if not keyword_set(plot) then image = tvrd(0,0,!d.x_vsize,!d.y_vsize)
endif
if keyword_set(indx) then windx = indx else windx = !d.window

xx = !d.x_vsize & yy = !d.y_vsize & wset,windx

i=0 & j=0 & oldi=intarr(28) & oldj=intarr(28)
cur=' ' & cr1='   ' & cr2=string("15b) & cr3=string("12b)

;decide output display format:
formx = 1
if imgflg eq 1 then begin
  zmin = min(image,max=zmax) & formx=7
  if zmax-zmin lt 1000 and zmax-zmin gt 100 then formx = 4
  if zmax-zmin ge 1000. and zmax-zmin le 1e5 then formx = 5
  if zmax-zmin gt 1e5 then begin
    if xfac gt 1e3 or yfac gt 1e3 then formx = 6
  endif
endif else begin
  if keyword_set(plot) then begin
    formx = 2 & if xfac gt 30 or yfac gt 30 then formx = 3
  endif
endelse

form1 = "($,'x=',i4,', y=',i4,a3,' ',a)"
form2 = "($,'x=',f10.5,', y=',f10.5,a3,' ',a)"
form3 = "($,'x=',e11.4,', y=',e11.4,a3,' ',a)"
form4 = "($,'x=',i4,', y=',i4,' z=',i4,a3,' ',a)"
form5 = "($,'x=',f10.5,', y=',f10.5,' z=',f10.5,a3,' ',a)"
form6 = "($,'x=',e11.4,', y=',e11.4,' z=',e11.4,a3,' ',a)"
form7 = "($,'x=',f10.5,', y=',f10.5,' z=',e11.4,a3,' ',a)"

case formx of
  1: form = form1
  2: form = form2
  3: form = form3
  4: form = form4
  5: form = form5
  6: form = form6
  7: form = form7
  else: form = form2
endcase

print, 'h(<-) j(\/) k(^) l(->) ... x(mouse[MB3-exit]) ?(help) q(quit)'

while cur ne 'q' do begin
  cur = get_kbrd(1)
  case cur of
    '?': helpout
    'h': i = i - 1
    'j': j = j - 1
    'k': j = j + 1
    'l': i = i + 1
    'e': i = i + xx/8
    'E': i = i + xx/4
    'b': i = i - xx/8
    'B': i = i - xx/4
    ' ': i = i + 1
    't': i = i + 8
    'T': i = i - 8
    'w': i = i + 16
    'W': i = i - 16
    '': j = j + yy/8
    '': j = j + yy/4
    '': j = j - yy/8
    '': j = j - yy/4
    string("12b): j = j - 1
    'v': j = j + 8
    'V': j = j - 8
    'g': j = j + 16
    'G': j = j - 16
    'H': j = yy-1
    'M': j = yy/2
    'L': j = 0
    '$': i = xx-1
    ')': i = xx-1
    '=': i = xx/2
    '(': i = 0
    '^': j = yy-j-1
    '{': i = xx-i-1
    '}': i = xx-i-1
    'r': begin
      i = xx-i-1 & j = yy-j-1
    end
    '~': begin
      temp = i & i = j & j = temp
    end
    '-': begin
      i = 0 & j = j + 1
    end
    '_': i = 0
    '+': begin
      i = 0 & j = j - 1
    end
    '>': begin
      i = i + 1 & j = 0
    end
    '<': begin
      i = i - 1 & j = 0
    end
    'o': begin
      i = 0 & j = 0 
    end
    'c': begin
      i = xx/2 & j = yy/2
    end
    'u': begin
      i = oldi(1) & j = oldj(1)
    end
    '`': begin
      c1 = get_kbrd(1) & posalfbt,c1,pos & pos = pos+1
      oldi(pos) = i & oldj(pos) = j
    end
    ',': begin
      c1 = get_kbrd(1) & posalfbt,c1,pos & pos = pos+1
      i = oldi(pos) & j = oldj(pos)
    end
    'x': begin
      print, 'press right button to exit cursor readout'
      while !err ne 4 do begin
	wait,0.1 & tvrdc,i,j,2,/dev
	if i le 0 then i = 0 & if j le 0 then j = 0
	if i ge xx then i = xx-1 & if j ge yy then j = yy-1
	xpos = (i-zerox)*xfac+plusx & ypos = (j-zeroy)*yfac+plusy
	if not imgflg then print,form=form,xpos,ypos,cr1,cr2
	if imgflg then print,form=form,xpos,ypos,image(i,j),cr1,cr2
      endwhile
    end
    'X': begin
      if not keyword_set(plot) then begin
	c1 = 'type zero of x-axis (device) [' + strtrim(zerox,2) + ']'
	print, form="($,50a)",'      ',c1,string("15b) & z1 = '' & read,z1
	c1 = 'type scale factor for x-axis [' + strtrim(xfac,2) + ']'
	print, form="($,50a)",'      ',c1,string("15b) & z2 = '' & read,z2
	c1 = 'type zero of y-axis(device) [' + strtrim(zeroy,2) + ']'
	print, form="($,50a)",'      ',c1,string("15b) & z3 = '' & read,z3
	c1 = 'type scale factor for y-axis [' + strtrim(yfac,2) + ']'
	print, form="($,50a)",'      ',c1,string("15b) & z4 = '' & read,z4
	c1 = 'type zero of x-axis (physical) [' + strtrim(plusx,2) + ']'
	print, form="($,50a)",'      ',c1,string("15b) & z5 = '' & read,z5
	c1 = 'type zero of y-axis (physical) [' + strtrim(plusy,2) + ']'
	print, form="($,50a)",'      ',c1,string("15b) & z6 = '' & read,z6
	if z1 eq '' or z1 eq string("12b) then z1 = '0'
	if z2 eq '' or z2 eq string("12b) then z2 = '1'
	if z3 eq '' or z3 eq string("12b) then z3 = '0'
	if z4 eq '' or z4 eq string("12b) then z4 = '1'
	if z5 eq '' or z5 eq string("12b) then z5 = '0'
	if z6 eq '' or z6 eq string("12b) then z6 = '0'
	zerox = fix(z1) & zeroy = fix(z3) & xfac = float(z2) & yfac = float(z4)
	plusx = float(z5) & plusy = float(z6)
	if form eq form1 or form eq form2 then form = form3
	if form eq form4 or form eq form5 or form eq form7 then form = form6
      endif
    end
    'S': begin
      print, 'user defined special transformations'
    end
    ':': begin
      print, form="($,a,'type destination coordinates')",string("12b)
      i1=0. & j1=0. & read,i1,j1
      i = fix((i1-plusx)/xfac+zerox) & j = fix((j1-plusy)/yfac+zeroy)
    end
    'a': print, form="($,a)",string("12b)
    'i': print, form="($,a)",string("12b)
    's': begin
      xpos = (i-zerox)*xfac+plusx & ypos = (j-zeroy)*yfac+plusy
      snum = snum + 1 & i1 = strcompress(xpos) & j1 = strcompress(ypos)
      if filopn eq 0 then begin
	c1 = findfile('coords_tmp',count=nfil)
	case nfil of
	  0: openw,u,'coords_tmp'
	  else: openu,u,'coords_tmp',/append
	endcase
	filopn = 1
      endif
      if not imgflg then printf,u,i1,' ',j1,snum
      if imgflg then printf,u,i1,' ',j1,' ',image(i,j)
      print, form="($,a)",string("12b)
    end
    '!': begin
      c1 = '' & print, form="($,a,'%')",string("12b) & read, c1 & spawn,c1
    end
    'q': begin
      print, form="($,a)",string("12b) & return
    end
    else: print, 'h(<-) j(\/) k(^) l(->) ... x(mouse[MB3-exit]) ?(help) q(quit)'
  endcase
  i = i mod xx & j = j mod yy
  if i lt 0 then i = xx-1 & if j lt 0 then j = yy-1
  oldi(1) = oldi(0) & oldj(1) = oldj(0) & oldi(0) = i & oldj(0) = j
  xpos = (i-zerox)*xfac+plusx & ypos = (j-zeroy)*yfac+plusy
  if not imgflg then print,form=form,xpos,ypos,cr1,cr2 & tvcrs,i,j
  if imgflg then print,form=form,xpos,ypos,image(i,j),cr1,cr2
endwhile

free_lun,u

return
end
