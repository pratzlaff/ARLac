function circolap,dsep,rad1,rad2,chord=chord,theta1=theta1,theta2=theta2,$
	d2ch1=d2ch1,d2ch2=d2ch2,cirstr=cirstr, _extra=e
;+
;function	circolap
;	compute and return the area of overlap between two circles
;
;syntax
;	area=circolap(dsep,rad1,rad2,chord=chord,theta1=theta1,$
;	theta2=theta2,d2ch1=d2ch1,d2ch2=d2ch2,cirstr=cirstr)
;
;parameters
;	dsep	[INPUT; required] separation between the circles
;	rad1	[INPUT; default=1] radius of first circle
;	rad2	[INPUT; default=RAD1] radius of second circle
;
;keywords
;	chord	[OUTPUT] the length of the chord that connects the
;		points of intersection of the two circles
;	theta1	[OUTPUT] the opening angle on circle 1 that subtends
;		the chord of intersection [deg]
;	theta2	[OUTPUT] the opening angle on circle 2 that subtends
;		the chord of intersection [deg]
;	d2ch1	[OUTPUT] perpendicular distance from center of circle 1
;		to CHORD
;	d2ch2	[OUTPUT] perpendicular distance from center of circle 2
;		to CHORD
;	cirstr	[OUTPUT] a structure containing all of the above outputs
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap (May2006)
;-

;	usage
ok='ok' & np=n_params() & nd=n_elements(dsep)
if np eq 0 then ok='Insufficient parameters' else $
 if nd eq 0 then ok='DSEP is undefined'
if ok ne 'ok' then begin
  print,'Usage: area=circolap(dsep,rad1,rad2,chord=chord,theta1=theta1,$'
  print,'       theta2=theta2,d2ch1=d2ch1,d2ch2=d2ch2,cirstr=cirstr)'
  print,'  compute and return area of overlap between two circles'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	inputs
nr1=n_elements(rad1) & nr2=n_elements(rad2)
r1=fltarr(nd)+1.
if nr1 gt 0 then r1[*]=rad1[0]
if nr1 gt 1 then r1[0L:(nr1<nd)-1L]=rad1[0L:(nr1<nd)-1L]
r2=r1
if nr2 gt 0 then r2[*]=rad2[0]
if nr2 gt 1 then r2[0L:(nr2<nd)-1L]=rad2[0L:(nr2<nd)-1L]

;	outputs
area=fltarr(nd)
chord=area & theta1=area & theta2=area & d2ch1=area & d2ch2=area

;	compute the chord lengths and areas

;	some special cases
ii=lonarr(nd)
ox=where(dsep gt r1+r2,mox) 		;no overlaps
oz=where(dsep le abs(r1-r2),moz)	;fully enclosed
if mox gt 0 then ii[ox]=-1 & if moz gt 0 then ii[oz]=-1
oo=where(ii ge 0,moo)			;the remainder

;	no overlap case
if mox gt 0 then begin
  area[ox]=0. & chord[ox]=0. & theta1[ox]=0. & theta2[ox]=0.
  d2ch1[ox]=!values.F_NAN & d2ch2[ox]=!values.F_NAN
endif
;	fully enclosed case
if moz gt 0 then begin
  area[oz]=!pi*r1[oz]^2 < (!pi*r2[oz]^2)
  chord[oz]=!values.F_NAN
  theta1[oz]=360. & theta2[oz]=360.
  d2ch1[oz]=!values.F_NAN & d2ch2[oz]=!values.F_NAN
endif
;	regular case
if moo gt 0 then begin
  xx=(dsep[oo]^2-r1[oo]^2+r2[oo]^2)/2./dsep[oo]
  yy=sqrt((-dsep[oo]+r1[oo]-r2[oo])*(-dsep[oo]-r1[oo]+r2[oo])*(-dsep[oo]+r1[oo]+r2[oo])*(dsep[oo]+r1[oo]+r2[oo]))/dsep[oo]
  area[oo]=r1[oo]^2*acos((dsep[oo]^2+r1[oo]^2-r2[oo]^2)/2./dsep[oo]/r1[oo]) +$
	   r2[oo]^2*acos((dsep[oo]^2-r1[oo]^2+r2[oo]^2)/2./dsep[oo]/r2[oo]) -$
	   sqrt((-dsep[oo]+r1[oo]+r2[oo])*(dsep[oo]+r1[oo]-r2[oo])*(dsep[oo]-r1[oo]+r2[oo])*(dsep[oo]+r1[oo]+r2[oo]))/2.
  chord[oo]=yy
  d2ch1[oo]=xx & d2ch2[oo]=dsep[oo]-xx
  theta1[oo]=atan(yy/2.,d2ch1[oo])*180./!pi
  theta2[oo]=atan(yy/2.,d2ch2[oo])*180./!pi
endif

;	output structure
cirstr=create_struct('DSEP',[dsep],'RAD1',r1,'RAD2',r2,$
	'OVERLAP',area,'CHORD',chord,'THETA1',theta1,'THETA2',theta2,$
	'D2CH1',d2ch1,'D2CH2',d2ch2)

return,area
end
