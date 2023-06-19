;+
;PROCEDURE	CALLRS
;		The IDL interface to the Raymond-Smith Thermal Spectrum Code
;
;USAGE
;		callrs,ptev,ev,ptang,ang
;		[,h2h1=h2h1][,parrst=parrst][,infil=infil][,temp=temp]
;		[,dens=dens][,/clean]
;
;PARAMETERS
;		ptev	P(T) [*1e-23 ergs cm^3 s^-1], the power emitted from 1
;			cm^3 of plasma in a given ev bin
;		ev	eV bin positions at which P(T) is computed
;		ptang	P(T) [*1e-23 ergs cm^3 s^-1], the power emitted from 1
;                       cm^3 of plasma in a given A bin
;		ang	Angstrom bin positions at which P(T) is computed
;
;KEYWORDS
;		h2h1	the ratio of ionized to neutral H
;		infil	if set to a filename, takes the input from the
;			named file (overrides keyword PARRST), where the
;			relevant quantities are stored in the following
;			format:
;			line 1 -- NBIN BINMIN BINSYZ
;			line 2 -- NBLN BLNMIN BLNSYZ
;			(if NBLN < 0, BLNMIN and BLNSYZ are (re)computed
;			during runtime)
;			line 3 -- NUM IPRINT JPRINT IPHOT IDENS ICX
;			line 4 -- log10(T) log10(DENSITY)
;			line 5 -- RF1(=1?) ABSEL(0/1/2/3)
;			(ABSEL refers to the choice of abundance models:
;			0:Allen 1:Coronal 2:Photospheric 3:STDIN)
;			line 6 -- ABUNDANCES(0:11) (overrides ABSEL=3)
;			(it is NOT necessary to have all lines present in
;			the input file, but it IS necessary to have no gaps
;			in line numbers. eg: you may leave out lines 5 & 6)
;		parrst	an array containing the parameters.
;			parrst(0:2): nbin,binmin,binsyz
;			parrst(3:5): nbln,blnmin,blnsyz
;			parrst(6:11): num,iprint,jprint,iphot,idens,icx
;			parrst(12): log_10(T [K])
;			parrst(13): log_10(n_e [cm^-3])
;			parrst(14:15): rf1, absel
;			parrst(16:27): abundances (overrides absel=3)
;			NOTE: if scalar, uses hardcoded default settings
;			NOTE: as with INFIL, entire array need not be defined
;		temp	if set, sets log(T [K]); overrides all other settings
;		dens	if set, sets log(n_e [cm^-3]); overrides all settings
;		clean	if set, deletes the *.dat files created by the code
;
;DESCRIPTION
;	The RS Thermal Spectral code is in Fortran.  It is a collection
;	of subroutines, put together in a single file, named rstherm.f,
;	and whose calling sequence is coordinated by the Fortran subroutine
;	callrs.f
;	IDL requires an interface to callrs.f, and that function is
;	performed by the C program rsidl.c
;	The Fortran programs are compiled as
;		> f77 -c -pic callrs.f rstherm.f
;	and the C program is compiled as
;		> cc -pic -fsingle -c rsidl.c
;	on Suns, and the objects are combined into a shared object with
;	the command
;		> /usr/bin/ld -o rsidl.so rsidl.o callrs.o rstherm.o \
;		/usr/lang/SC1.0/libF77.a /usr/lang/SC1.0/libm.a
;	The spectral code is then called by *this* procedure in IDL using
;	the call_external function, after determining all the relevant
;	input parameters
;
;RESTRICTIONS
;	Only demonstrated to work on SunOS 4.1.x and IRIX 5.2
;	The spectral code leaves droppings in $cwd
;
;SUBROUTINES
;	GETABUN.PRO (attached)
;	RDVALUE.PRO
;	SUNRS.SO [SUNRSF.C, SUNRS.F, RSCODE_SUN.F]
;	SGIRS.SO [SGIRSF.C, SGIRS.F, RSCODE_SGI.F]
;	RSIDL.SO (from RSIDL.C, CALLRS.F, RSTHERM.F /home6/kashyap/RStherm/)
;
;HISTORY
; vinay kashyap (10/7/93)
; ported to SGI IRIX 5.2 (2/13/95; vk)
;-

