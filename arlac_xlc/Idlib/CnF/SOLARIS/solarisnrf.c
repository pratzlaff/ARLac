#include "solaris_nr.h"

/***************************************************************
 example function, CNEW
 ***************************************************************
int cnew(iarg,rarg,darg)
int *iarg; float *rarg; double *darg;
{
  		declare local variables:
  int karg1, karg2, ...;
  int *arg1;
  float *arg2;
  ...
  		reassign elements of *iarg, *rarg, *darg to kargN
  		make *argN point to kargN
  printf("calling new.f\n");
  new_(arg1,arg2,arg3,arg4,...);
  return 0;
}
 ***************************************************************/

/***************************************************************
  FUNCTION FOUR1(DATA,NN,ISIGN)
  FOUR1 replaces DATA by its discrete Fourier transform if ISIGN=1; or
  replaces DATA by its inverse discrete Fourier transform if ISIGN=-1.
  DATA is a complex array of length NN (or a real*4 array of length 2*NN).
  NN *must* be a power of 2!
  In IDL,
    iarg must be defined as iarg=long([nn,isign])
    rarg must be defined as rarg=complexarr(nn), or complex(fltarr(nn))
    darg can be anything, as long as it is defined.
 ***************************************************************/
int cfour1(iarg,data)
int *iarg;
float *data;
{
  int knn, kisign;
  int *nn, *isign;

  knn = iarg[0]; kisign = iarg[1];
  nn = &knn; isign = &kisign;

  printf("four1");
  four1_(data,nn,isign);
  printf("\b\b\b\b\b");
  return 0;
}

/***************************************************************
  FUNCTION FOURN(DATA,NN,NDIM,ISIGN)
  FOURN replaces DATA by its NDIM-dimensional discrete Fourier transform
  if ISIGN=1, and the discrete inverse Fourier transform if ISIGN=-1.
  NN is an integer array of length NDIM, containing the lengths of each
  dimension, which *must* be powers of 2.  DATA is a real array of length
  2*[NN(1)*NN(2)*...*NN(NDIM)].
  in IDL,
    iarg must be defined as iarg=long([ndim,isign,nn])
    rarg must be defined as rarg=complexarr(nn(0),...nn(ndim-1)) or
      rarg=complex(fltarr(nn(0),...nn(ndim-1)))
    darg can be anything, as long as it is defined.
 ***************************************************************/
int cfourn(iarg,rarg)
int *iarg;
float *rarg;
{
  int kndim, kisign;
  int *nn, *ndim, *isign;

  kndim = iarg[0]; kisign = iarg[1];
  ndim = &kndim; isign = &kisign; nn = &iarg[2];

  printf("fourn");
  fourn_(rarg,nn,ndim,isign);
  printf("\b\b\b\b\b");
  return 0;
}

/***************************************************************
  FUNCTION SPFOURN(DATA,NN,NDIM,ISIGN)
  Exactly as FOURN(DATA,NN,NDIM,ISIGN).  The only difference is the
  addition of some conditional statements in SPFOURN.F to take
  advantage of the lack of necessity of floating point operations
  while dealing with sparse matrices.
 ***************************************************************/
int cspfourn(iarg, rarg)
int *iarg;
float *rarg;
{
  int kndim, kisign;
  int *nn, *ndim, *isign;

  kndim = iarg[0]; kisign = iarg[1];
  ndim = &kndim; isign = &kisign; nn = &iarg[2];

  printf("spfourn");
  spfourn_(rarg,nn,ndim,isign);
  printf("\b\b\b\b\b\b\b");
  return 0;
}

/***************************************************************
  FUNCTION FIT(X,Y,NDATA,SIG,MWT,A,B,SIGA,SIGB,CHI2,Q)
  Given a set of NDATA points (X(I),Y(I)) with standard deviations
  SIG(I) on Y(I), FIT fits them to a straight line Y=A+B*X by minimizing
  \chi^2.  A, B, and their respective uncertainties SIGA and SIGB are
  returned, along with the \chi^2 CHI2 and the goodness-of-fit probability
  Q.  If MWT=0, SIG are assumed to be unavailable, Q is returned as 1.0,
  and CHI2 is normalized to unit std. deviation on all points.
  in IDL,
    iarg must be defined as long([ndata, mwt])
    rarg must be defined as float([x,y,sig,a,b,siga,sigb,chi2,q])
      where x=y=sig=fltarr(ndata), a=b=siga=sigb=chi2=q=float()
    darg can be anything, as long as it is defined.
 ***************************************************************/
