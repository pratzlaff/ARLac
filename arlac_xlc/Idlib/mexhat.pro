function mexhat,dim,nbin=nbin,cen=cen,sig=sig,zigma=zigma,sym=sym,help=help
;+
;function	mexhat
;		returns the Mexican Hat function
;
;parameters	dim	dimension of function [default=1]
;
;keywords	nbin	DIM dimensional array of number of array elements
;			along each axis
;		cen	DIM dimensional array of pixel value of the center
;		sig	DIM dimensional array of sigma-parameter of mexican-hat
;		zigma	if set, forces an average sigma on the problem
;			the default is to use total(SIG)/DIM
;		sym	if set, ensures that fx=fy=fz=...
;		help	if set, prints out the usage synopsis
;
;restrictions
;	procedure will crash for large values of NBIN!
;
;usage examples
;	hat = mexhat(0) & print, mexhat(/help)
;	hat = mexhat(1,nbin=[512],sig=[16])
;	hat = mexhat(2,nbin=[512,512],sig=[32,16]) & hat = shift(hat,256,256)
;
;history
;	vinay kashyap (ASC/UC, 1995)
;-

np = n_params(0)
if np eq 0 then dim = 1 else dim = fix(dim)

if keyword_set(help) or dim lt 1 then begin
  print, 'Usage: hat = mexhat(dim,nbin=nbin,cen=cen,sig=sig,zigma=zigma,/sym,/help)'
  print, '  returns the Mexican Hat function'
  return,-1L
endif

n = intarr(dim) & for i=0,dim-1 do n(i)=64
if keyword_set(nbin) then begin
  sz = size(nbin)
  if sz(0) eq 0 then n(*)=fix(nbin) > 64
  if sz(0) eq 1 and sz(1) le dim then n(0) = fix(nbin)
endif

zen = float((n/2)+1)
if keyword_set(cen) then begin
  sz = size(cen)
  if sz(0) eq 1 and sz(1) le dim then zen(0) = float(cen)
endif

s = fltarr(dim)+2.
if keyword_set(sig) then begin
  sz = size(sig)
  if sz(0) eq 0 then s(*)=float(sig) > 2
  if sz(0) eq 1 and sz(1) le dim then s(0) = float(sig)
endif

case dim of
  1: begin
    x = findgen(n(0))+1-zen(0)
    tmp = (x/s(0))^2 & tmp = tmp < 150.
    f = (1.-tmp)*exp(-0.5*tmp)
  end
  2: begin
    x = findgen(n(0))+1-zen(0) & y = findgen(n(1))+1-zen(1) & tmp = y*0.
    f = fltarr(n(0),n(1))
    if not keyword_set(zigma) then sigma=total(s)/2. else sigma=float(zigma)
    fx=(sigma/s(0))^2 & fy=(sigma/s(1))^2
    if keyword_set(sym) then fy=fx
    for i=0,n(0)-1 do begin
      tmp = (x(i)/s(0))^2 + (y/s(1))^2 & tmp = tmp < 150.
      f(i,*) = (fx*(1.-(x(i)/s(0))^2) + fy*(1.-(y(*)/s(1))^2))*exp(-0.5*tmp(*))
    endfor
  end
  3: begin
    x = findgen(n(0))+1-zen(0) & y = findgen(n(1))+1-zen(1)
    z = findgen(n(2))+1-zen(2) & tmp = z*0.
    f = fltarr(n(0),n(1),n(2))
    if not keyword_set(zigma) then sigma=total(s)/3. else sigma=float(zigma)
    fx=(sigma/s(0))^2 & fy=(sigma/s(1))^2 & fz=(sigma/s(2))^2
    if keyword_set(sym) then begin & fy=fx & fz=fx & endif
    for i=0,n(0)-1 do begin
      for j=0,n(1)-1 do begin
	tmp = (x(i)/s(0))^2 + (y(j)/s(1))^2 + (z/s(2))^2 & tmp = tmp < 150.
	tm2 = fx*(1.-(x(i)/s(0))^2) + fy*(1.-(y(j)/s(1))^2) + fz*(1.-(z/s(2))^2)
	f(i,j,*) = tm2*exp(-0.5*tmp(*))
      endfor
    endfor
  end
  4: begin
    x = findgen(n(0))+1-zen(0) & y = findgen(n(1))+1-zen(1)
    z = findgen(n(2))+1-zen(2) & t = findgen(n(3))+1-zen(3)
    tmp = t*0.
    f = fltarr(n(0),n(1),n(2),n(3))
    if not keyword_set(zigma) then sigma=total(s)/4. else sigma=float(zigma)
    fx=(sigma/s(0))^2 & fy=(sigma/s(1))^2
    fz=(sigma/s(2))^2 & ft=(sigma/s(3))^2
    if keyword_set(sym) then begin & fy=fx & fz=fx & ft=fx & endif
    for i=0,n(0)-1 do begin
      for j=0,n(1)-1 do begin
	for k=0,n(2)-1 do begin
	  tmp = (x(i)/s(0))^2 + (y(j)/s(1))^2 + (z(k)/s(2))^2 + (t/s(3))^2
	  tmp = tmp < 150.
	  tm2 = fx*(1.-(x(i)/s(0))^2) + fy*(1.-(y(j)/s(1))^2) +$
		fz*(1.-(z(k)/s(2))^2) + ft*(1.-(t/s(3))^2)
	  f(i,j,k,*) = tm2*exp(-0.5*tmp(*))
	endfor
      endfor
    endfor
  end
  else: begin
    print, 'hoy, watch it!  this is not particle physics!'
    print, 'edit MEXHAT.PRO to add these higher dimensional functional forms.'
    return, -1L
  end
endcase

return,f
end
