pro readxlf,xl,f,file=file,dir=dir,filtyp=filtyp,nsim=nsim,simf=simf,ave=ave
;+
;procedure	readxlf		general routine to read in X-ray LF and
;				bootstrap different realizations of it.
;
;parameters	xl		log_10(X-ray luminosities [ergs/s])
;				output xl always in ASCENDING order
;		f		F(xl)
;
;keywords	file		data file location (full pathname required)
;					{Mblue.xlf}
;		dir		directory containing data files
;					{./}
;		filtyp		format of data file
;				0: (logLx, cdf), all lines except the last one.
;				   [X-ray LFs constructed by Giusi, and used in
;				    Kashyap et al. 1992, ApJ 391, 684]
;				1: (logLx, cdf), all lines
;				   [X-ray LFs constructed by Giusi, and used in
;				    Micela et al. 1995 (PleiadesI)]
;		nsim		if set, computes NSIM realizations of the
;				X-ray LF.  the resulting cdfs (computed
;				at the same xl as the data) are placed in
;				the array SIMF
;		simf		OUTPUT: returns the simulated cdfs as (NF,NSIM)
;				array, where NF = n_elements(F)
;		ave		OUTPUT: <Lx> (1D array with NSIM+1 elements)
;
;history
;	vinay kashyap	(1/12/94)
;	changed default DIR to be "./" (VK; Dec98)
;-

np = n_params(0)
if np lt 2 then begin
  print, 'Usage: readxlf,xl,f,file=file,dir=dir,filtyp=filtyp,nsim=nsim,simf=simf,ave=ave'
  print, '  use to read in and bootstrap X-ray LFs' & return
endif

dfil='Mblue.xlf' & if keyword_set(file) then dfil=strtrim(file,2)
ddir='./' & if keyword_set(dir) then ddir=strtrim(dir,2)
isim=0 & if keyword_set(nsim) then isim=fix(nsim)
frmt=0 & if keyword_set(filtyp) then frmt=fix(filtyp)

if frmt lt 0 or frmt gt 1 then begin
  print, 'sorry, no other format has been encoded'
  xl = [0.,0.] & f = [1., 0.]
  return
endif

if frmt eq 0 then begin
  xlf_fil = ddir+dfil
  nf = wc(xlf_fil)-1 & var = fltarr(2,nf)
  openr,uxf,xlf_fil,/get_lun & readf,uxf,var & close,uxf & free_lun,uxf
  xl = reform(var(0,*)) & f = reform(var(1,*))
  h1 = reverse(sort(f)) & xl = xl(h1) & f = f(h1)
endif

if frmt eq 1 then begin
  xlf_fil = ddir+dfil
  nf = wc(xlf_fil) & var = fltarr(2,nf)
  openr,uxf,xlf_fil,/get_lun & readf,uxf,var & close,uxf & free_lun,uxf
  xl = reform(var(0,*)) & f = reform(var(1,*))
  xl = reverse(xl) & f = reverse(f)
endif

ff = [f,0.] & df = ff-ff(1:*) & ave = [total(10.^(xl)*df)]

if isim gt 0 then begin
  simf = fltarr(nf,isim) & simx=randomu(seed,long(isim)*nf) & simr=0.*simx
  ave = [ave,fltarr(isim)]
  for i=1,nf-1 do begin
    h1 = where(simx gt f(i) and simx le f(i-1))
    if h1(0) ne -1 then simr(h1) = i-1
  endfor
  h1=where(simx gt 0. and simx lt f(nf-1)) & if h1(0) ne -1 then simr(h1)=nf-1
  ;D; plot,xl,f,psym=10
  for i=0,isim-1 do begin
    r = simr(i*nf:(i+1)*nf-1) & xf = 0.*r
    for j=0,nf-1 do xf(r(j)) = xf(r(j))+1
    for j=nf-2,0,-1 do xf(j) = xf(j)+xf(j+1) & xf = xf/xf(0)
    simf(0:nf-1,i) = xf
    ;D; oplot,xl,simf(*,i),linestyle=1,psym=10
    ;
    ff = [xf,0.] & df = ff-ff(1:*) & ave(i+1) = total(10.^(xl)*df)
  endfor
endif

return
end
