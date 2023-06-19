function xgflux,spec,kev=kev,emin=emin,emax=emax,colden=colden,lat=lat,$
	unabsfx=unabsfx,parxgx=parxgx,help=help
;+
;function	xgflux
;		returns the diffuse extragalactic X-ray flux in the
;		given passband [ergs/s/cm^2/deg^2]
;
;parameters	spec	diffuse extragalactic X-ray spectrum in the given
;			passband [ergs/s/cm^2/keV/deg^2]
;
;keywords	kev	values at which the spectrum is computed [keV]
;		emin	lower bound on passband {0.15 [keV]}
;		emax	upper bound on passband {0.28 [keV]}
;		colden	column density of absorption [cm^-2]
;			if scalar, = N_H, and N_{H_2} = 0.26 * N_H
;			if vector, [N_H, N_{H_2}]
;		lat	galactic latitude [degrees]
;			if set, compute column densities using Bloemen model
;			overrides scalar COLDEN settings
;		unabsfx	unabsorbed flux [ergs/s/cm^2/deg^2]
;		parxgx	array containing parameters for spectrum model
;			parxgx(0): model number
;		help	print usage information
;-

np = n_params(0)

if keyword_set(emin) then e0 = emin else e0 = 0.15
if keyword_set(emax) then e1 = emax else e1 = 0.28
if not keyword_set(parxgx) then parxgx = 1.

db = [ 1., 5., 7.7, 1.4, e0, e1, 1000.,$
       2., 7., 9.5, 0.7, 2.2e6, 3.5e-3, e0, e1, 1000.,$
       3., 6., 5.6, 0.29, 40., e0, e1, 1000.]
pr = [ 'normalization [ph/s/cm^2/keV/sr]', 'power law index [E^(-indx)]',$
       'E_min [keV]', 'E_max [keV]', 'number of bins',$
       'power law normalization [ph/s/cm^2/keV/sr]', 'power law index',$
       'thermal emission temperature [K]', 'thermal emission EM [cm^-6 pc]',$
       'E_min [keV]', 'E_max [keV]', 'number of bins',$
       'normalization@3keV [ph/s/cm^2/keV/sr]', 'power law index',$
       'bremsstrahlung temperature [keV]', 'E_min [keV]', 'E_max [keV]',$
       'number of bins']

par = getpar(parxgx,dbase=db,ask=pr)

if keyword_set(help) then begin
  print, 'Usage: fx = xgflux(spec,kev=kev,emin=emin,emax=emax,colden=colden,$'
  print, '            lat=lat,parxgx=parxgx,/help) [ergs/s/cm^2/deg^2]'
  stop,'type help to see parameter values, .con to continue'
  rdvalue,'continue?',c1,'n',/ch & if c1 eq 'n' then return,0.
endif

;simple power law, extrapolated from higher energy observations:
;	dI/dE = norm * E^(-indx) ph/s/cm^2/keV/sr,
;	where (norm,indx) = (11.,1.4), (7.7,1.4), etc.
if par(0) eq 1. then begin
  norm = par(1) & indx = par(2) & e0 = par(3) & e1 = par(4) & bins = par(5)
  if bins lt 0 then begin
    bins = -bins & e0 = alog10(e0) & e1 = alog10(e1)
    if bins lt 100 then bins = 100
    de = (e1-e0)/(bins-1.) & kev = de*findgen(bins) + e0 & kev = exp(kev)
    e0 = 10.^(e0) & e1 = 10.^(e1)
  endif else begin
    if bins lt 100 then bins = 100
    de = (e1-e0)/(bins-1.) & kev = de*findgen(bins) + e0
  endelse
  ;power law spectrum
  spec = norm * kev^(-indx)			;[ph/s/cm^2/keV/sr]
  spec = temporary(spec) * kev * 1.602d-9	;[ergs/s/cm^2/keV/sr]
  spec = temporary(spec) * (!pi/180.)^2		;[ergs/s/cm^2/keV/deg^2]
  ;unabsorbed flux
  if indx-1. ne 1. then begin
    fx0 = (norm/(2.-indx))*(e1^(2.-indx)-e0^(2.-indx))
  endif else fx0 = norm*alog(e1/e0)
  fx0 = fx0 * 1.602d-9 * (!pi/180.)^2
  unabsfx = fx0
endif

