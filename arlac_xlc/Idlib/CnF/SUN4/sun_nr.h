/************************************************************************
  SUNMAIN.C
	This C function is a generic interface between IDL and a whole suite
	of Fortran subroutines.  In this case, the emphasis is on Numerical
	Recipes (Press et al. 1986, 1992) subroutines.
   USAGE
	In IDL use this as:
	so = '/path/name/sunnr.so'
	IDL> RESULT=CALL_EXTERNAL(so,'sunmain',nr_name,iarg,rarg,darg)
	where
	  nr_name = string containing the name of the Fortran routine
	  iarg = pointer to all LONG (I*4) variables
	  rarg = pointer to all FLOAT (R*4) variables
	  darg = pointer to all DOUBLE (R*8) variables
   ADDING NEW.F
	1. In sun_nr.h:
	   a] declare the C wrapper routine
	      int cnew();
	   b] declare the FORTRAN subroutine
	      void new_();
	2. In sunmain.c:
	   a] declare a char pointer holding the name of the subroutine
	      char *new = "new"
	   b] place a call to cnew_() IF nr_name->s matches *new
	3. In sunnrf.c:
	   a] add the new funtion cnew()
	   b] recase *argv in cnew into a format usable by new.f
	      (see other entries for examples)
	   c] place a call to new_() with the appropriate arguments
	      AVOID editing the fortran subroutine!
	4. In Makefile:
	   a] add new.f and new.o to F_SRC and F_OBJ
	   b] make
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

/*
these are the FORTRAN subroutines accessible via this interface, eg:
int cnew();
void new_();
*/
int cfourn();
int cspfourn();
int cfour1();
int cfit();
int cfitexy();
int crlft3();
void fourn_();
void spfourn_();
void four1_();
void fit_();
void fitexy_();
void rlft3();

