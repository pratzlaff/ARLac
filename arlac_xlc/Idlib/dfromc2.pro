function dfromc2,p0,xc,yc,pout,iout,chkall=chkall,verbose=verbose, _extra=e
;+
;function	dfromc2
;	return the minimum distance, in a 2D plane, of a given point
;	from an irregular curve
;
;syntax
;	dmin=dfromc2(p0,xc,yc,pout,iout,chkall=chkall,verbose=verbose,$
;	xtretch=xtretch)
;
;parameters
;	p0	[INPUT; required] 2-element array of location (x0,y0) of
;		reference point
;	xc	[INPUT; required] x-coordinates of points defining the
;		irregular curve
;	yc	[INPUT; required] y-coordinates of points defining the
;		irregular curve
;		* YC must match size of XC
;		* both XC and YC are assumed to be ordered in the proper
;		  sequence, whatever that may be
;	pout	[OUTPUT] 2-element array of the location of the nearest
;		point to P0 on the curve YC(XC)
;	iout	[OUTPUT] a float index indicating the location of POUT
;		along YC(XC)
;
;keywords
;	chkall	[INPUT] if set, looks at every line segment of the curve
;		* if not set (i.e., the default) then looks only in the
;		  vicinity of the point on YC(XC) that is closest to P0
;		* if set to a negative integer, then stops after checking
;		  the -CHKALL nearest points to P0 on YC(XC)
;	verbose	[INPUT] controls chatter, throws up plots, etc.
;	_extra	[INPUT ONLY] pass defined keywords to subroutines
;		[DFROML2] XTRETCH
;
;description
;	first finds the point on YC(XC) that is closest to P0, sat P_i.
;	then looks for point nearest to P0 on the lines (P_(i-1)->P_i)
;	and (P_i->P_(i+1)) using DFROML2.  if CHKALL is set to a +ve
;	number, does the same check for all the line segments in YC(XC).
;	if CHKALL is set to a -ve number, does the same checks, but in
;	the sequence of increasing distances from P0 of points of YC(XC).
;
;restrictions
;	requires subroutine DFROML2
;
;history
;	vinay kashyap (Jul01)
;	added parameter IOUT (VK; Aug01)
;-

;	usage
ok='ok' & np=n_params() & n0=n_elements(p0)
nx=n_elements(xc) & ny=n_elements(yc)
if np lt 3 then ok='Insufficient input parameters' else $
 if n0 eq 0 then ok='reference point P0 not defined' else $
  if nx eq 0 then ok='XC not defined' else $
   if ny eq 0 then ok='YC(XC) not defined' else $
    if nx ne ny then ok='YC not compatible with XC'
if ok ne 'ok' then begin
  print,'Usage: dmin=dfromc2(p0,xc,yc,pout,iout,chkall=chkall,verbose=verbose,$'
  print,'       xtretch=xtretch)'
  print,'  return minimum distance from reference point P0 to'
  print,'  irregular curve YC(XC)'
  if np ne 0 then message,ok,/info
  return,-1L
endif

;	keywords
chkpt=0L
if n_elements(chkall) gt 0 then chkpt=long(chkall[0])
vv=0L & if keyword_set(verbose) then vv=long(verbose[0]) > 1

;	extract relevant info from inputs
x0=p0[0] & if n0 gt 1 then y0=p0[1] else y0=0.
dist=sqrt((x0-xc)^2+(y0-yc)^2) & os=sort(dist)
im=os[0] & dmin=dist[im] & pout=[xc[im],yc[im]] & iout=im
if vv gt 2 then message,'Dmin='+strtrim(dmin,2)+' @ I='+strtrim(im,2),/info

;	go forth and find the minimum distance!
if chkpt le 0 then begin		;(cascade down increasing distances

  i=0L
  while i ge 0L do begin			;{check each point
    im=os[i] & d_min=dist[im] & p1=[xc[im],yc[im]]
    if im gt 0 then begin
      p2=[xc[im-1L],yc[im-1L]]
      dA=dfroml2(p0,p1,p2,pA,iA, _extra=e)
      ;	check to see if it is still within the interval
      if (iA ge 0 and iA le 1) and dA lt dmin then begin
	dmin=dA & pout=pA & iout=im-iA
      endif
      if vv gt 3 then message,'D@I='+strtrim(dA,2)+' @ '+strtrim(im,2)+'-',/info
      if vv gt 10 then begin
	plot,xc,yc,psym=-7,/xs,/ys
	oplot,[p1[0],p2[0]],[p1[1],p2[1]],thick=3
	oplot,[p0[0],pA[0]],[p0[1],pA[1]],thick=2
	if vv gt 30 then begin
	  c='hit any key to continue, z to stop' & print,c & c=get_kbrd(1)
	  if strlowcase(c) eq 'z' then stop,'Halting.  type .CON to continue'
	endif
      endif
    endif
    if im lt nx-1L then begin
      p2=[xc[im+1L],yc[im+1L]]
      dB=dfroml2(p0,p1,p2,pB,iB)
      ;	check to see if it is still within the interval
      if (iB ge 0 and iB le 1) and dB lt dmin then begin
	dmin=dB & pout=pB & iout=im+iB
      endif
      if vv gt 3 then message,'D@I='+strtrim(dB,2)+' @ '+strtrim(im,2)+'+',/info
      if vv gt 10 then begin
	plot,xc,yc,psym=-7,/xs,/ys
	oplot,[p1[0],p2[0]],[p1[1],p2[1]],thick=3
	oplot,[p0[0],pB[0]],[p0[1],pB[1]],thick=2
	if vv gt 30 then begin
	  c='hit any key to continue, z to stop' & print,c & c=get_kbrd(1)
	  if strlowcase(c) eq 'z' then stop,'Halting.  type .CON to continue'
	endif
      endif
    endif
    i=i+1L
    ;	stopping rule
    if i ge -chkpt then i=-1L
    if i eq nx then i=-1L
  endwhile				;I>0}

endif else begin			;cascade)(look at all segments

  for i=0L,nx-2L do begin		;{for each segment
    p1=[xc[i],yc[i]] & p2=[xc[i+1L],yc[i+1L]]
    dC=dfroml2(p0,p1,p2,pC,iC)
    ; check to see if it is still within the interval
    if (iC ge 0 and iC le 1) and dC lt dmin then begin
      dmin=dC & pout=pC & iout=i+iC
    endif
    if vv gt 3 then message,'D@I='+strtrim(dC,2)+' @ '+strtrim(i,2),/info
      if vv gt 10 then begin
	plot,xc,yc,psym=-7,/xs,/ys
	oplot,[p1[0],p2[0]],[p1[1],p2[1]],thick=3
	oplot,[p0[0],pC[0]],[p0[1],pC[1]],thick=2
	if vv gt 30 then begin
	  c='hit any key to continue, z to stop' & print,c & c=get_kbrd(1)
	  if strlowcase(c) eq 'z' then stop,'Halting.  type .CON to continue'
	endif
      endif
  endfor				;I=0,NX-2}

endelse					;segments)

return,dmin
end
