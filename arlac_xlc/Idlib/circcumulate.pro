function circcumulate,xpos,ypos,rad,thresh, _extra=e
;+
;function	circcumulate
;	given a list of circles of various radii, figure out
;	the areal overlap between them and group all those
;	circles that overlap another by more than a specified
;	fraction, and return a unique list of indices that
;	identify the group to which each circle belongs
;
;syntax
;	ig=circcumulate(xpos,ypos,rad,thresh)
;
;parameters
;	xpos	[INPUT; required] x-positions of centers of circles
;	ypos	[INPUT; required] y-positions of centers of circles
;	rad	[INPUT; required] radii of circles, in same units
;		as XPOS and YPOS
;	thresh	[INPUT; default=0.1] the fraction of the area of a
;		circle that must be overlapped before the adjoining
;		circle gets pulled into its, er, circle
;
;keywords
;	_extra	[JUNK] here only to prevent crashing the program
;
;subroutines
;	CIRCOLAP()
;
;history
;	vinay kashyap (May2006)
;-

;	usage
ok='ok' & np=n_params()
nx=n_elements(xpos) & ny=n_elements(ypos) & nr=n_elements(rad)
if np lt 3 then ok='Insufficient parameters' else $
 if nx eq 0 then ok='XPOS is undefined' else $
  if ny eq 0 then ok='YPOS is undefined' else $
   if nr eq 0 then ok='RAD is undefined' else $
    if nx ne ny then ok='XPOS and YPOS are incompatible' else $
     if nx ne nr then ok='XPOS and RAD are incompatible' else $
      if nx eq 1 then ok='Require at least 2 circles as input'
if ok ne 'ok' then begin
  print,'Usage: ig=circcumulate(xpos,ypos,rad,thresh)'
  print,'  return group indices after accumulating circles'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	input
thr=0.1 & if n_elements(thresh) ne 0 then thr=float(abs(thresh[0]))
if thr eq 0 then thr=0.1

;	output
ig=lonarr(nx)-1L & ik=-1L & ii=lindgen(nx)

for i=0L,nx-1L do begin		;{for each circle in the list

  oi=where(ii ne i,moi) & ok=where(ig lt 0,mok)
  if mok gt 0 then begin
    dsep=0.*xpos & farea=dsep
    dsep=sqrt((xpos[i]-xpos)^2+(ypos[i]-ypos)^2)
    farea=circolap(dsep,0*dsep+rad[i],rad)/!pi/rad[i]^2
    ooi=where(farea[oi] ge thr,mooi)
    oo=where(farea ge thr,moo)
    ;print,i,farea,ig
    if mooi gt 0 then begin		;(at least one extra match
      jg=[ig[i],ig[oo]] & oz=where(jg ge 0,moz)
      if moz gt 0 then begin
	zjg=jg[oz] & mg=min(zjg) & ig[i]=mg
        zujg=zjg[uniq(zjg,sort(zjg))] & nzujg=n_elements(zujg)
        for j=0L,nzujg-1L do begin
	  ooj=where(ig eq zujg[j]) & ig[ooj]=mg
        endfor
      endif else begin
	ik=ik+1L
	ig[oo]=ik
      endelse
    endif else begin			;one extra match)(no matches -- new group
      ik=ik+1L
      ig[i]=ik
    endelse				;new group)

    ;if moo gt 0 then begin
    ;  if ig[i] lt 0 then begin
;	ook=where(ig[oo] ge 0,mook)
;	if mook gt 0 then begin
;	  for ik=0,mook-1 do ig[oo[ook[ik]]]=min(ig[oo])
;	endif else begin
;          ik=ik+1L
;          ig[oo]=ik
;	endelse
    ;  endif else ig[oo]=ig[i]
    ;endif
    ;stop,ig

  endif

endfor				;I=0,NX-1}

return,ig
end
