#
# IRIX5.2 MAKEFILE
#	this is the makefile to compile and link Numerical Recipes
#	programs with a C-interface callable from IDL (idltonrf.c)

F_SRC = fourn.f four1.f spfourn.f fit.f gammq.f gser.f gcf.f gammln.f \
	fitexy.f avevar.f chixy.f mnbrak.f brent.f zbrent.f rlft3.f
F_OBJ = fourn.o four1.o spfourn.o fit.o gammq.o gser.o gcf.o gammln.o \
	fitexy.o avevar.o chixy.o mnbrak.o brent.o zbrent.o rlft3.o

C_SRC = sgimain.c sginrf.c
C_OBJ = sgimain.o sginrf.o

NRSO = ../sginr.so

C_FLAGS = -c -KPIC
F_FLAGS = -c -KPIC -static
LD_FLAGS = -shared -o
LD_LIBS = -lm -lftn -lc

all:	cobj fobj sobj

cobj:
	cc $(C_FLAGS) $(C_SRC)

fobj:
	f77 $(F_FLAGS) $(F_SRC)

sobj:
	ld $(LD_FLAGS) $(NRSO) $(C_OBJ) $(F_OBJ) $(LD_LIBS)

clean: tidy
	rm -f $(NRSO) 

tidy:
	rm -f $(C_OBJ) $(F_OBJ)

