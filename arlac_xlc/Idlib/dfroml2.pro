function dfroml2,p0,p1,p2,pout,iout,xtretch=xtretch,eps=eps, _extra=e
;+
;function	dfroml2
;	return the minimum distance, in a 2D plane, of a given point
;	from a line defined by 2 points
;
;syntax
;	dmin=dfroml2(p0,p1,p2,pout,iout,xtretch=xtretch)
;
;parameters
;	p0	[INPUT; required] 2-element array of location (x0,y0) of
;		reference point
;	p1	[INPUT; required] 2-element array denoting one of the
;		points defining the line (x1,y1)
;	p2	[INPUT; required] 2-element array denoting the other
;		point defining the line (x2,y2)
;	pout	[OUTPUT] 2-element array of the location of the nearest
;		point to P0 on the line
;		* to pick the closest point _on_ the line segment (P1->P2),
;		  use the index IOUT below:
;		  - if IOUT<0 then the closest point must be P1
;		  - if IOUT>1 then the closest point must be P2
;	iout	[OUTPUT] a float index denoting where on the line (P1->P2)
;		does POUT lie (with 0==P1 and 1==P2)
;
;keywords
;	xtretch	[INPUT] a factor by which to "stretch" the X-axis
;		* if 0 or not set, taken to be 1.0, of course
;		* if -ve, absolute value is used
;		* comes in handy if the axes are in different units
;		  and/or scales
;	eps	[INPUT] a small number
;		* default is 1e-6
;	_extra	[JUNK] here only to avoid crashing the program
;
;description
;	we want the distance from (x0,y0) to some point defined by
;	y=mx+c, where obviously, c=(y1-((y2-y1)/(x2-x1))*x1), and
;	m=(y2-y1)/(x2-x1)
;	now minimizing d^2=(x-x0)^2+(mx+c-y0)^2, i.e., setting
;	d(d^2)/dx=0, we get x=(m*y0+x0-m*c)/(1+m^2)
;
;	of course, when m is \infty, then the solution is trivial --
;	x=x1=x2, y=y0, d_min=abs(x1-x0)
;
;history
;	vinay kashyap (Jul01)
;	added parameter IOUT and keyword EPS (VK; Aug01)
;-

;	usage
ok='ok' & np=n_params()
n0=n_elements(p0) & n1=n_elements(p1) & n2=n_elements(p2)
if np lt 3 then ok='Insufficient parameters' else $
 if n0 eq 0 then ok='Reference point P0 not defined' else $
  if n1 eq 0 then ok='point P1 not defined' else $
   if n2 eq 0 then ok='point P2 not defined' else $
    if n0 ne 2 then ok='P0 not in form [x0,y0]' else $
     if n1 ne 2 then ok='P1 not in form [x1,y1]' else $
      if n2 ne 2 then ok='P2 not in form [x2,y2]'
if ok ne 'ok' then begin
  print,'Usage: dmin=dfroml2(p0,p1,p2,pout,iout,xtretch=xtretch)'
  print,'  return minimum distance from reference point P0 to line'
  print,'  defined by points P1,P2'
  if np ne 0 then message,ok,/info
  return,-1L
endif

;	keywords
stretchx=1.0
if keyword_set(xtretch) then stretchx=1.0*abs(xtretch[0])
epsilon=1e-6 & if keyword_set(eps) then epsilon=eps[0]

;	disentangle the inputs
x0=p0[0]*stretchx & if n0 gt 1 then y0=p0[1] else y0=0.
x1=p1[0]*stretchx & if n1 gt 1 then y1=p1[1] else y1=0.
x2=p2[0]*stretchx & if n2 gt 1 then y2=p2[1] else y2=0.

;	what is the line?
dx=(x2-x1)+0.
if abs(dx) le epsilon then begin
  ;	slope must be infinity..  (this is the trivial case)
  xout=x1 & yout=y0
  pout=[xout/stretchx,yout]
  if y1 ne y2 then iout=float(yout-y1)/float(y2-y1) else iout=0.
  dmin=abs(xout-x0)/stretchx
endif else begin
  m=(y2-y1)/dx
  c=y1-m*x1
  xout=(m*y0+x0-m*c)/(1.+m^2)
  yout=m*xout+c
  pout=[xout/stretchx,yout]
  th=atan(m)
  xA=x1*cos(th)+y1*sin(th) & yA=-x1*sin(th)+y1*cos(th)
  xB=x2*cos(th)+y2*sin(th) & yB=-x2*sin(th)+y2*cos(th)
  xO=xout*cos(th)+yout*sin(th) & yO=-xout*sin(th)+yout*cos(th)
  if xA ne XB then iout=float(xO-xA)/float(xB-xA) else iout=0.
  dmin=sqrt(((xout-x0)/stretchx)^2+(yout-y0)^2)
endelse

return,dmin
end
