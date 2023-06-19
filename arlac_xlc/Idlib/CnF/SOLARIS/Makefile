#
# Solaris2.5 MAKEFILE
#	this is the makefile to compile and link Numerical Recipes
#	programs with a C-interface callable from IDL (idltonrf.c)

F_SRC = fourn.f four1.f spfourn.f fit.f gammq.f gser.f gcf.f gammln.f \
	fitexy.f avevar.f chixy.f mnbrak.f brent.f zbrent.f rlft3.f
F_OBJ = fourn.o four1.o spfourn.o fit.o gammq.o gser.o gcf.o gammln.o \
	fitexy.o avevar.o chixy.o mnbrak.o brent.o zbrent.o rlft3.o

C_SRC = solarismain.c solarisnrf.c
C_OBJ = solarismain.o solarisnrf.o

NRSO = ../solarisnr.so

C_FLAGS = -K pic -DSPARC -G -c
F_FLAGS = -pic -G -c
LD_FLAGS = -G
LD_LIBS = /usr/lang/SC1.0/libF77.a /usr/lang/SC1.0/libm.a 
#OPT_FTN_LIBS = -lF77 -lm -lc /opt/SUNWspro_3.0.1/SC3.0.1/lib/libsunmath.a
OPT_FTN_LIBS = -lF77 -lm -lc

all:	cobj fobj sobj

cobj:
	cc $(C_FLAGS) $(C_SRC)

fobj:
	f77 $(F_FLAGS) $(F_SRC)

sobj:
	f77 $(LD_FLAGS) -o $(NRSO) $(C_OBJ) $(F_OBJ) $(OPT_FTN_LIBS)

clean: tidy
	rm -f $(NRSO) 

tidy:
	rm -f $(C_OBJ) $(F_OBJ)

