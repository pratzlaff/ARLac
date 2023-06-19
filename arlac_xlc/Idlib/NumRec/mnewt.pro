pro mnewt,fname,x,ntrial=ntrial,tolx=tolx,tolf=tolf,params=params
;+
;procedure	mnewt
;		based on the numerical recipe of the same name, takes an
;		initial guess x for a root in N dimensions, and takes
;		ntrial Newton-Raphson steps to improve the root.
;
;parameters	fname	string array containing the names of the functions
;			whose intersections are desired
;		x	initial guess for the simultaneous solution fname = 0
;
;keywords	ntrial	maximum number of tries to find exact root
;		tolx	summed variable increments to decide root convergence
;		tolf	summed function values to decide root convergence
;		params	parameters to be supplied to the user-defined
;			functions specified in fname
;-

if n_params(0) lt 2 then begin
  print, 'Usage: mnewt,fname,x,ntrial=ntrial,tolx=tolx,tolf=tolf,params=params'
  print, '  based on an initial guess of simultaneous root of various'
  print, '  equations, calculates the exact root if it exists'
  return
endif

if not keyword_set(ntrial) then ntrial = 100
if not keyword_set(tolx) then tolx = 1e-3
if not keyword_set(tolf) then tolf = 1e-3

np = n_elements(fname) & alpha = fltarr(np,np) & beta = fltarr(np)

for k=1,ntrial do begin
  getfdf,fname,x,alpha,beta,params=params
  errf = total(abs(beta))
  if errf le tolf then return
  ludcmp,alpha,indx,d & lubksb,alpha,indx,beta
  errx = total(abs(beta)) & x = x+beta
  if errx le tolx then return
endfor

return
end
