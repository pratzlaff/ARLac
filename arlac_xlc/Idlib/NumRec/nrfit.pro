function nrfit,x,y,sig,nr=nr,sigx=sigx
;+
;function	nrfit
;		fits a straight line of the form [y=a+bx] to the given set of
;		data points.  IDL translation of FIT.F (Numerical Recipes,
;		Press et al.) returns a 5-element array containing
;			[a,b,sigma(a),sigma(b),chi^2,q]
;		If SIGX is set, or if NR is set, calls the FORTRAN codes in
;		fit.f or fitexy.f via a C interface on Suns and SGIs.
;
;parameters	x	array of data points
;		y	array of dependant data points
;		sig	individual std. deviations in x (optional)
;
;keywords	nr	if set, calls the FORTRAN version
;		sigx	if set, calls FITEXY.F via the C interface
;
;subroutines
;	NRGAMMQ
;	SGINR.SO/SUNNR.SO
;
;history
;	vinay kashyap (1/16/95)
;-

np = n_params(0)
if np lt 2 then begin
  print, 'Usage: fit_pars = nrfit(x,y,sig,/nr,sigx=sigx),'
  print, '  where fits_pars = [a,b,sigma(a),sigma(b),chi^2,q]'
  print, '  Use to fit st. line a+bx to given data points'
  return,intarr(5)
endif

if np eq 2 then mwt = 0 else mwt = 1
ndata = n_elements(x)
if ndata le 2 then begin
  print, "sorry, can't handle 2-element arrays" & return,intarr(5)
endif

if keyword_set(nr) or keyword_set(sigx) then begin
  ;try to use the Fortran version via the shared object
  sodir = '/home6/kashyap/Idlib/NumRec/' & shobj = 'NONE'
  if !version.os eq 'IRIX' then begin
    shobj=sodir+'sginr.so' & cmain='sgimain'
  endif
  if !version.os eq 'sunos' then begin
    shobj=sodir+'sunnr.so' & cmain='sunmain'
  endif
  if shobj eq 'NONE' then begin
    print, 'Sorry, the fortran versions are inaccessible.  SIGX, if it'
    print, 'was set, will be ignored.' & goto, nofort
  endif
  a=0. & b=a & siga=a & sigb=a & chi2=a & q=a & darg=0.D
  if not keyword_set(sigx) or mwt eq 0 then begin
    if keyword_set(sigx) then print, 'ignoring SIGX'
    iarg=long([ndata,mwt]) & if np eq 2 then sig=0.*x
    rarg = float([x,y,sig,a,b,siga,sigb,chi2,q])
    i = call_external(shobj,cmain,'fit',iarg,rarg,darg)
    fit_pars = rarg(3*ndata:*) & goto, done
  endif else begin
    iarg = long([ndata])
    rarg = float([x,y,sigx,sig,a,b,siga,sigb,chi2,q])
    i = call_external(shobj,cmain,'fitexy',iarg,rarg,darg)
    fit_pars = rarg(4*ndata:*) & goto,done
  endelse
endif

nofort:
;initialize sums to zero
sx = 0. & sy = 0. & st2 = 0. & b = 0.

;accumulate sums
if mwt ne 0 then begin
  ;with weights
  ss = 0. & wt = 1./sig^2
  sx = total(x*wt) & sy = total(y*wt) & ss = total(wt)
endif else begin
  ;without weights
  sx = total(x) & sy = total(y) & ss = float(ndata)
endelse

sxoss = sx/ss

if mwt ne 0. then begin
  t = (x-sxoss)/sig & st2 = total(t^2) & b = total(t*y/sig)
endif else begin
  t = (x-sxoss) & st2 = total(t^2) & b = total(t*y)
endelse

;solve for a,b,sig(a),sig(b)
b = b/st2 & a = (sy-sx*b)/ss
siga = sqrt((1.+sx*sx/(ss*st2))/ss) & sigb = sqrt(1./st2)

;compute chi^2
chi2 = 0.
if mwt eq 0 then begin
  chi2 = total((y-a-b*x)^2) & q = 1.
  ;for unweighted data, evaluate typical sig using chi2, and adjust siga & sigb
  sigdat = sqrt(chi2/(ndata-2)) & siga = siga*sigdat & sigb = sigb*sigdat
endif else begin
  chi2 = total(((y-a-b*x)/sig)^2)
  q = nrgammq(0.5*(ndata-2),0.5*chi2)
endelse

fit_pars = [a,b,siga,sigb,chi2,q]

done:
return,fit_pars
end