int cfit(iarg,rarg)
int *iarg;
float *rarg;
{
  int i, kndata, kmwt;
  float xa, xb, xsiga, xsigb, xchi2, xq;
  int *ndata, *mwt;
  float *x, *y, *sig, *a, *b, *siga, *sigb, *chi2, *q;

  kndata = iarg[0]; kmwt = iarg[1];

  /* set aside storage space for the output */
  i = 3*kndata;
  xa = rarg[i]; xb = rarg[i+1]; xsiga = rarg[i+2]; xsigb = rarg[i+3];
  xchi2 = rarg[i+4]; xq = rarg[i+5];
  a = &xa; b = &xb; siga = &xsiga; sigb = &xsigb;
  chi2 = &xchi2; q = &xq;

  /* recast the input */
  ndata = &kndata; mwt = &kmwt;
  x = &rarg[0]; y = &rarg[kndata]; sig = &rarg[2*kndata];

  printf("fit");
  fit_(x,y,ndata,sig,mwt,a,b,siga,sigb,chi2,q);
  printf("\b\b\b");

  /* recast the output */
  i = 3*kndata;
  rarg[i]=a[0]; rarg[i+1]=b[0]; rarg[i+2]=siga[0]; rarg[i+3]=sigb[0];
  rarg[i+4]=chi2[0]; rarg[i+5]=q[0];

  return 0;
}

/***************************************************************
  FUNCTION FITEXY(X,Y,NDATA,SIGX,SIGY,A,B,SIGA,SIGB,CHI2,Q)
  Given NDATA input points (X(I),Y(I)) with errors in both x and y,
  SIGX(I) and SIGY(I), FITEXY fits them to a st.-line Y=A+B*X by
  minimizing \chi^2.  A, B, and their respective uncertainties SIGA and
  SIGB are returned, along with the \chi^2 CHI2 and the goodness-of-fit
  probability Q.
  in IDL,
    iarg must be defined as long(ndata)
    rarg must be defined as float([x,y,sigx,sigy,a,b,siga,sigb,chi2,q])
      where x=y=sigx=sigy=fltarr(ndata), a=b=siga=sigb=chi2=q=float()
    darg can be anything, as long as it is defined.
 ***************************************************************/
int cfitexy(iarg,rarg)
int *iarg;
float *rarg;
{
  int i, kndata;
  float xa, xb, xsiga, xsigb, xchi2, xq;
  int *ndata;
  float *x, *y, *sigx, *sigy, *a, *b, *siga, *sigb, *chi2, *q;

  kndata = iarg[0];

  /* set aside storage space for the output */
  i = 4*kndata;
  xa = rarg[i]; xb = rarg[i+1]; xsiga = rarg[i+2]; xsigb = rarg[i+3];
  xchi2 = rarg[i+4]; xq = rarg[i+5];
  a = &xa; b = &xb; siga = &xsiga; sigb = &xsigb;
  chi2 = &xchi2; q = &xq;

  /* recast the input */
  ndata = &kndata;
  x = &rarg[0]; y = &rarg[kndata];
  sigx = &rarg[2*kndata]; sigy = &rarg[3*kndata];

  printf("fitexy");
  fitexy_(x,y,ndata,sigx,sigy,a,b,siga,sigb,chi2,q);
  printf("\b\b\b\b\b\b");

  /* recast the output */
  i = 4*kndata;
  rarg[i]=a[0]; rarg[i+1]=b[0]; rarg[i+2]=siga[0]; rarg[i+3]=sigb[0];
  rarg[i+4]=chi2[0]; rarg[i+5]=q[0];

  return 0;
}

/***************************************************************
  FUNCTION RLFT3(DATA,SPEQ,NN1,NN2,NN3,ISIGN)
  Given a 2 or 3D real array DATA whose dimensions are NN1, NN2, NN3
  (where NN3=1 for a 2D array), RLFT3 returns the complex FFT of DATA
  as two complex arrays DATA (containing the 0 and +ve frequencies of
  the first component) and SPEQ (containing the FFT values at critical
  frequency of the first component) for ISIGN=1.  (Both +ve and -ve
  frequencies of the other components are stored in wraparound order.)
  The inverse transform*NN1*NN2*NN3/2 is returned for ISIGN=-1, with
  output real DATA deriving from input complex DATA.
  NN1, NN2, and NN3 *must* be powers of 2.
  in IDL,
    iarg must be defined as long([nn1,nn2,nn3,isign])
    rarg must be defined as float([data(*),speq(*)]), where
      data=fltarr(nn1,nn2,nn3) & speq=(2*nn2,nn3)
    darg can be anything, as long as it is defined.
 ***************************************************************/
int crlft3(iarg,rarg)
int *iarg;
float *rarg;
{
  /* define local variables */
  int i, knn1, knn2, knn3, kisign, ndata, nspeq;
  int *nn1, *nn2, *nn3, *isign;
  float *data, *speq;

  /* recast the input */
  knn1 = iarg[0]; knn2 = iarg[1]; knn3 = iarg[2]; kisign = iarg[4];
  ndata = knn1 * knn2 * knn3; nspeq = 2 * knn2 * knn3;
  data = &rarg[0]; speq = &rarg[ndata];

  printf("rlft3");
  rlft3_(data,speq,nn1,nn2,nn3,isign);
  printf("\b\b\b\b\b");

  /* recast the output */
  for (i=0;i<ndata;i++) {rarg[i]=data[i];};
  for (i=0;i<nspeq;i++) {rarg[i+ndata]=speq[i];};

  return 0;
}

