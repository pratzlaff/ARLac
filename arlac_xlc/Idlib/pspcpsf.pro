function pspcpsf,x,y,kev,z,bl=bl,nstp=nstp,wdth=wdth,offx=offx,fwhm=fwhm,$
	cumul=cumul
;+
;function	pspcpsf
;		obtains the normalized point spread function for the PSPC
;		at given energy and off-axis source position
;
;parameters	x	x pixel position			*input*
;		y	y pixel position			*input*
;		kev	energy at which to calculate PSF [keV]	*input*
;		z	distance from source [arcsec]		*output*
;
;keywords	bl	blocking factor for x,y (default=30)
;		nstp	number of steps to take from source position to
;			"edge" (default=1024)
;		wdth	width of each step [arcsec] (default=1.)
;		offx	output off-axis angular position [arcmin]
;		fwhm	full-width at half-maximum
;		cumul	if set, returns $\int{0}{R} 2 \pi r dr psf$
;
;history	based on VMS Fortran program PSFOFF of Hasinger et al.
;		conversion to IDL by Vinay Kashyap	{8/11/93}
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: psf = pspcpsf(x,y,kev,z,bl=bl,nstp=nstp,wdth=wdth,'
  print, '  offx=offx,fwhm=fwhm,/cumul)'
  print, '       obtain normalized PSF for PSPC' & return,0L
endif
if np eq 1 then begin
  y = x & kev = 1.
endif
if np eq 2 then kev = 1.

if kev lt 0.07 or kev gt 3. then begin
  print, 'photon energy out of bounds, defaulting to 1 keV' & kev = 1.
endif

if keyword_set(bl) then block=bl else block=30.
if keyword_set(nstp) then steps=nstp else steps=1024
if keyword_set(wdth) then stpsz=wdth else stpsz=1.

xr = 15360. & yr = xr
x0 = 0.5*xr/block & y0 = 0.5*yr/block
z = findgen(steps)*stpsz

c1 = 'pspcpsf('+strtrim(x,2)+','+strtrim(y,2)+','+strtrim(kev,2)+',bl='+$
	strtrim(block,2)+',nstp='+strtrim(steps,2)+',wdth='+strtrim(stpsz,2)
if !quiet ge 1 then print, c1+')'
if keyword_set(offx) then c1 = c1 + ',/offx'
if keyword_set(fwhm) then c1 = c1 + ',/fwhm'
if keyword_set(cumul) then c1 = c1 + ',/cumul'
if !quiet ge 2 then print,c1+')'

;compute the off-axis angle
dx = x-x0 & dy = y-y0					;[pixels]
dx = dx*block & dy = dy*block				;[full res. pixels]
offx = sqrt(dx^2+dy^2)					;[full res. pixels]
offx = offx*0.5/60.					;[arcmin]

;		get energy dependent parameters
;	exponential fraction
a2 = 10.^(-1.635+0.639*kev+0.052*kev^2)*exp(-0.5*(offx/12.)^2)
;	scattering fraction
a3 = 0.041*kev^(1.43)
;	avoid "exponential artefact"
if (1.-a3) lt a2 then a2 = 1.-a3
;	gaussian fraction
a1 = 1.-a2-a3
;	gaussian sigma, detector
sigdet2 = 108.7*kev^(-0.888)+1.121*kev^6
;	gaussian sigma, mirror
sigmir2 = 0.219*offx^(2.848)
;	total sigma
sigma=sqrt(sigdet2+sigmir2)
;	exponential e-folding angle
rc = sqrt(50.61*kev^(-1.472)+6.80*kev^(5.62))
;	scattering lorentzian break angles
break1 = 39.95/kev & break2 = 861.9/kev
;	scattering lorentzian slope
alpha2 = 2.119+0.212*kev
;	normalization by integrals 0-infinity
fnor1 = a1/(2.*!pi*sigma^2) & fnor2 = a2/(2.*!pi*rc^2)
b3 = (break2/break1)^2 & aux = 1.+b3
fnor3 = a3/(!pi*alog(aux)+2.*b3/(aux*(alpha2-2)))

;		calculate function
psf = z*0.
arg1 = 0.5*(z/sigma)^2 & arg1 = arg1 < 75.
arg2 = z/rc & arg2 = arg2 < 75.
psf = fnor1*exp(-arg1)+fnor2*exp(-arg2)
h1 = where(z le break2)
if h1(0) ne -1 then psf(h1) = psf(h1)+fnor3/(break1^2+z(h1)^2)
h1 = where(z gt break2)
if h1(0) ne -1 then begin
  zz = z & zz(h1) = break2
  psf(h1) = psf(h1)+(fnor3/(break1^2+zz(h1)^2))*(z(h1)/break2)^(-alpha2)
endif

mx = psf(0) & hmx = mx/2. & h1=where(psf ge hmx) & h2=where(psf le hmx)
i1 = max(h1) & i2 = h2(0) & if i2 eq -1 then i2 = i1
fwhm = 2.*(z(i1) + (z(i1)-z(i2))*(hmx-psf(i2))/(psf(i1)-psf(i2)))
if !quiet ge 2 then print, 'fwhm=',strtrim(fwhm,2)

h1 = where(psf lt 1d-9) & if h1(0) ne -1 then psf(h1) = 0.

if keyword_set(cumul) then begin
  pc = 0.*psf & for i=1,steps-1 do pc(i) = pc(i-1)+psf(i)*2*!pi*z(i)*stpsz
  psf = pc < 1.				;get rid of round-off errors
endif

return,psf
end
