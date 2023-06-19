#include "solaris_nr.h"

void solarismain(argc,argv)
int argc;
void *argv[];
{
  /* declare input variables */
  IDLSTRING	*nr_name;
  int		*iarg;
  float		*rarg;
  double	*darg;

  /* declare local variables: eg., char *new = "new"; */
  char *four1 = "four1";
  char *fourn = "fourn";
  char *spfourn = "spfourn";
  char *fit = "fit";
  char *fitexy = "fitexy";
  char *rlft3 = "rlft3";

  nr_name = (IDLSTRING *) argv[0];
  iarg    = (int *) argv[1];
  rarg    = (float *) argv[2];
  darg    = (double *) argv[3];

  /* add a conditional statement to call the appropriate subroutine: eg.,
  if (strcmp(nr_name->s,new) == 0) {
    cnew(iarg,rarg,darg);
  } */

  /* FOUR1 */
  if (strcmp(nr_name->s,four1) == 0) {
    cfour1(iarg,rarg);
    return;
  }

  /* FOURN */
  if (strcmp(nr_name->s,fourn) == 0) {
    cfourn(iarg,rarg);
    return;
  }

  /* SPFOURN */
  if (strcmp(nr_name->s,spfourn) == 0) {
    cspfourn(iarg,rarg);
    return;
  }

  /* RLFT3 */
  if (strcmp(nr_name->s,rlft3) == 0) {
    crlft3(iarg,rarg);
    return;
  }

  /* FIT */
  if (strcmp(nr_name->s,fit) == 0) {
    cfit(iarg,rarg);
    return;
  }

  /* FITEXY */
  if (strcmp(nr_name->s,fitexy) == 0) {
    cfitexy(iarg,rarg);
    return;
  }

}
