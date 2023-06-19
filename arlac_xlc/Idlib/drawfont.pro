;From: zawodny@arbd0.larc.nasa.gov (Dr. Joseph M Zawodny)
;Subject: Re: QUESTION: special characters in postscript output
;Date: 11 Mar 1993 13:45:05 GMT
;
;In a somewhat related vain:
;	Here is a little routine I wrote up that creates a PostScript plot
;displaying the characters in a font and how theey map to the keyboard and
;their byte values.  A sample usage of this might be:
;
;IDL> !p.multi=[0,2,2,0,0]
;IDL> for k=3,20 do DRAWFONT,k
;
;This will draw all the available fonts (3 through 20) as they are cuurently
;defined 4 fonts to a page.
;
;There is also a .signature file at end of this message.
;-----cut here-----------cut here-----------cut here-----------cut here------
;;+
; NAME:
;	DRAWFONT
; PURPOSE:
;	Make a postscript file containing a display of the font
; CATEGORY:
;	Unknown
; CALLING SEQUENCE:
;	DRAWFONT,num
; INPUTS:
;	num	Font number (see the HELP,/DEVICE command)
; OUTPUTS:
;	None
; COMMON BLOCKS:
;	None
; SIDE EFFECTS:
;	Make a postscript file
; RESTRICTIONS:
;	None
; PROCEDURE:
;	STRAIGHTFORWARD (seems to be the default value of this field).
; MODIFICATION HISTORY:
;	Written Dec, 1991 by J. M. Zawodny
;		zawodny@arbd0.larc.nasa.gov
;-

pro DRAWFONT,num

	if (!d.name ne 'PS') then begin
		set_plot,'ps'
		device,xoff=.5,xsize=7.5,yoff=1.,ysize=9.,/inch
		!p.font=0
	endif

	!p.thick  = 5
	!x.range  = [0,10]
	!x.margin = [.12,.12]
	!x.style  = 5
	!y.range  = [0,10]
	!y.margin = [.1,.1]
	!y.style  = 5
	plot,[0,0,10,6,6,0],[0,10,10,10,9,9],/noclip	
	if(total(!p.multi) ne 0) then scale=.5 else scale=1.

	font = '!'+strtrim(fix(num),2)
	rfnt = '!3'
	titl = 'PS Font !'+font
	xyouts,3,9.15,titl,size=4*scale,align=.5
	for r=0,9 do begin
		y = 9.17-r
		for c=0,9 do begin
			if (r eq 0) and (c le 5) then goto,skip
			x    = c+.5
			char = string(27B+byte(c+10*r))
			if (char eq '!') then char = '!!'
			numb = strtrim(27+c+10*r,2)
			xyouts,x    ,y    ,font+char,align=.5,size=3*scale
			xyouts,x-.40,y+.63,rfnt+char,align=0.,size=1.25*scale
			xyouts,x+.40,y+.63,numb     ,align=1.,size=1.25*scale
			oplot,[0,1,1]+c,10-r-[1,1,0],/noclip	
skip:
		endfor
	endfor
return
end
