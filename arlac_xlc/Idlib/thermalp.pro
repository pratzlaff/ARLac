pro thermalp,t,p,kev=kev,logt=logt,elaine=elaine,rtv=rtv,hg=hg,rscode=rscode,$
	interp=interp,emin=emin,emax=emax,metals=metals
;+
;procedure	thermalp,t,p,/kev,/logt,[/elaine|/rtv|/hg|/rscode],$
;			emin=emin,emax=emax,metals=metals
;		returns the power emitted (p) by a cm^3 of gas at the given
;		temperature (t) as optically thin thermal radiation
;								vlk090492
;parameters	t	temperature [K (keV if so specified)]
;		p	P(T) (in erg cm^3 s^-1)
;
;keywords	kev	if set, t should be given in keV
;		logt	if set, log10(t) (in keV or K) should be given 
;		elaine	the fit used here is due to Elaine Chun
;		rtv	the fit used here is from Rosner, Tucker & Vaiana 1978,
;			ApJ 220, 643.
;		hg	the fit used here is from Holzer & MacGregor (1985,
;			in Mass Loss from Red Giants, ed. Morris & Zuckerman,
;			p229-255)
;		rscode	the Raymond-Smith Thermal Spectral code (1993) is used
;			(right now, works only on mhd3 & mhd5)
;		interp	if set, interpolates in metal abundances.  uses the
;			parametrization found by VK (7/94)
;		emin	lower limit of passband [keV] (only if RSCODE is set)
;		emax	upper limit of passband [keV] (only in RSCODE is set)
;		metals	metal abundances (He is held at Solar)
;			has no action unless INTERP or RSCODE is also set
;
;history	written by Vinay Kashyap (9/4/92)
;		added keyword hg (5/31/93; vk)
;		added keywords rscode, emin and emax (10/8/93; vk)
;		added keyword interp, support for interp={1,-1} (1/1/94 vk)
;		added keyword metals (7/6/94; vk)
;		modified action of INTERP and METALS to get P(T,Z) (7/10/94 vk)
;-

n1 = n_params(0)
if n1 eq 0 then begin
  print, 'Usage: thermalp,t,p,/kev,/logt,emin=emin,emax=emax,metals=metals$'
  print, '       [/elaine|/rtv|/hg|/interp|/rscode]'
  print, '  returns power emitted (p) by a cm^3 of gas at the specified'
  print, '  temperature (t) as optically thin thermal radiation' & return
endif

temp = float(t)
if keyword_set(logt) then temp = 10.^(temp)
if keyword_set(kev) then begin
  temp = temp*1e3 					;keV --> eV
  temp = temp * 1.6021892e-12				;eV --> erg
  temp = temp / 1.380662e-16				;erg --> K
endif
if keyword_set(metals) then Z = metals else Z = 1.
if keyword_set(metals) and not keyword_set(rscode) then interp=1

t0 = 1e3 & t1 = 1e8 & p = -30.
temp = alog10(temp)

if 10^(temp) lt t0 or 10^(temp) gt t1 then begin
  print, 'reset temperature range! '+strtrim(temp,2)+' not within ['+$
	strtrim(alog10(t0),2)+','+strtrim(alog10(t1),2)+']'
  p = 10^p & return
endif

if keyword_set(elaine) then begin
  if temp ge 5.00 and temp lt 5.12 then p = -19.2673 - 0.393*temp
  if temp ge 5.12 and temp lt 5.42 then p = -22.1943 + 0.176*temp
  if temp ge 5.42 and temp lt 5.54 then p = -05.8786 - 2.833*temp
  if temp ge 5.54 and temp lt 6.15 then p = -17.9975 - 0.68*temp
  if temp ge 6.15 and temp lt 6.24 then p = -22.0604 + 0.0134*temp
  if temp ge 6.24 and temp lt 6.57 then p = -12.3747 - 1.539*temp
  if temp ge 6.57 and temp lt 6.92 then p = -23.8713 + 0.2133*temp
  if temp ge 6.92 and temp lt 7.28 then p = -15.1535 - 1.052*temp
  if temp ge 7.28 and temp le 8.00 then p = -25.1897 + 0.325*temp
endif

if keyword_set(rtv) then begin
  if temp gt 4.30 and temp le 4.60 then p = -21.85
  if temp gt 4.60 and temp le 4.90 then p = -31.00 + 2.*temp
  if temp gt 4.90 and temp le 5.40 then p = -21.20
  if temp gt 5.40 and temp le 5.75 then p = -10.40 - 2.*temp
  if temp gt 5.75 and temp le 6.30 then p = -21.94
  if temp gt 6.30 and temp le 7.00 then p = -17.73 - (2./3.)*temp
endif