;2-component model: power law + thermal (cf. Wang & McCray 1993, ApJ 409, L37)
;	power law: dI/dE = norm * E^(-indx) ph/s/cm^2/keV/sr,
;	where (norm,indx) = (9.5+0.5-0.3,0.7+-0.2)
;	thermal emission: fx = EM*P_rad(T),
;	EM = (3.5+-1.3)e-3 cm^-6 pc, and T = (2.2+0.6-0.4)e6 K
if par(0) eq 2. then begin
  norm = par(1) & indx = par(2) & t = par(3) & em = par(4)
  e0 = par(5) & e1 = par(6) & bins = par(7)
  if bins lt 0 then bins = -bins & if bins lt 100 then bins = 100
  ;power law component
  spec = norm * kev^(-indx)			;[ph/s/cm^2/keV/sr]
  spec = temporary(spec) * kev * 1.602d-9	;[ergs/s/cm^2/keV/sr]
  spec = temporary(spec) * (!pi/180.)^2		;[ergs/s/cm^2/keV/deg^2]
  ;thermal component
  temp = alog10(t) & em = em * 3.1d18 * (!dpi/180.)^2/(4.*!dpi)
  parrst=[float(bins),e0*1e3,de*1e3,0.,0.,0.,12.,0.,0.,0.,0.,0.,temp,10.,1.,0.]
  callrs,pt,parrst=parrst,/clean
  spec = temporary(spec) + em*pt*1d-23
  ;unabsorbed flux
  if indx-1. ne 1. then begin
    fx0 = (norm/(2.-indx))*(e1^(2.-indx)-e0^(2.-indx))
  endif else fx0 = norm*alog(e1/e0)
  fx0 = fx0 * 1.602d-9 * (!pi/180.)^2 + em*1d-23*total(1d-23)
  unabsfx = fx0
endif

;fit to observed spectrum beyond 3 keV using power law and "thermal"
;component
;	dI/dE = N * (E/3 keV)^(-a) * exp(-E/W) ph/s/cm^2/sr/keV
;	where E = photon energy [keV], N = normalization [ph/s/cm^2/sr/keV],
;	a = spectral index, and W = temperature of "thermal" emission [keV]
;
;	(N,a,W) = (5.6, 0.29, 40.) : Marshall et al. 1990, ApJ 235, 4
;				     ("total" observed background 3-100 keV)
;	(N,a,W) = (3.5, 0., 23.)   : Boldt, E. 1987, Phys. Repts. 146, 215
;				     ("residual" background 3-100 keV)
if par(0) eq 3. then begin
  norm = par(1) & indx = par(2) & kT = par(3)
  e0 = par(4) & e1 = par(5) & bins = par(6)
  if bins lt 0 then begin
    bins = -bins & e0 = alog10(e0) & e1 = alog10(e1)
    if bins lt 100 then bins = 100
    de = (e1-e0)/(bins-1.) & kev = de*findgen(bins) + e0 & kev = exp(kev)
    e0 = 10.^(e0) & e1 = 10.^(e1)
  endif else begin
    if bins lt 100 then bins = 100
    de = (e1-e0)/(bins-1.) & kev = de*findgen(bins) + e0
  endelse
  spec = norm * (kev/3.)^(-indx) * exp(-kev/kT)		;[ph/s/cm^2/keV/sr]
  spec = temporary(spec) * kev * 1.602d-9		;[ergs/s/cm^2/keV/sr]
  spec = temporary(spec) * (!pi/180.)^2			;[ergs/s/cm^2/keV/deg^2]
  ;unabsorbed flux
  unabsfx = total(0.5*(spec(1:*)+spec)*(kev(1:*)-kev))
endif

if keyword_set(colden) then begin
  sz = size(colden) & nh = colden(0) & nh2 = 0.26*nh
  if sz(0) eq 0 then begin
    if keyword_set(lat) then bloemen,abs(lat),nh,nh2
  endif else begin
    if sz(1) gt 1 then nh2 = colden(1)
  endelse
  for i=0,bins-1 do begin
    ee = kev(i) & sigma = ismabs(ee)
    if ee lt 1. then sigh2 = 0.16*ee^(-3.54)*1d-22 else sigh2 = 0.
    opdep = nh*sigma + nh2*sigh2
    spec(i) = spec(i) * exp(-opdep)
  endfor
endif

tmpsp = 0.5*(spec(1:*)+spec) & tmpev = (kev(1:*)-kev)
fx = total(tmpev*tmpsp)

return,fx
end
