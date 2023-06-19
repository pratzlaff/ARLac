function bootcdf,x,cdf,xmid,mdn=mdn,lgx=lgx,lvls=lvls,nboot=nboot,nper=nper
;+
;function	bootcdf
;		bootstraps the given integral distribution function of x to
;		obtain confidence levels on the mean or the median.
;
;parameters	x	independent parameter
;		cdf	cumulative distribution function
;		xmid	holds median (or mean if keyword MDN > 0)
;
;keywords	mdn	if set, returns median and confidence limits on it
;		lgx	if set, assumes input x is given in log_10 (logx=1)
;			of log_e(x) (logx=2) and converts accordinngly
;		lvls	force computation of upper and lower confidence limits
;			at specified percentages.  if not set, confidence
;			levels on the mean (or median) at +-[68,95,99]%
;			are returned.
;		nboot	number of bootstraps (def:1000)
;		nper	number of realizations/bootstrap (def: n_elements(x))
;
;usage		IDL> clim = bootcdf(x,cdf,xmid,mdn=median,lgx=logx,lvls=levels)
;
;history	written in prehistory, standardized 3/31/94
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: clim = bootcdf(x,cdf,xmid,mdn=median,lgx=logx,lvls=levels,$
  print, '              nboot=nboot,nper=nper)'
  print, '  returns confidence limits on mean/median of x with given cdf'
  return,[-1L]
endif
nx = n_elements(x) & x_store = x
if np eq 1 then begin
  cdf = 1. - (findgen(nx)/(nx-1.))
endif
y_store = cdf

if keyword_set(mdn) then get_mean = 0 else get_mean = 1
if keyword_set(lgx) then begin
  if lgx eq 1 then x = 10.^(x)
  if lgx eq 2 then x = exp(x)
endif
if keyword_set(lvls) then clev = lvls else clev = [68.,95.,99.]
if keyword_set(nboot) then iboot = nboot else iboot = 1000
if keyword_set(nper) then iper = nper else iper = nx

;	sort cdf into ascending order
h1 = sort(cdf) & cdf = cdf(h1) & x = x(h1)
nlev = n_elements(clev)*2 + 1. & clim = fltarr(nlev)

;	get the mean
df = 0. & f0 = 0. & mean = 0.
for i=0,nx-1 do begin
  df = cdf(i) - f0
  mean = mean + x(i)*df
  f0 = cdf(i)
endfor
clim(0) = mean & xmid = mean
;	...and the median
h1 = where(cdf ge 0.5) & median = x([h1(0)])
if get_mean eq 0 then clim(0) = median else xmid = median

;	simulate away!
mboot = fltarr(iboot)
for i=0,iboot-1 do begin
  ;create arrays of random numbers:
  hran = randomu(seed,iper)
  ;create new 'data' set
  new_x = fltarr(iper)
  for j=0,iper-1 do new_x(j) = x(min(where(cdf ge hran(j))))
  ;obtain the mean/median
  if get_mean then begin
    mboot(i) = total(new_x)/float(iper)
  endif else begin
    new_x = new_x(sort(new_x)) & imid = fix(float(iper)/2.)
    mboot(i) = new_x(imid)
  endelse
endfor

;obtain the confidence limits
mboot = mboot(sort(mboot))
nup = 0 & ndn = 0 & neq = 0
hup = where(mboot gt clim(0))
heq = where(mboot eq clim(0))
hdn = where(mboot lt clim(0))
if hup(0) ne -1 then nup = n_elements(hup)
if heq(0) ne -1 then neq = n_elements(heq)
if hdn(0) ne -1 then ndn = n_elements(hdn)

k = 0
for i=0,n_elements(clev)-1 do begin
  k = k + 1 & pct = clev(i) & if pct gt 1. then pct = pct/100.
  clim(k) = mboot(fix(pct*nup+neq+ndn+0.5)-1) & k = k + 1
  clim(k) = mboot(fix((1.-pct)*ndn+0.5))
endfor

if keyword_set(lgx) then begin
  if lgx eq 1 then clim = alog10(clim)
  if lgx eq 2 then clim = alog(clim)
endif
x = x_store & cdf = y_store

return,clim
end
