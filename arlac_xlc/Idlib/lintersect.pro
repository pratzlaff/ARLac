function lintersect,y1,y2,x1,x2,verbose=verbose, _extra=e
;+
;function	lintersect
;	returns the locations where Y1(X1) intersects Y2(X2)
;
;parameters
;	y1	[INPUT; required] Y-coordinate values along curve 1
;	y2	[INPUT; required] Y-coordinate values along curve 2
;	x1	[INPUT] X-coordinate values for Y1
;		* if not given, or smaller in size than Y1, assumed to
;		  be LINDGEN(N_ELEMENTS(Y1))
;		* if larger in size than Y1, uses first N(Y1) elements
;	x2	[INPUT] X-coordinate values for Y2
;		* if not given, or smaller in size than Y1, assumed to
;		  be LINDGEN(N_ELEMENTS(Y2))
;		* if larger in size than Y2, uses first N(Y2) elements
;
;keywords
;	verbose	[INPUT] controls chatter
;	_extra	[JUNK] here only to avoid crashing the program
;
;examples
;
;history
;	vinay kashyap (jul2003)
;-

;	usage
ok='ok' & np=n_params() & ny1=n_elements(y1) & ny2=n_elements(y2)
if np lt 2 then ok='Insufficient parameters' else $
 if ny1 eq 0 then ok='Y1 is undefined' else $
  if ny2 eq 0 then ok='Y2 is undefined' else $
   if ny1 eq 1 then ok='Y1: cannot define a curve with one point' else $
    if ny2 eq 1 then ok='Y2: cannot define a curve with one point'
if ok ne 'ok' then begin
  print,'Usage: p=lintersect(y1,y2,x1,x2,verbose=verbose)'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	verbosity
vv=0 & if keyword_set(verbose) then vv=long(verbose[0])>1

;	define X1 and X2 if necessary
nx1=n_elements(x1) & ok1='ok'
if nx1 eq 0 then ok1='noX' else if nx1 ne ny1 then ok1='noXY'
if ok1 eq 'ok' then xx1=x1
if ok1 eq 'noX' then begin
  if vv gt 0 then message,'Assuming array indices of Y1 to be X1',/informational
  xx1=dindgen(ny1) & nx1=ny1
endif
if ok1 eq 'noXY' then begin
  if vv gt 0 then message,'X1 and Y1 are of different sizes',/informational
  xx1=dindgen(ny1)
  if nx1 gt ny1 then begin
    if vv gt 0 then message,'Using first '+strtrim(ny1,2)+$
	' elements of X1',/informational
    xx1=x1[0L:ny1-1L]
  endif else message,'Ignoring X1 as input; using array indices instead',$
	/informational
  nx1=ny1
endif
;
nx2=n_elements(x2) & ok2='ok'
if nx2 eq 0 then ok2='noX' else if nx2 ne ny2 then ok2='noXY'
if ok2 eq 'ok' then xx2=x2
if ok2 eq 'noX' then begin
  if vv gt 0 then message,'Assuming array indices of Y2 to be X2',/informational
  xx2=dindgen(ny2) & nx2=ny2
endif
if ok2 eq 'noXY' then begin
  if vv gt 0 then message,'X2 and Y2 are of different sizes',/informational
  xx2=dindgen(ny2)
  if nx2 gt ny2 then begin
    if vv gt 0 then message,'Using first '+strtrim(ny2,2)+$
	' elements of X2',/informational
    xx2=x2[0L:ny2-1L]
  endif else message,'Ignoring X2 as input; using array indices instead',$
	/informational
  nx2=ny2
endif

;	the basic algorithm is to first find the value of Y2 at locations X1
;	(or Y1 at X2, depending on which has more points), then look at the
;	difference in the Y-coordinates, dY, and find X-locations where dY
;	is 0.

if ny1 gt ny2 then begin
  xx=xx1 & yy=interpol(y2,xx2,xx) & dY=yy-y1
endif else begin
  xx=xx2 & yy=interpol(y1,xx1,xx) & dY=yy-y2
endelse
;
x0=interpol(xx,dY,0)
y0=interpol(yy,xx,x0)
n0=n_elements(x0)

;	plot
if vv gt 5 then begin
  plot,x1,y1 & oplot,x2,y2,line=2,thick=2 & oplot,[x0],[y0],psym=2,symsize=2
endif

;	output
p=fltarr(2,n0) & p[0,*]=x0[*] & p[1,*]=y0[*]

return,p
end
