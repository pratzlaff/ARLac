function probks,alam,nterm=nterm,eps1=eps1,eps2=eps2, _extra=e
;+
;function	probks
;	Kolmogorov-Smirnov probability function, based on NumRecC2, 14.3, 626
;
;parameters
;	alam	[INPUT; required] argument for Q_{KS}
;
;keywords
;	nterm	[INPUT; default=100] number of terms to include in series
;	eps1	[INPUT; default=0.001] convergence criterion
;	eps2	[INPUT; default=1e-8] another convergence criterion
;
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	translated to IDL by Vinay Kashyap (Oct95)
;	rewrote with keywords and all (VK;Mar98)
;	added keyword _EXTRA (VK; Nov98)
;-

;	usage
if n_elements(alam) ne 1 then begin
  print,'Usage: Qks=probks(alam,nterm=nterm,eps1=eps1,eps2=eps2)'
  print,'  return Kolmogorov-Smirnov probability (NumRec)'
  return,1.0
endif

;	keywords
if not keyword_set(nterm) then nt=100L else nt=(long(nterm)>2)
if not keyword_set(eps1) then e1=0.001 else e1=float(eps1)
if not keyword_set(eps2) then e2=1e-8 else e2=float(eps2)

;	initialize
fac=2.0 & sum=0. & termbf=0. & ksprob=0.0
a2=-2.*alam(0)^2

for i=1L,nt do begin		;{step through summation
  term=fac*exp(a2*i*i)
  ksprob=ksprob+term
  if abs(term) le e1*termbf or abs(term) le e2*ksprob then return,ksprob
  fac=-fac			;alternating signs in sum
  termbf=abs(term)
endfor				;I=1,NT}

ksprob=1.	;get here only by failing to converge

return,ksprob
end