if keyword_set(hg) then begin
  p = -0.3 * exp(-100*(temp - 4.09)^2) +$
       2.5 * exp(-30 *(temp - 4.3)^2) +$
       4.5 * exp(-16 *(temp - 4.9)^2) +$
       4.5 * exp(-16 *(temp - 5.35)^2) +$
       2.0 * exp(-4  *(temp - 6.1)^2)
  p = alog10(p)-22.
endif

if keyword_set(interp) then begin
  ;P == P(T,Z) = P(T,0) + Z * P'(T)
  ;special case for backwards compatibility:
  if interp eq -1 and not keyword_set(metals) then Z = 1e-2
  tt = 10.^(temp)
  if temp ge 4.93 and temp le 8.0 then begin
    p0 = 2d-27*sqrt(tt) + 5d-25*exp(1672.84/sqrt(tt))
    if tt ge 9e5 and tt le 1.85e6 then p0 = p0 + 3d-25
    pp = -19.-0.5*temp
    if temp ge 4.93 and temp lt 5.00 then pp = -26.3424 + 0.9954*temp
    if temp ge 5.00 and temp lt 5.10 then pp = -21.3739 + 0.0006*temp
    if temp ge 5.10 and temp lt 5.30 then pp = -23.3968 + 0.3971*temp
    if temp ge 5.30 and temp lt 5.41 then pp = -20.5778 - 0.1347*temp
    if temp ge 5.41 and temp lt 5.61 then pp = -06.6383 - 2.7116*temp
    if temp ge 5.61 and temp lt 5.86 then pp = -17.7652 - 0.7278*temp
    if temp ge 5.86 and temp lt 6.04 then pp = -23.1371 + 0.1894*temp
    if temp ge 6.04 and temp lt 6.23 then pp = -21.0372 - 0.1575*temp
    if temp ge 6.23 and temp lt 6.59 then pp = -12.4683 - 1.5313*temp
    if temp ge 6.59 and temp lt 6.77 then pp = -21.7394 - 0.1232*temp
    if temp ge 6.77 and temp lt 6.83 then pp = -26.5275 + 0.5855*temp
    if temp ge 6.83 and temp lt 6.97 then pp = -18.0073 - 0.6597*temp
    if temp ge 6.97 and temp lt 7.24 then pp = -10.0141 - 1.8085*temp
    if temp ge 7.24 and temp lt 7.56 then pp = -15.9355 - 0.9915*temp
    if temp ge 7.56 and temp lt 7.60 then pp = -36.2535 + 1.6961*temp
    if temp ge 7.60 and temp le 8.00 then pp = -22.9527 - 0.0546*temp
    p = p0 + Z*10.^(pp)
    p = alog10(p)
  endif
  if temp lt 4.93 then begin
    c1 = 'P('+strtrim(tt,2)+',Z) is not well determined'
    if !quiet gt 0 then message,c1,/cont,/info
    xp0 = 2e-5*sqrt(8.6e4) + 5e-3*exp(1672.84/sqrt(8.6e4))
    xm1 = 6.31 & drop = xp0/xm1 & norm = (xm1-xp0)/xm1
    if temp le 3.64 then p = alog10(5.)-28.
    if temp gt 3.64 and temp le 3.9031 then p = 11.732*alog10(1.0606e-6*tt)
    if temp gt 3.9031 and temp le 4.301 then p = 6.1496*alog10(1.3972e-8*tt)
    if temp gt 4.301 and temp le 4.6 then p = alog10(1.41)-22.
    if temp gt 4.6 and temp le 4.9 then p = 2.*temp - 31.
    if temp gt 4.9 then p = alog10(6.31)-22.
    p = alog10(drop + Z*norm) + p
  endif
endif

if keyword_set(rscode) then begin
  tt = 1.380662d-16 * 10.^(temp)			;K --> erg
  tt = tt / 1.6021892d-12				;erg --> eV
  binmax = 2*tt & if binmax lt 1000. then binmax = 1000.
  binmin = 1e-3 * binmax & if binmin gt 1. then binmin = 1.
  if keyword_set(emin) then binmin = emin*1e3
  if keyword_set(emax) then binmax = emax*1e3
  nbin = fix(alog10((binmax-binmin)/10))*200 & if nbin gt 1000 then nbin = 1000
  binsyz = (binmax-binmin)/(nbin-1.) & dene = 10. & rf1 = 1. & absel = 0
  ;
  abun = [10.93,8.52,7.96,8.82,7.92,7.42,7.52,7.2,6.9,6.3,7.6,6.3]
  abun(1:11) = abun(1:11)+alog10(Z)
  parrst=[nbin,binmin,binsyz,0.,0.,0.,12.,0.,0.,0.,0.,0.,temp,dene,1.,0.,abun]
  ;
  print, 'calling RS Spectral code'
  parrst = float(parrst) & callrs,ptev,parrst=parrst,/clean
  p = total(ptev) & p = alog10(p)-23.
endif

p = 10^(p)
if n1 eq 1 then print, 'P(',strtrim(t,2),') = ',p,' erg cm^3 /s'

return
end
