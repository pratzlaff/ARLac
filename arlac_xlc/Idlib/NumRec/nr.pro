so='/home6/kashyap/Idlib/NumRec/sginr.so' & e_pt = 'sgimain'

rdvalue,'fitexy?',fitexy,'y',/ch
if fitexy ne 'y' then goto, nfitexy
  a=1.0 & b=5. & siga=0. & sigb=0. & chi2=0. & q=0.
  ndata=30 & sigx=randomn(seed,ndata) & sigy=randomn(seed,ndata)
  x=findgen(ndata)+sigx & y=a+b*x+sigy
  iarg=long([ndata])
  farg=[x,y,sigx,sigy,a,b,siga,sigb,chi2,q]
  darg=0.D
  nr_name='fitexy'
  goto, ok
nfitexy:

rdvalue,'fit?',fit,'y',/ch
if fit ne 'y' then goto, nfit
  a=1.0 & b=2. & siga=0. & sigb=0. & chi2=0. & q=0.
  ndata=30 & mwt=1
  x=findgen(ndata) & sig=randomn(seed,ndata) & y=a+b*x+sig
  iarg=long([ndata,mwt])
  farg=[x,y,sig,a,b,siga,sigb,chi2,q]
  darg=0.D
  nr_name='fit'
  print, farg(3*ndata:*)
  goto, ok
nfit:

rdvalue,'spfourn?',fourn,'y',/ch
if fourn ne 'y' then goto, nspfourn
  darg = [0.D] & nr_name = 'spfourn'
  sig=[4,16] & ndim = 2 & nn = [512,256] & isign = 1
  farg = shift(mexhat(ndim,nbin=nn,sig=sig),nn(0)/2,nn(1)/2)
  ;sig = [4] & ndim=1 & nn=[128] & isign=1
  ;farg = shift(mexhat(ndim,nbin=nn,sig=sig),nn(0)/2)
  h1 = where(abs(farg) lt 1e-8) & farg(h1)=0. & farg = complex(farg)
  iarg = long([ndim,isign,nn])
  ;tvscl,float(farg),0
  goto, ok
nspfourn:

rdvalue,'fourn?',fourn,'y',/ch
if fourn ne 'y' then goto, nfourn
  darg = [0.D] & nr_name = 'fourn'
  sig=[4,16] & ndim = 2 & nn = [512,256] & isign = 1
  farg = shift(mexhat(ndim,nbin=nn,sig=sig),nn(0)/2,nn(1)/2)
  ;sig = [4] & ndim=1 & nn=[128] & isign=1
  ;farg = shift(mexhat(ndim,nbin=nn,sig=sig),nn(0)/2)
  h1 = where(abs(farg) lt 1e-8) & farg(h1)=0. & farg = complex(farg)
  iarg = long([ndim,isign,nn])
  ;tvscl,float(farg),0
  goto, ok
nfourn:

rdvalue,'four1?',four1,'n',/ch
if four1 ne 'y' then goto, nfour1
  sig = 4
  nbin = 256 & isign = 1
  nr_name = 'four1'
  iarg = long([nbin,isign])
  farg = complex(shift(mexhat(1,nbin=[nbin],sig=sig),nbin/2))
  darg = 0.D
  goto, ok
nfour1:

goto, skip

ok: i=call_external(so,e_pt,nr_name,iarg,farg,darg)

skip:

end
