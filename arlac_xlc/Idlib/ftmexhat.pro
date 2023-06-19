function ftmexhat,dim,nbin=nbin,step=step,sig=sig,zigma=zigma,sym=sym,help=help
;+
;function	ftmexhat
;		returns the Fourier Transform of the Mexican Hat function
;
;parameters	dim	dimension of function [default=1]
;
;keywords	nbin	DIM dimensional array of number of array elements
;			along each axis
;		step	DIM dimensional array of step sizes in the mexhat
;			function.  this parameter is used to determine the
;			range in k for which to calculate the transform:
;			kmax = 1/(2*step)
;			note that the transform is returned *always* centered
;			at (nbin/2)+1
;		sig	DIM dimensional array of sigma-parameter of mexican-hat
;		zigma	if set, forces an "average" sigma on the problem.
;			the default is to use total(SIG)/DIM
;		sym	if set, forces fx=fy=fz=...
;		help	if set, prints out the usage synopsis
;
;restrictions
;	procedure will crash for large values of NBIN!
;
;history
;	vinay kashyap (ASC/UC, 1995)
;-

np = n_params(0)
if np eq 0 then dim = 1 else dim = fix(dim)

if keyword_set(help) or dim lt 1 then begin
  print,'Usage: fth=ftmexhat(dim,nbin=nbin,step=step,sig=sig,zigma=zigma,/help)'
  print, '  returns the Mexican Hat function'
  return,-1L
endif

n = intarr(dim) & for i=0,dim-1 do n(i)=64
if keyword_set(nbin) then begin
  sz = size(nbin)
  if sz(0) eq 1 and sz(1) le dim then n(0) = fix(nbin)
  if sz(0) eq 0 then n(*) = fix(nbin)
endif

cen = float((n/2)+1) & delt = fltarr(dim)+1.
if keyword_set(step) then begin
  sz = size(step)
  if sz(0) eq 1 and sz(1) le dim then delt(0) = float(step)
  if sz(0) eq 0 then delt(*) = float(step)
endif

s = fltarr(dim)+2.
if keyword_set(sig) then begin
  sz = size(sig)
  if sz(0) eq 1 and sz(1) le dim then s(0) = float(sig)
  if sz(0) eq 0 then s(*) = float(sig)
endif
if not keyword_set(zigma) then sigma=total(s)/dim else sigma=float(zigma)
fsig = (sigma/s)^2
if keyword_set(sym) then fsig(*)=fsig(0)

case dim of
  1: begin
    x = findgen(n(0))+1-cen(0) & x = x/abs(2.*x(0)*delt(0))
    tmp = (2.*!pi*x*s(0))^2 & tmp = tmp < 150.
    f = sqrt(2.*!pi)*s(0)*tmp*exp(-0.5*tmp)
  end
  2: begin
    x = findgen(n(0))+1-cen(0) & y = findgen(n(1))+1-cen(1) & tmp = y*0.
    x = x/abs(2.*x(0)*delt(0)) & y = y/abs(2.*y(0)*delt(1))
    f = fltarr(n(0),n(1))
    for i=0,n(0)-1 do begin
      tmp1 = fsig(0)*(2.*!pi*x(i)*s(0))^2 + fsig(1)*(2.*!pi*y*s(1))^2
      tmp2 = (2.*!pi*x(i)*s(0))^2 + (2.*!pi*y*s(1))^2 & tmp2 = tmp2 < 150.
      f(i,*) = (2.*!pi)*s(0)*s(1)*tmp1(*)*exp(-0.5*tmp2(*))
    endfor
  end
  3: begin
    x = findgen(n(0))+1-cen(0) & y = findgen(n(1))+1-cen(1)
    z = findgen(n(2))+1-cen(2) & tmp = z*0.
    x = x/abs(2.*x(0)*delt(0)) & y = y/abs(2.*y(0)*delt(1))
    z = z/abs(2.*z(0)*delt(2))
    f = fltarr(n(0),n(1),n(2))
    for i=0,n(0)-1 do begin
      for j=0,n(1)-1 do begin
	tmp1 = fsig(0)*(2.*!pi*x(i)*s(0))^2 + fsig(1)*(2.*!pi*y(j)*s(1))^2
	tmp1 = tmp1 + fsig(2)*(2.*!pi*z*s(2))^2
	tmp2 = (2.*!pi*x(i)*s(0))^2 + (2.*!pi*y(j)*s(1))^2 + (2.*!pi*z*s(2))^2
	tmp2 = tmp2 < 150.
	f(i,j,*)=(2.*!pi)^(1.5)*s(0)*s(1)*s(2)*tmp1(*)*exp(-0.5*tmp2(*))
      endfor
    endfor
  end
  4: begin
    x = findgen(n(0))+1-cen(0) & y = findgen(n(1))+1-cen(1)
    z = findgen(n(2))+1-cen(2) & t = findgen(n(3))+1-cen(3)
    x = x/abs(2.*x(0)*delt(0)) & y = y/abs(2.*y(0)*delt(1))
    z = z/abs(2.*z(0)*delt(2)) & t = t/abs(2.*t(0)*delt(3))
    tmp = z*0.
    f = fltarr(n(0),n(1),n(2),n(3))
    for i=0,n(0)-1 do begin
      for j=0,n(1)-1 do begin
	for k=0,n(2)-1 do begin
	  tmp1 = fsig(0)*(2.*!pi*x(i)*s(0))^2+fsig(1)*(2.*!pi*y(j)*s(1))^2
	  tmp1 = tmp1+fsig(2)*(2.*!pi*z(k)*s(2))^2+fsig(3)*(2.*!pi*t*s(2))^2
	  tmp2 = (2.*!pi*x(i)*s(0))^2+(2.*!pi*y(j)*s(1))^2+(2.*!pi*z(k)*s(2))^2
	  tmp2 = tmp2 + (2.*!pi*t*s(2))^2 & tmp2 = tmp2 < 150.
	  f(i,j,k,*)=(2.*!pi)^2*s(0)*s(1)*s(2)*s(3)*tmp1(*)*exp(-0.5*tmp2(*))
	endfor
      endfor
    endfor
  end
  else: begin
    print, 'hoy, watch it!  this is not particle physics!'
    print, 'edit FTMEXHAT.PRO to add these higher dimensional functional forms.'
    return, -1L
  end
endcase

return,f
end
