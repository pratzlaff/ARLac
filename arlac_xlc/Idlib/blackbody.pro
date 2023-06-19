pro blackbody,t,b,x,xr=xr,tunit=tunit,xunit=xunit,hunit=hunit,nolog=nolog
;+
;procedure	blackbody
;		computes the planck function B (ergs/s/cm^2/sr/unitx)
;		as a function of specified unit (frequency/wavelength)
;		at the given temperature.
;		To get the planck function in units of Jy/sr, the following
;		sequence is recommended:
;		* first, obtain the range in x in Hz.  if the input is in
;		  microns, use -- IDL> xr=cm(cm([x0,x1],/mu),/hz,/inv)
;		* second, call this procedure --
;		  IDL> blackbody,T,B_nu,x,xr=xr
;		* convert the units to (say) microns --
;		  IDL> xx = cm(cm(x,/hz),/mu,/inv)
;		* convert B_nu from [ergs/s/cm^2/sr/Hz] to [watts/m^2/Hz/sr]
;		  IDL> B_nu = B_nu/1e3
;
;parameters	t	temperature
;		b	the Planck function, B(T,x)
;		x	frequency/wavelength array
;			NOTE: if input, returns B(x;T) at the values of x.
;			Otherwise, is computed at run time.
;
;keywords	xr	range in x (must be in same unit as specified by xunit)
;			if x is specified uniquely, this keyword is ignored
;		tunit	units in which t is given (default: degrees K)
;		xunit	units in which x is given (default: hz)
;		hunit	print out a menu of available unit formats
;		nolog	if set, intervals in x are spaced regularly
;			(default is to use logarithmic spacing)
;
;side effects
;		if only one parameter is given, plots B v/s x
;
;subroutines 
;	ERG.PRO
;
;						-- vinay kashyap (3/24/93)
;-

;some constants:
h = 6.626176e-27 & c = 2.99792458e10 & kb = 1.380662e-16

n1 = n_params(0)
if n1 lt 1 then begin
  print, 'Usage: blackbody,t,b,x,xr=xr,tunit=tunit,xunit=xunit,/hunit,/nolog
  print, '  computes the Plank function B(x) in specified range'
endif

if keyword_set(hunit) or n1 lt 1 then begin
  c1 = 'TUNIT: Default is K [K]'
  c2 = '       EV [eV]; KEV [keV]; LOG [log_10(T[K])]'
  print, c1 & print,c2
  c1 = 'XUNIT: Default is HZ [hz]'
  c2 = '       KHZ [khz]; MHZ [Mhz]; GHZ [Ghz]; EV [eV]; KEV [keV];'
  c3 = '       CM [cm]; M [m]; A/ANG [angstrom]; MU/MIC [microns]'
  print, c1 & print,c2 & print,c3
endif

if n1 lt 1 then return

;figure out the number steps in the output: if an array b is input, use
;its size.  otherwise, default is 101
nbin=0 & sz=size(b) & if sz(0) ne 0 then nbin=sz(1) & if nbin le 1 then nbin=101

;figure out whether B_nu(Hz) or B_lamda(cm) are to be calculated
freq = 1
if keyword_set(xunit) then begin
  xunit = strupcase(xunit)
  if strlen(xunit) gt 3 then xunit = strmid(xunit,0,3)
  if xunit eq 'CM' or xunit eq 'M' or xunit eq 'MU' then freq = 0
  if xunit eq 'MIC' or xunit eq 'A' or xunit eq 'ANG' then freq = 0
endif

;convert the given xrange to the proper units (CM or HZ)
if keyword_set(xunit) and keyword_set(xr) then begin
  if xunit eq 'A' or xunit eq 'ANG' then xr = xr*1e-8
  if xunit eq 'MU' or xunit eq 'MIC' then xr = xr*1e-4
  if xunit eq 'EV' or xunit eq 'KEV' then xr = erg(erg(xr,/ev),/hz,/inv)
  if xunit eq 'KEV' then xr = xr*1e3
  if xunit eq 'KHZ' then xr = xr*1e3
  if xunit eq 'MHZ' then xr = xr*1e6
  if xunit eq 'GHZ' then xr = xr*1e9
endif

