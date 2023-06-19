function rosatpsf,x,y,kev,z,bl=bl,nstp=nstp,wdth=wdth,offx=offx,fwhm=fwhm,$
	cumul=cumul,instr=instr
;+
;FUNCTION	ROSATPSf
;		retruns the normalized point spread function for the ROSAT
;		PSPC or HRI at given energy and off-axis source position
;		[cts/arcsec^2]
;
;PARAMETERS     X       x pixel position                        *input*
;               Y       y pixel position                        *input*
;               KEV     energy at which to calculate PSF [keV]  *input*
;               Z       distance from source [arcsec]           *output*
;
;KEYWORDS       BL      blocking factor for x,y (default=30)
;               NSTP    number of steps to take from source position to
;                       "edge" (default=1024)
;               WDTH    width of each step [arcsec] (default=1.)
;               OFFX    off-axis angular position [arcmin]	*output*
;               FWHM    full-width at half-maximum [arcsec]	*output*
;               CUMUL   if set, returns $\int{0}{R} 2 \pi r dr psf$
;		INSTR	'PSPC' or 'HRI' (default='PSPC'; HRI not yet
;			implemented)
;
;REFERNCES	PSPC:
;	Hasinger, G., Boesse, G., Predehl, P., Turner, J., Yusaf, R., George,
;	I.M.\ \& Rohrbach, G.\ 1993, MPE/OGIP Calibration Memo CAL/ROS/93-015,
;	in Legacy, 9
;	IRAF/PROS(2.3).xray> help prfrospspc
;		HRI:
;	http://heasarc.gsfc.nasa.gov/0/docs/rosat/newsletters/Contents10.html
;
;HISTORY        PSPC PSF based on Hasinger et al. (1993) and PROS documentation
;		HRI PSF based on article in Lagacy 10, 1994
;		written by Vinay Kashyap 4/18/94
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: psf = rosatpsf(x,y,kev,z,bl=bl,nstp=nstp,wdth=wdth,offx=offx,'
  print, '  fwhm=fwhm,/cumul,instr=instr)'
  print, '       returns normalized PSF [/arcsec^2] for PSPC/HRI'
  return,0L
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
if keyword_set(instr) then det=instr else det='PSPC'
if det ne 'PSPC' and det ne 'HRI' then det = 'PSPC'
if det eq 'PSPC' then begin
  xr = 15360.		;width of image in full-res. pixels
  pixang = 0.5		;angular size of 1 full-res. pixel [arcsec]
endif
if det eq 'HRI' then begin
  print, 'sorry, not implemented yet' & return, 0L
  xr = 8640.		;???width of image in full-res. pixels
  pixang = 0.5		;???angular size of 1 full-res. pixel [arcsec]
endif

yr = xr & x0 = pixang*xr/block & y0 = x0
z = findgen(steps)*stpsz

c1 = 'rosatpsf('+strtrim(x,2)+','+strtrim(y,2)+','+strtrim(kev,2)+',bl='+$
        strtrim(block,2)+',nstp='+strtrim(steps,2)+',wdth='+strtrim(stpsz,2)
if !quiet eq 1 then print, c1+')'
if keyword_set(offx) then c1 = c1 + ',/offx'
if keyword_set(fwhm) then c1 = c1 + ',/fwhm'
if keyword_set(cumul) then c1 = c1 + ',/cumul'
if keyword_set(instr) then c1 = c1 + ',instr='+det
if !quiet ge 2 then print,c1+')'

;compute the off-axis angle
dx = x-x0 & dy = y-y0                                   ;[pixels]
dx = dx*block & dy = dy*block                           ;[full res. pixels]
offx = sqrt(dx^2+dy^2)                                  ;[full res. pixels]
offx = offx*pixang/60.                                  ;[arcmin]

pspc:
if det eq 'HRI' then goto, hri
;==================================================================
;PSPC PSF variables
;==================================================================
	;scattering term
f_sc = 0.075 * kev^(1.43)
			;fraction of photons in this component
z_b = 861.9/kev	;change of scattering PSF from lorentzian to
			;power-law [arcsec]
z_sc = 79.9/kev	;width of lorentzian [arcsec]
zed = z_b/z_sc
alpha = 2.119 + 0.212 * kev
			;PSF power-law index
i1 = alog(1.+4*zed^2) & i2 = 2*zed^2 ;*(1.+16.*zed^2)
  ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ;NOTE: The Hasinger et al. (1993) memo has this factor (1.+16*(z_b/z_sc)^2)
  ;which is (a) missing in the PROS documentation (help prfrospspc), (b) causes
  ;a *large* discrepancy with previous versions, (c) incompatible with magnitude
  ;of scattering component of PSF in Fig 4d of memo, and (d) incompatible with
  ;integral normalization (integral over all space must=f_sc) of the component.
  ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
i3 = (alpha-2.)*(zed^2+0.25) & i0 = !pi * (z_sc/2.)^2
I_sc = i0 * (i1 + i2/i3)
			;renormalization factor
A_sc = f_sc/I_sc	;normalization [cts/arcsec^2]

	;exponential focus & penetration depth term
f1 = -1.635+0.639*kev+0.052*kev^2 & f2 = -0.5*(offx/12.)^2
f_xp = 10.^(f1) * exp(f2) & f3 = 1.-f_sc
if f_xp gt f3 then f_xp = f3
			;fraction of photons in this component
z_tau = sqrt(50.61*kev^(-1.472)+6.80*kev^(5.62))
			;e-folding 'angle' [arcsec]
A_xp = f_xp/(2.*!pi*z_tau^2)
			;normalization [cts/arcsec^2]

	;gaussian intrinsic resolution and mirror blur term
f_gm = 1.-f_sc-f_xp
			;fraction of photons in this component
z_sig = sqrt(108.7*kev^(-0.888)+1.121*kev^6)
			;detector gaussian [arcsec]
m_sig = sqrt(0.219*offx^(2.848))
			;mirror gaussian [arcsec]
G_sig = sqrt(z_sig^2+m_sig^2)
			;total spread [arcsec]
A_gm = f_gm / (2.*!pi*G_sig^2)
			;normalization [cts/arcsec^2]

;------------------------------------------------------------------
;PSPC PSF
;------------------------------------------------------------------

;MIRROR SCATTERING TERM
psf_sc = z*0.
hl = where(z le z_b) & hp = where(z gt z_b)
if hl(0) ne -1 then psf_sc(hl) = A_sc/(1.+(2.*z(hl)/z_sc)^2)
if hp(0) ne -1 then begin
  psf_sc(hp) = (A_sc/(1.+(2.*zed)^2))*(z(hp)/z_b)^(-alpha)
endif

;EXPONENTIAL FOCUS AND PENETRATION DEPTH TERM
psf_xp = z*0.
zz = z/z_tau & h1 = where(zz lt 100.)
psf_xp(h1) = A_xp * exp(-zz(h1))

;GAUSSIAN INTRINSIC RESOLUTION AND MIRROR BLUR TERM
psf_gm = z*0.
zz = 0.5*(z/G_sig)^2 & h1 = where(zz lt 100.)
  ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ;NOTE: The Hasinger et al. (1993) memo has this as 0.5*(z/z_sig)^2,
  ;which is patently absurd.  I have substituted G_sig for z_sig, and
  ;have found a much better agreement with previous PSFs.
  ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
psf_gm(h1) = A_gm * exp(-zz(h1))

;OVERALL PSPC PSF
psf = psf_sc + psf_xp + psf_gm

hri:
if det eq 'PSPC' then goto, rosat
;==================================================================
;HRI variables
;==================================================================
s1 = 2.18 		;[arcsec]
s2 = 3.3 + 0.019*offx - 0.016*offx^2 + 0.0044*offx^3
			;[arcsec]
s3 = 31.7 		;[arcsec]
A1 = 0.96 & A2 = 0.18 & A3 = 0.0009

;------------------------------------------------------------------
;HRI PSF
;------------------------------------------------------------------

psf = 0.*z
zz=0.5*(z/s1)^2 & h1=where(zz lt 100.) & psf(h1)=A1*exp(-zz(h1))
zz=0.5*(z/s2)^2 & h1=where(zz lt 100.) & psf(h1)=psf(h1)+A2*exp(-zz(h1))
zz=z/s3 & h1=where(zz lt 100.) & psf(h1)=psf(h1)+A3*exp(-zz(h1))
;what are the units?  nowhere is it mentioned what the units are.
;I am assuming [/arcsec^2] until it is found otherwise!

;==================================================================
;OK, PSF calculated

rosat:
;		Full-Width at Half-Maximum
mx = psf(0) & hmx = mx/2. & h1=where(psf ge hmx) & h2=where(psf le hmx)
i1 = max(h1) & i2 = h2(0) & if i2 eq -1 then i2 = i1
fwhm = 2.*(z(i1) + (z(i1)-z(i2))*(hmx-psf(i2))/(psf(i1)-psf(i2)))
							;[arcsec]
if !quiet ge 2 then print, 'fwhm=',strtrim(fwhm,2),' arcsec'

;h1 = where(psf lt 1d-9) & if h1(0) ne -1 then psf(h1) = 0.

;		Encircled energy fraction
if keyword_set(cumul) then begin
  pc = 0.*psf & for i=1,steps-1 do pc(i) = pc(i-1)+psf(i)*2*!pi*z(i)*stpsz
  psf = pc < 1.                         ;get rid of round-off errors
endif

return,psf
end
