#
# MAKEFILE
#	this is the makefile to compile and link Numerical Recipes
#	programs with a C-interface callable from IDL (idltonrf.c)

SGISO = sginr.so
SUNSO = sunnr.so

all:
	@echo "Usage: make MACH"
	@echo "  where MACH=[sgi,sun]"
	@echo "  other options are clean[_MACH], tidy[_MACH]"

sgi:
	cd SGI; make all

sun:
	cd SUN; make all

clean: clean_sgi clean_sun

clean_sgi:
	rm -f $(SGISO) ; cd SGI ; make clean

clean_sun:
	rm -f $(SUNSO) ; cd SUN ; make clean

tidy: tidy_sgi tidy_sun

tidy_sgi:
	cd SGI; make tidy

tidy_sun:
	cd SUN; make tidy
