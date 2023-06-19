/************************************************************************
  IDLTONRF.C
	This C function is a generic interface between IDL and a whole suite
	of Fortran subroutines.  In this case, the emphasis is on Numerical
	Recipes subroutines.
   USAGE
	In IDL use this as:
	so = '/path/name/idltonr.so'
	IDL> RESULT=CALL_EXTERNAL(so,'idltonrf',nr_name,iarg,rarg,darg)
	where
	  nr_name = string containing the name of the Fortran routine
	  iarg = pointer to all LONG (I*4) variables
	  rarg = pointer to all FLOAT (R*4) variables
	  darg = pointer to all DOUBLE (R*8) variables
   ADDING NEW.F
	1. declare the C function
	   int cnew(int *iarg, float *rarg, double *darg);
	   *before* idltonrf.
	2. declare char *new in idltonrf and initialize it to "new"
	3. add an if statement in idltonrf that will call cnew when
	   nr_name = 'new'
	4. recast *argv in cnew into a format usable by new.f
	   (see example at the end of this file)
	5. place a call to new_(appropriate arguments) within cnew
	6. add new.f and new.o to F_SRC and F_OBJ in Makefile
	7. make [sgi|sun]
   HISTORY
	vinay kashyap (5/24/95)
************************************************************************/

#include <stdio.h>
#include <string.h>

/* Declare the structure for an IDL string (From IDL User's Guide)	*/
typedef struct {
  unsigned short slen;			/* length of the string		*/
  short stype;				/* Type of string		*/
  char *s;				/* Pointer to chararcter array	*/
} IDLSTRING;

/* these are the FORTRAN subroutines accessible via this interface, eg:
int cnew(int *iarg, float *rarg, double *darg);				*/
int cfourn(int *iarg, float *rarg);
int cfour1(int *iarg, float *rarg);

void idltonrf(argc,argv)
int argc;
void *argv[];
{
  void fourn_();
  /* declare input variables */
  IDLSTRING	*nr_name;
  int		*iarg;
  float		*rarg;
  double	*darg;

  /* declare local variables: eg., char *new = "new"; */
  char *four1 = "four1";
  char *fourn = "fourn";
  int i, kndim, kisign;			/* these are for FOURN.F */
  int *nn, *ndim, *isign;		/* these are for FOURN.F */

  nr_name = (IDLSTRING *) argv[0];
  iarg    = (int *) argv[1];
  rarg    = (float *) argv[2];
  darg    = (double *) argv[3];

  /* add a conditional statement to call the appropriate subroutine: eg.,
  if (strcmp(nr_name->s,new) == 0) {
    printf("calling cnew\n");
    cnew(iarg,rarg,darg);
  } */

  /* FOUR1 */
  if (strcmp(nr_name->s,four1) == 0) {
    printf("calling cfour1\n");
    cfour1(iarg,rarg);
  }

  /* FOURN */
  /* hmph.  for some reason, this does not take kindly to being */
  /* called from a subroutine.  hence this 'direct approach'	*/
  if (strcmp(nr_name->s,fourn) == 0) {
    kndim = iarg[0]; kisign = iarg[1];
    ndim = &kndim; isign = &kisign; nn = &iarg[2];
    printf("calling fourn.f\n");
    fourn_(rarg,nn,ndim,isign);
  }

  /* RLFT3
  if (strcmp(nr_name->s,rlft3) == 0) {
    printf("calling crlft3\n");
    rlft3_(iarg,rarg,darg);
  } */

}

/***************************************************************
 example function, CNEW
 ***************************************************************
int cnew(int *iarg, float *rarg, double *darg) {
  void new_();
  		declare local variables:
  int karg1, karg2, ...;
  int *arg1;
  float *arg2;
  ...
  		reassign elements of *iarg, *rarg, *darg to kargI
  		make *iargI point to kargI
  printf("calling new.f\n");
  new_(arg1,arg2,arg3,arg4,...);
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
int cfour1(int *iarg, float *data) {
  void four1_();

  int knn, kisign;
  int *nn, *isign;

  knn = iarg[0]; kisign = iarg[1];
  nn = &knn; isign = &kisign;

  four1_(data,nn,isign);
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
 /* called directly from the "main" program */
