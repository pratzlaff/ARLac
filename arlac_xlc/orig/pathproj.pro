function pathproj,offset,minrad,rfunct=rfunct,sclht=sclht,$
	maxrad=maxrad,nstep=nstep,halfsh=halfsh,coneang=coneang,$
	verbose=verbose, _extra=e
;+
;function	pathproj
;	projects the intensity along a line-of-sight (LOS) through a stellar
;	atmosphere onto a plane
;
;parameters
;	offset	[INPUT; required] offset of the LOS from center
;	minrad	[INPUT] radius of opaque sphere (default=0)
;
;keywords
;	rfunct	[INPUT] function describing intensity variation along the
;		radius
;		* 'EXP' ==> exponential drop-off (see SCLHT)
;		* 'CONST' ==> constant (the default)
;		* 'INVSQ' ==> inverse square
;	sclht	[INPUT] scale height for exponential drop-off of intensity
;	maxrad	[INPUT] maximum distance to which to integrate
;		* default=2*minrad>1
;	nstep	[INPUT] number of steps along the LOS
;		* default=1001L
;		* if -ve, steps are logarithmic
;	halfsh	[INPUT] if set, does not double up past the edge of the
;		opaque inner sphere
;	coneang	[INPUT] if given, confines the integral over the LOS to
;		be within (+ve) or without (-ve) the given cone.
;		* must be in degrees in the range [0,90]
;	verbose	[INPUT] controls chatter
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap (MIM.XI)
;	added keyword HALFSH (VK; MayMM)
;	added INVSQ option to RFUNCT (VK; JunMM)
;	added keywords CONEANG and VERBOSE, allowed OFFSET to be array (VK; IMVIM.I)
;-

;	usage
noff=n_elements(offset)
if noff eq 0 then begin
  print,'Usage: projected_intensity=pathproj(offset,minrad,rfunct=rfunct,$'
  print,'       sclht=sclht,maxrad=maxrad,nstep=nstep,/halfsh,coneang=coneang,$'
  print,'       verbose=verbose)'
  print,'  projects the intensity along a line-of-sight through a stellar'
  print,'  atmosphere onto a plane'
  return,0.
endif

;	inputs
d=0. & r0=0. & r1=2.*r0 > 1. & h=(r1-r0) > 1. & funct='const'
dl=(r1-r0)/(100.-1.) & dlog=0 & nlos=1001L
dx=offset(0) & dy=0. & if noff gt 1 then dy=offset(1) & dd=sqrt(dx^2+dy^2)
if n_elements(minrad) gt 0 then r0=minrad(0)
if n_elements(maxrad) gt 0 then r1=maxrad(0) > r0
if keyword_set(sclht) then h=sclht(0)
if n_elements(rfunct) gt 0 then funct=strlowcase(strtrim(rfunct(0),2))
if keyword_set(nstep) then nlos=nstep(0)
if nlos lt 0 then begin & dlog=1 & nlos=-nlos & endif
thetamin=0. & thetamax=90.
if keyword_set(coneang) then begin
  if coneang(0) gt 0 then thetamax=(coneang(0) mod 90) else $
    thetamin=(abs(coneang(0)) mod 90)
endif
;if thetamin gt 0 then r00=dd/cos(thetamin*!dpi/180.) else r00=r0
;if thetamax lt 90 then r10=dd/cos(thetamax*!dpi/180.) else r10=r1
;if r00 gt r0 then r0=r00
;if r10 lt r1 then r1=r10
vv=0 & if keyword_set(verbose) then vv=long(verbose(0))>1

;	calculate points along line-of-sight
if dd gt r1 then return,0.	;why bother?
if r0 ge dd then l0=sqrt(r0^2-dd^2) else l0=0.
if r1 ge dd then l1=sqrt(r1^2-dd^2) else l1=0.
if l1 le l0 then return,0.	;no need to bother
if dlog eq 1 then begin
  lmax=alog(l1)
  if l0 gt 0 then lmin=alog(l0) else lmin=lmax-6.
  dl=(lmax-lmin)/abs(nlos)
  los=findgen(abs(nlos)+1L)*dl+lmin & los=exp(los)
  if l0 eq 0 then los=[l0,los]
endif else begin
  dl=(l1-l0)/nlos & los=findgen(nlos+1L)*dl+l0
endelse
ll=0.5*(los(1:*)+los) & dlos=los(1:*)-los

;	now translate LOS into R and get THETA
rr=sqrt(los^2+dd^2) ;& drr=abs(rr(1:*)-rr)
r=0.5*(rr(1:*)+rr)
xx=0*los+dx & yy=0*los+dy
th=acos(sqrt(xx^2+los^2)/sqrt(xx^2+yy^2+los^2))*180./!pi
ok=where(th ge thetamin and th le thetamax,mok)
if mok eq 0 then return,0.	;not in interesting region

;	and figure out the intensity function
case funct of
  'bradw': begin
    message,'waiting for Brad to supply functional form',/info
  end
  'invsq': begin		;inverse square
    ff=0.*r & oo=where(r gt r0,moo)
    if moo gt 0 then ff[oo]=1./r[oo]^2
  end
  'exp': ff=exp(-(r-r0)/h)	;exponential drop-off
  else: ff=0.*r + 1.		;constant, by default
endcase

;	and now build up the integrand
;pp=ff*r*drr/ll
pp=ff(ok)*dlos

;	and the integral
p=total(pp)

;	and correction for half-shell transparency
if not keyword_set(halfsh) then $
  if dd ge r0 then p=2.*p

;	debug plots
if vv gt 50 then begin
  pmulti=!p.multi & !p.multi=[0,1,2]
  plot,los,pp,xtitle='line of sight'
  plot,rr,pp,xtitle='radius'
  !p.multi=pmulti
  if vv gt 100 then stop
endif

return,p
end
