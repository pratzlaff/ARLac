function spectrum,ev,parspc=parspc,intsp=intsp
;+
;function	spectrum
;		returns the required spectrum
;
;parameters	ev	energies at which the spectrum is computed [eV]
;
;keywords	parspc	array containing all pertinent parameters
;			parspc(0): spectral model to be used
;			parspc(1:*): parameters for model
;		intsp	return emission integrated over all energies
;-

np = n_params(0)
if np eq 0 and not keyword_set(intsp) then begin
  print, 'Usage: f_nu = spectrum(ev,parspc=parspc,/intsp)'
  return,0L
endif

if not keyword_set(parspc) then begin
  print, 'please encode model parameters in array "parspc"'
  print, 'parspc(0): spectral model to be used'
  return,0.
endif

db = [	1., 5., 0.15, 0.28, 1e8, -2., 200.,$
	2., 4., 100., 100., 100., 1e6 ]
pr = [	'E_min [keV]','E_max [keV]','Temperature [K]',$
	'metal abundances [log(Solar)]','number of bins',$
	'nbin [0 < nbin < 1001]','binmin [eV]','binsyz [eV]','Temperature [K]']

par = getpar(parspc,dbase=db,ask=pr)

;model 1: RS Thermal spectrum with feature for metal abundance depletion
;parspc = [1, emin, emax, t, metab, nbin]
if par(0) eq 1. then begin
  emin = par(1) & emax = par(2) & t = par(3) & metab = par(4)
  nbin = par(5)
  print,'SPECTRUM 1: emin,emax,t,metab,nbin',strcompress(par(1:*))

  abun = [10.93,8.52,7.96,8.82,7.92,7.42,7.52,7.2,6.9,6.3,7.6,6.3]
  abun = abun + metab & abun(0) = abun(0) - metab

  if emin gt emax then begin
    print, 'SPECTRUM: interchanging emin and emax'
    tmp = abs(emax) & emax = abs(emin) & emin = tmp
    print, 'SPECTRUM: emin =',strcompress(emin),' emax =',strcompress(emax)
  endif

  if keyword_set(intsp) then begin
    if metab eq 0. then begin
      thermalp,t,var,/interp & return,var
    endif
    if metab eq -2. then begin
      thermalp,t,var,interp=-1 & return,var
    endif
    bmin = 1. & bmax = 2.*1.380662e-16*t/1.6021892e-12
    if bmax lt 1000. then bmax = 1000.
    nbin = fix(alog10((bmax-bmin)/10))*200 & if nbin gt 1000 then nbin = 1000
    bsyz = (bmax-bmin)/(nbin-1.) & dene = 10.
    parrst = [float(nbin),bmin,bsyz,0.,0.,0.,12.,0.,0.,0.,0.,0.,alog10(t),$
	10.,1.,0.,abun]
  endif else begin
    parrst = [float(nbin),emin*1e3,(emax-emin)*1e3/(nbin-1.),0.,0.,0.,$
	12.,0.,0.,0.,0.,0.,alog10(t),10.,1.,0.,abun]
  endelse

  parrst = float(parrst) & callrs,var,ev,parrst=parrst,/clean
  var = var*1e-23 & if keyword_set(intsp) then var = total(var)
endif

;model 2: RS Thermal spectrum in specified passband at given temperature
;parspc = [2, nbin, bmin, bsyz, t]
if par(0) eq 2. then begin
  nbin = par(1) & bmin = par(2) & bsyz = par(3) & t = par(4)
  print,'SPECTRUM 2: nbin,binmin,binsyz,t',strcompress(par(1:*))
  if keyword_set(intsp) then begin
    bmin = 1. & bmax = 2.*1.380662e-16*t/1.6021892e-12
    if bmax lt 1000. then bmax = 1000.
    nbin = fix(alog10((bmax-bmin)/10))*200 & if nbin gt 1000 then nbin = 1000
    bsyz = (bmax-bmin)/(nbin-1.) & dene = 10.
    parrst = [float(nbin),bmin,bsyz,0.,0.,0.,12.,0.,0.,0.,0.,0.,alog10(t),10.]
  endif else begin
    parrst = [float(nbin),bmin,bsyz,0.,0.,0.,12.,0.,0.,0.,0.,0.,alog10(t),10.]
  endelse
  parrst = float(parrst) & callrs,var,ev,parrst=parrst,/clean
  var = var*1e-23 & if keyword_set(intsp) then var = total(var)
endif

return,var
end
