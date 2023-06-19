pro solvnleq,root,f_nam,params=params,xlow=xlow,xhigh=xhigh,xac=xac
;+
;procedure	solvnleq
;	Using a combination of the Newton-Raphson and bisection methods,
;	finds the root of a function bracketed between xlow and xhigh.
;	the root will be refined until its accuracy is known within +/- xac.
;	(from Numerical Recipes, by Press et al. 1st ed., p258)
;parameters	root	root of user-supplied function
;		f_nam	name of user-supplied procedure that returns the
;			value of the function and its first derivative at
;			specified points
;keywords	params	parameters to be supplied to user-defined f_nam
;		xlow	lower bound of root
;		xhigh	upper bound of root
;		xac	accuracy with which root will be determined
;-

n1 = n_params(0) & c1 = ''

if n1 lt 2 then begin
  print,'Usage: solvnleq,root,f_nam,params=params,xlow=xlow,xhigh=xhigh,xac=xac'
  print,'  finds root(s) of function f_nam with parameters params'
  return
endif

x1 = 1e-8 & x2 = 1e3 & xacc = 1e-8

if keyword_set(xlow) then x1 = xlow
if keyword_set(xhigh) then x2 = xhigh
if keyword_set(xac) then xacc = xac

getfdf,f_nam,x1,alpha,beta,params=params,dx=xacc & fl=-beta
getfdf,f_nam,x2,alpha,beta,params=params,dx=xacc & fh=-beta

maxit = 100
if fl lt 0 then begin
  xl = x1 & xh = x2
endif else begin
  xh = x1 & xl = x2 & swap = fl & fl = fh & fh = swap
endelse

root = 0.5*(x1+x2) & dxold = abs(x2-x1) & dx = dxold
getfdf,f_nam,root,alpha,beta,params=params,dx=xacc & f=-beta & df=alpha

for j=1,maxit do begin
  cond1 = ((root-xh)*df-f)*((root-xl)*df-f)
  cond2 = abs(2.*f)-abs(dxold*df)
  if cond1 gt 0. or cond2 gt 0. then begin
    dxold = dx & dx = 0.5*(xh-xl) & root = xl+dx
    if xl eq root then return
  endif else begin
    dxold = dx & dx = f/df & temp = root & root = root-dx
    if temp eq root then return
  endelse
  if abs(dx) lt xacc then return

  getfdf,f_nam,root,alpha,beta,params=params,dx=xacc & f=-beta & df=alpha

  if f lt 0. then begin
    xl = root & fl = f
  endif else begin
    xh = root & fh = f
  endelse
endfor

print, 'SOLVNLEQ exceeding maximum iterations'

return
end