;-------------------------------------------------------------------------

pro getabun,abunj
;little procedure to assign abundances 'by hand'

elem = [ 'He', 'C', 'N', 'O', 'Ne', 'Mg', 'Si', 'S', 'Ar', 'Ca', 'Fe', 'Ni' ]
numb = strtrim(1+indgen(n_elements(elem)),2)
num = 1

while num gt 0 and num lt 13 do begin
  print, ' *'+numb+'('+elem+'):'+strtrim(abunj,2)
  print, 'Number, abundance? (type 0 0 when done)'
  read, num,abund
  if num gt 0 and num lt 13 then abunj(num-1) = abund
endwhile

return
end

;-------------------------------------------------------------------------

pro callrs,ptev,ev,ptang,ang,h2h1=h2h1,parrst=parrst,infil=infil,$
	temp=temp,dens=dens,clean=clean

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: callrs,ptev,ev,ptang,ang,h2h1=h2h1,parrst=parrst,infil=infil,$'
  print, '  temp=logT,dens=log(n_e),/clean'
  print, '  IDL interface to Raymond-Smith Thermal Spectrum'
  return
endif

;;;;;;;;;
;directory containing interface code
;;;;;;;;;
dir = '/home/kashyap/Idlib/RStherm/'

;;;;;;;;;
;default parameters
;;;;;;;;;
nbin = 100 & binmin = 100. & binsyz = 100.
nbln = 0 & blnmin = 0. & blnsyz = 0.
num = 12 & iprint = 2 & jprint = 1 & iphot = 0 & idens = 0 & icx = 0
logt = 6. & logd = 10.
rf1 = 1. & absel = 0

;;;;;;;;;
;abundances
;;;;;;;;;
;  default is from Allen (1973)
abunj = [ 10.93,8.52,7.96,8.82,7.92,7.42,7.52,7.2,6.9,6.3,7.6,6.3 ]
;  option of coronal abundances (Anders & Grevasse 1989)
abcor = [ 10.14,7.90,7.40,8.30,7.46,7.59,7.55,6.93,5.89,6.46,7.65,6.22 ]
;  option of photospheric abundances (Anders & Grevasse 1989)
abphot = [ 10.99,8.56,8.05,8.93,8.09,7.58,7.55,7.21,6.56,6.36,7.67,6.25 ]

;;;;;;;;;
;decipher keywords
;;;;;;;;;
if keyword_set(infil) then begin
  openr,uin,strtrim(infil,2),/get_lun
  tmpar=[0.]
  while (not eof(uin)) do begin
    readf,uin,tmp & tmpar=[tmpar,tmp]
  endwhile
  close,uin & free_lun,uin
  if n_elements(tmpar) gt 1 then begin
    tmpar=tmpar(1:*)
    if keyword_set(parrst) then parrst(0)=tmpar else parrst=tmpar
  endif
endif
if keyword_set(parrst) then begin
  sz = size(parrst)
  if sz(0) eq 1 then begin
    if sz(1) ge 1 then nbin = fix(parrst(0))
    if sz(1) ge 2 then binmin = float(parrst(1))
    if sz(1) ge 3 then binsyz = float(parrst(2))
    if sz(1) ge 4 then nbln = fix(parrst(3))
    if sz(1) ge 5 then blnmin = float(parrst(4))
    if sz(1) ge 6 then blnsyz = float(parrst(5))
    if sz(1) ge 7 then num = fix(parrst(6))
    if sz(1) ge 8 then iprint = fix(parrst(7))
    if sz(1) ge 9 then jprint = fix(parrst(8))
    if sz(1) ge 10 then iphot = fix(parrst(9))
    if sz(1) ge 11 then idens = fix(parrst(10))
    if sz(1) ge 12 then icx = fix(parrst(11))
    if sz(1) ge 13 then logt = float(parrst(12))
    if sz(1) ge 14 then logd = float(parrst(13))
    if sz(1) ge 15 then rf1 = float(parrst(14))
    if sz(1) ge 16 then absel = fix(parrst(15))
    if absel eq 1 then abunj = abcor
    if absel eq 2 then abunj = abphot
    if sz(1) lt 28 and absel eq 3 then getabun,abunj
    if sz(1) eq 28 then abunj = float(parrst(16:27))
  endif