;check if x is uniquely specified, and if so, set the range from it
;also convert the units of x to HZ or CM as the case may be.
sz = size(x)
if sz(1) gt 0 then begin
  tmp = x(1:*)-x & h1 = where(tmp ne 0.)
  if n_elements(h1) ge 0.5*nbin then begin
    if keyword_set(xunit) then begin
      if xunit eq 'A' or xunit eq 'ANG' then x = x*1e-8
      if xunit eq 'MU' or xunit eq 'MIC' then x = x*1e-4
      if xunit eq 'EV' or xunit eq 'KEV' then x = erg(erg(x,/ev),/hz,/inv)
      if xunit eq 'KEV' then x = x*1e3
      if xunit eq 'KHZ' then x = x*1e3
      if xunit eq 'MHZ' then x = x*1e6
      if xunit eq 'GHZ' then x = x*1e9
    endif
    x0 = min(x,max=x1) & xr = [x0,x1]
  endif
endif else begin
  if keyword_set(xr) then begin
    if keyword_set(nolog) then begin
      y = (xr(1)-xr(0))/(nbin-1.) & x = y*findgen(nbin) + xr(0)
    endif else begin
      y = (alog(xr(1))-alog(xr(0)))/(nbin-1.) & x = y*findgen(nbin)+alog(xr(0))
      x = exp(x)
    endelse
  endif
endelse

;now figure out the default range (one order of magnitude on either side
;of the peak).  default range would be in default units.  Also define
;the points at which B will be calculated, if x has not been uniquely
;specified.
if not keyword_set(xr) then begin
  if freq then xmax = 5.88e10*t else xmax = 0.29/t
  xr = xmax*[0.1,10.]
  if keyword_set(nolog) then begin
    y = (xr(1)-xr(0))/(nbin-1.) & x = y*findgen(nbin) + xr(0)
  endif else begin
    y = (alog(xr(1))-alog(xr(0)))/(nbin-1.) & x = y*findgen(nbin)+alog(xr(0))
    x = exp(x)
  endelse
endif

;now convert the temperature to the proper unit (K)
temp = t
if keyword_set(tunit) then begin
  tunit = strupcase(tunit) & tunit = strmid(tunit,0,3)
  if tunit eq 'EV' then t = erg(erg(t,/ev),/degk,/inv)
  if tunit eq 'KEV' then t = erg(erg(t,/kev),/degk,/inv)
  if tunit eq 'LOG' then t = 10^t
endif else tunit = 'K'

;ok, calculate B_nu (ergs/s/cm^2/sr/hz) or B_lamda (ergs/s/cm^2/sr/cm) as
;the case may be:
b = x*0.
if freq then begin
  a1 = alog(2.*h) + 3.*alog(x) - 2.*alog(c)
  a2 = alog(h*x) - alog(kb) - alog(t)
endif else begin
  a1 = alog(2.*h) + 2.*alog(c) - 5.*alog(x)
  a2 = alog(h*c) - alog(x) - alog(kb) - alog(t)
endelse
a2 = exp(a2) & a1 = exp(a1)
h1 = where(a2 lt 100.) & h2 = where(a2 ge 100.)
if h1(0) ne -1 then begin
  a2(h1) = exp(a2(h1))-1. & b(h1) = a1(h1)/a2(h1)
endif
if h2(0) ne -1 then b(h2) = 0.

;convert the units of B_x to [ergs/s/cm^2/sr/xunit]
y = 1.
if keyword_set(xunit) then begin
  if xunit eq 'KHZ' then y = 1e3
  if xunit eq 'MHZ' then y = 1e6
  if xunit eq 'GHZ' then y = 1e9
  if xunit eq 'EV' or xunit eq 'KEV' then y = erg(erg(1.,/ev),/hz,/inv)
  if xunit eq 'KEV' then y = y*1e3
  if xunit eq 'A' or xunit eq 'ANG' then y = 1e-8
  if xunit eq 'M' then y = 1e2
  if xunit eq 'MU' or xunit eq 'MIC' then y = 1e-4
endif else xunit = 'HZ'

b = b*y & x = x/y & xr = xr/y

if n1 eq 1 then begin
  xt = xunit & yt = 'B [ergs/s/cm^2/sr/'+xunit+' ]'
  tt = 'Planck function at T = ' + strtrim(temp,2) + ' [' + tunit + ']'
  plot,x,b,xrange=xr,xtitle=xt,ytitle=yt,title=tt,xstyle=1
endif

return
end
