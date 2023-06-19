pro getfdf,fname,x,alpha,beta,params=params,dx=dx
;+
;procedure	getfdf
;		given the names of a set of functions, returns their
;		value and the matrix of derivatives at the given point x
;
;parameters	fname	string array of function names
;		x	point at which fname is to be evaluated
;		alpha	matrix of derivatives, df_i/dx_j
;		beta	-ve of the function values, f_i(x)
;
;keywords	params	parameters to be supplied to fname
;		dx	array containing increments in x to be considered
;			for df/dx
;-

if n_params(0) lt 3 then begin
  print, 'Usage: getfdf,fname,x,alpha,beta,params=params,dx=dx'
  print, '  returns df_i/dx_j and -f_i(x) for given f at x'
  return
endif

np = n_elements(fname) & nd = n_elements(x)
alpha = fltarr(np,nd) & beta = fltarr(np)
delx = fltarr(nd) & delx(0)=1. & if not keyword_set(dx) then dx=0.1+fltarr(nd)

for i=0,np-1 do begin
  c1 = fname(i) & beta(i) = -call_function(c1,x,params=params)
  for j=0,nd-1 do begin
    y = x+shift(delx,j)*dx
    alpha(i,j) = (call_function(c1,y,params=params)+beta(i))/dx
  endfor
endfor

return
end
