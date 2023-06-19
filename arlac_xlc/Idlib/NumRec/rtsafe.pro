pro rtsafe,root,f_nam,p1,p2,p3,p4,p5,p6,p7,xlow=xlow,xhigh=xhigh,xac=xac
;+
;procedure	rtsafe
;	Using a combination of the Newton-Raphson and bisection methods,
;	finds the root of a function bracketed between xlow and xhigh.
;	the root will be refined until its accuracy is known within +/- xac.
;	(from Numerical Recipes, by Press et al. 1st ed., p258)
;parameters	root	root of user-supplied function
;		f_nam	name of user-supplied procedure that returns the
;			value of the function and its first derivative at
;			specified points
;		p1-p7	parameters/keyword-values to be supplied to f_nam
;keywords	xlow	lower bound of root
;		xhigh	upper bound of root
;		xac	accuracy with which root will be determined
;-

n1 = n_params(0) & c1 = ''

if n1 lt 2 then begin
  print, 'Usage: rtsafe,root,f_nam,p_i,xlow=xlow,xhigh=xhigh,xac=xac'
  print, '  finds root(s) of function f_nam with parameters p_i (max=7)'
  return
endif

x1 = 1e-8 & x2 = 1e3 & xacc = 1e-8

if f_nam eq 'standard' then begin
  x1 = 1e-8 & x2 = 1e3
endif
if f_nam eq 'bernoulli' then begin
  x1 = 1e-8 & x2 = 1e3 & xacc = 1e-3
  ucrit = p1 & grav = p2 & x = p3 & gamm = 1.1 & rsup = 2.
  if n1 ge 6 then gamm = p4 & if n1 ge 7 then rsup = p5
endif
if f_nam eq 'saha' then begin
  x1 = 10. & x2 = 1e23 & xacc = 1e-8
  t_gas = p1 & ntot = p2
endif

if keyword_set(xlow) then x1 = xlow
if keyword_set(xhigh) then x2 = xhigh
if keyword_set(xac) then xacc = xac

if f_nam eq 'standard' then begin
  standard,x1,fl,df & standard,x2,fh,df
endif
if f_nam eq 'bernoulli' then begin
  bernoulli,ucrit,grav,x,x1,fl,df,gamma=gamm,rindex=rsup
  bernoulli,ucrit,grav,x,x2,fh,df,gamma=gamm,rindex=rsup
endif
if f_nam eq 'saha' then begin
  saha,t_gas,ntot,phi,x1,fl,df
  saha,t_gas,ntot,phi,x2,fh,df
endif

maxit = 100
if fl lt 0 then begin
  xl = x1 & xh = x2
endif else begin
  xh = x1 & xl = x2 & swap = fl & fl = fh & fh = swap
endelse

root = 0.5*(x1+x2) & dxold = abs(x2-x1) & dx = dxold
if f_nam eq 'standard' then standard,x,f,df
if f_nam eq 'bernoulli' then bernoulli,$
	ucrit,grav,x,root,f,df,gamma=gamm,rindex=rsup
if f_nam eq 'saha' then saha,t_gas,ntot,phi,root,f,df

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

  if f_nam eq 'standard' then standard,x,f,df
  if f_nam eq 'bernoulli' then bernoulli,$
	ucrit,grav,x,root,f,df,gamma=gamm,rindex=rsup
  if f_nam eq 'saha' then saha,t_gas,ntot,phi,root,f,df

  if f lt 0. then begin
    xl = root & fl = f
  endif else begin
    xh = root & fh = f
  endelse
endfor

print, 'RTSAFE exceeding maximum iterations'

return
end