endif

if keyword_set(temp) then logt = temp & if keyword_set(dens) then logd = dens

;;;;;;;;;
;read in input parameters
;;;;;;;;;
if not keyword_set(parrst) and not keyword_set(infil) then begin
  print, 'NBIN(100), BINMIN(100), BINSYZ(100)' & read,nbin,binmin,binsyz
  print, 'NBLN(100/0), BLNMIN(1), BLNSYZ(0.1)' & read,nbln,blnmin,blnsyz
  ;NOTE: if nbln < 0, blnmin/blnsyz are computed from binmin/binsyz and
  ;nbln is set to -nbln
  print, 'NUM(12),IPRINT(2),JPRINT(1),IPHOT(0),IDENS(0),ICX(0)'
  read,num,iprint,jprint,iphot,idens,icx
  c1 = 'Abundance code [0:Allen 1:Coronal 2:Photospheric 3:STDIN 4:FILE]'
  rdvalue,c1,absel,0,/i
  if absel eq 1 then abunj = abcor
  if absel eq 2 then abunj = abphot
  if absel eq 3 then getabun,abunj
  if absel eq 4 then begin
    rdvalue,'file containing abundances?',abfil,'',/ch
    openr,uab,abfil,/get_lun & readf,uab,abunj & close,uab & free_lun,uab
    print, 'Abundances are:',abunj
  endif
  if not keyword_set(temp) then rdvalue,'log(T)',logt,logt
  if not keyword_set(dens) then rdvalue,'log(n_e)',logd,logd
endif

if nbln lt 0 then begin
  binmax = binmin + nbin*binsyz & blnmin = 12398.54/binmax
  nbln = -nbln
  blnmax = 12398.54/binmin & blnsyz = (blnmax-blnmin)/(nbln-1.)
endif

if !quiet gt 0 then begin
  print, 'nbin,binmin,binsyz',nbin,binmin,binsyz
  print, 'nbln,blnmin,blnsyz',nbln,blnmin,blnsyz
  print, 'num,iprint,jprint,iphot,idens,icx',num,iprint,jprint,iphot,idens,icx
  print, 'logt,logd',logt,logd
  print, 'rf1,absel',rf1,absel
endif

ev = findgen(nbin)*binsyz + binmin
if nbln gt 0 then ang = findgen(nbln)*blnsyz + blnmin

;;;;;;;;;
;set up input to C interface
;;;;;;;;;
RHY = 0.					;NOTE: RHY is *output*
iput = [nbin, nbln, num, iprint, jprint, iphot, idens, icx] & iput=long(iput)
rput = [binmin, binsyz, blnmin, blnsyz, abunj, logt, logd, rf1, RHY]

ptev = fltarr(nbin) & ptang = ptev & phbin = ptev

;;;;;;;;;
;call the Raymond-Smith Thermal Spectral code
;;;;;;;;;
;this is the part that is SUN specific.  Apparently, in HP, IBM, etc., you
;don't need the preceding underscore in "_rsidl".  they must be compiled
;separately and all that, of course.

if !version.os eq 'sunos' then begin
  i=call_external(dir+'sunrs.so','_sunrsf',iput,rput,ptev,ptang,phbin)
endif
if !version.os eq 'IRIX' then begin
  i=call_external(dir+'sgirs.so','sgirsf',iput,rput,ptev,ptang,phbin)
endif

h2h1 = rput(19)

;;;;;;;;;
;clean up
;;;;;;;;;
if keyword_set(clean) then spawn,'rm file1.dat file2.dat answers.dat'

return
end
