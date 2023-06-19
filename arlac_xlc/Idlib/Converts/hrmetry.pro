function hrmetry,x,intyp=intyp,outyp=outyp,class=class,dbval=dbval
;+
;function	hrmetry
;		use to convert various astronomical measures of stars on
;		the HR diagram to and from each other.
;
;parameters	x	whatever is input to be converted
;			(the output of the function will be the converted
;			quantity)
;
;keywords	intyp	input variable type: should be one of
;			'MK', 'MV', 'MBOL', 'B-V', 'BC',
;			'LUM', 'TEFF', 'RAD', or 'MASS'
;			default is 'MK'
;		outyp	output variable type: can be any from the above list
;			default is 'MK'
;		class	luminosity class: 1-5 imply usual luminosity classes,
;			while 6=ZAMS, and 7=Subdwarf population
;			default is 5
;		dbval	2-element array of xrange to use for double-valued
;			functions
;
;usage
;	y = hrmetry(x,intyp=intyp,outyp=outyp,class=class)
;
;examples
;     *	to obtain the internal representation of MK types (see below) for a
;	given list of main sequence stellar temperatures, use
;	    MK = hrmetry(teff,intyp='teff')
;     *	to obtain M_bol corresponding to a list of M_v for stars on the main
;	sequence, use
;	    M_bol = hrmetry(M_v,intyp='MV',outyp='MBOL')
;     *	to obtain B-V corresponding to a list of supergiant luminosities, use
;	    bv = hrmetry(lum,intyp='lum',outyp='b-v',class=1)
;
;description
;     *	spectral types are "encoded" as follows: 
;	[O0, O9, B0, B9, A0, A9, F0, F9, G0, G9, K0, K9, M0, M9 ] = 
;	[ 0,  9, 10, 19, 20, 29, 30, 39, 40, 49, 50, 59, 60, 69 ]
;     *	the input list is first converted into the (above) internal
;	representation, which is then converted to the output type
;     * luminosity, radius, and mass are in log(solar units)
;
;references
;	Mihalas & Binney 1981, "Galactic Astronomy", Freeman:SanFransisco
;	    Tables 3-2, 3-3, 3-5, 3-6, 3-7
;
;subroutines
;	NR_SPLINE
;	NR_SPLINT
;
;history
;	vinay kashyap (12/30/94)
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: y = hrmetry(x,intyp=intyp,outyp=outyp,class=class)
  return,-1L
endif

if not keyword_set(class) then lclass=5 else lclass=fix(class)
if lclass lt 1 or lclass gt 7 then lclass=5

if not keyword_set(intyp) then xtyp='MK' else xtyp=strtrim(intyp,2)
if not keyword_set(outyp) then ytyp='MK' else ytyp=strtrim(outyp,2)
xtyp=strupcase(xtyp) & ytyp=strupcase(ytyp)

inmk=0 & inmv=0 & inmbol=0 & inbv=0 & inbc=0
inlum=0 & inteff=0 & inrad=0 & inmass=0
oumk=0 & oumv=0 & oumbol=0 & oubv=0 & oubc=0
oulum=0 & outeff=0 & ourad=0 & oumass=0
dblval=0

if xtyp eq 'MK' then inmk=1 & if ytyp eq 'MK' then oumk=1
if xtyp eq 'MV' then inmv=1 & if ytyp eq 'MV' then oumv=1
if xtyp eq 'MBOL' then inmbol=1 & if ytyp eq 'MBOL' then oumbol=1
if xtyp eq 'B-V' then inbv=1 & if ytyp eq 'B-V' then oubv=1
if xtyp eq 'BC' then inbc=1 & if ytyp eq 'BC' then oubc=1
if xtyp eq 'LUM' then inlum=1 & if ytyp eq 'LUM' then oulum=1
if xtyp eq 'TEFF' then inteff=1 & if ytyp eq 'TEFF' then outeff=1
if xtyp eq 'RAD' then inrad=1 & if ytyp eq 'RAD' then ourad=1
if xtyp eq 'MASS' then inmass=1 & if ytyp eq 'MASS' then oumass=1

if lclass eq 1 then begin
  inmv=0 & inmbol=0 & inbc=0 & inbv=0 & inteff=0 & inmass=0
  oumv=0 & oumbol=0 & oubc=0 & oubv=0 & outeff=0 & oumass=0
  ;
  mk = [0.,9.,10.,19.,20.,29.,30.,39.,40.,49.,50.,59.,60.,69.]
  if inmk then begin & v_in=mk & f_in=mk & endif
  if oumk then begin & v_ou=mk & f_ou=mk & endif
  ;
  lum = [5.4, 4.8, 4.3, 4.0, 3.9, 3.8, 3.8, 3.8, 3.9, 4.2, 4.5]
  lummk=[10., 15., 20., 25., 30., 35., 40., 45., 50., 55., 60.]
  if inlum then begin & v_in=lum & f_in=lummk & dblval=1 & endif
  if oulum then begin & v_ou=lummk & f_ou=lum & endif
  ;
  rad = [1.3, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.3, 2.6, 2.7]
  radmk=[10., 15., 20., 25., 30., 35., 40., 45., 50., 55., 60.]
  if inrad then begin & v_in=rad & f_in=radmk & endif
  if ourad then begin & v_ou=radmk & f_ou=rad & endif
endif

if lclass eq 2 then begin
  inmv=0 & inmbol=0 & inbc=0 & inbv=0 & inlum=0 & inteff=0 & inmass=0 & inrad=0
  oumv=0 & oumbol=0 & oubc=0 & oubv=0 & oulum=0 & outeff=0 & oumass=0 & ourad=0
  ;
  mk = [0.,9.,10.,19.,20.,29.,30.,39.,40.,49.,50.,59.,60.,69.]
  if inmk then begin & f_in=mk & v_in=mk & endif
  if oumk then begin & f_ou=mk & v_ou=mk & endif
endif

if lclass eq 3 then begin
  inmv=0 & inmbol=0 & inbc=0 & inbv=0 & inteff=0 & inmass=0
  oumv=0 & oumbol=0 & oubc=0 & oubv=0 & outeff=0 & oumass=0
  ;
  mk = [0.,9.,10.,19.,20.,29.,30.,39.,40.,49.,50.,59.,60.,69.]
  if inmk then begin & v_in=mk & f_in=mk & endif
  if oumk then begin & v_ou=mk & f_ou=mk & endif
  ;
  lum = [1.5, 1.7, 1.9, 2.3, 2.6, 3.0]
  lummk=[40., 45., 50., 55., 60., 65.]
  if inlum then begin & v_in=lum & f_in=lummk & endif
  if oulum then begin & v_ou=lummk & f_ou=lum & endif
  ;
  rad = [1.2, 1.0, 0.8, 0.6, 0.8, 1.0, 1.2, 1.4]
  radmk=[10., 15., 20., 35., 40., 45., 50., 55.]
  if inrad then begin & v_in=rad & f_in=radmk & dblval=1 & endif
  if ourad then begin & v_ou=radmk & f_ou=rad & endif
endif

if lclass eq 4 then begin
  inmv=0 & inmbol=0 & inbc=0 & inbv=0 & inlum=0 & inteff=0 & inmass=0 & inrad=0
  oumv=0 & oumbol=0 & oubc=0 & oubv=0 & oulum=0 & outeff=0 & oumass=0 & ourad=0
  ;
  mk = [0.,9.,10.,19.,20.,29.,30.,39.,40.,49.,50.,59.,60.,69.]
  if inmk then begin & v_in=mk & f_in=mk & endif
  if oumk then begin & v_ou=mk & f_ou=mk & endif
endif

if lclass eq 5 then begin
  ;
  mk = [0.,9.,10.,19.,20.,29.,30.,39.,40.,49.,50.,59.,60.,69.]
  if inmk then begin & v_in=mk & f_in=mk & endif
  if oumk then begin & v_ou=mk & f_ou=mk & endif
  ;
  ;the last 2 points (below) were added to prevent M_B and M_V curves from
  ;crossing.  MBOL-BC was used to get the points.
  mv = [-5.6,-4.8,-4.3,-1.0,0.7,1.9,2.5,3.3,4.4,5.2,5.9,7.3,8.8,10.0,12.8,$
	 16.7,18.6]
  mvmk=[ 5.,  9.,  10., 15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,62., 65.,$
	 67., 68.]
  if inmv then begin & v_in=mv & f_in=mvmk & endif
  if oumv then begin & v_ou=mvmk & f_ou=mv & endif
  ;
  bc = [-4.0, -3.5, -3.2, -3.0, -2.3, -1.85, -1.4, -0.9, -0.7, -0.2, -0.1,$
	-0.08, -0.01, -0.05, -0.1, -0.2, -0.6, -1.2, -2.5, -4.0]
  bcmk=[ 5.,   7.,   9.,   10.,  12.,  13.,   15.,  17.,  18.,  20.,  25.,$
	 30.,  35.,  40.,  45.,  50.,  55.,   60.,  65.,  68.]
  if inbc then begin & v_in=bc & f_in=bcmk & dblval=1 & endif
  if oubc then begin & v_ou=bcmk & f_ou=bc & endif
  ;
  bv = [-0.32, -0.31, -0.30, -0.26, -0.24, -0.20,$
	-0.16, -0.12, -0.09, -0.06,  0.00,  0.15,  0.29,  0.42,  0.58,$
	 0.69,  0.85,  1.16,  1.42,  1.61]
  bvmk=[ 5.,    8.,    10.,   11.,   12.,   13.,$
	 15.,   17.,   18.,   19.,   20.,   25.,   30.,   35.,   40.,$
	 45.,   50.,   55.,   60.,   65.]
  if inbv then begin & v_in=bv & f_in=bvmk & endif
  if oubv then begin & v_ou=bvmk & f_ou=bv & endif
  ;
  mbol = [-10.2, -8.9, -7.6, -6.3, -4.6, -2.9, -1.1, 0.7, 2.7, 4.7, 6.6,$
	   8.4,   9.7,  10.9, 12.1]
  mbolmk=[ 4.,    5.,   8.,   10.,  13.,  15.,  18., 22., 30., 42.,  55.,$
	   62.,   64.,  65.,  66.]
  if inmbol then begin & v_in=mbol & f_in=mbolmk & endif
  if oumbol then begin & v_ou=mbolmk & f_ou=mbol & endif
  ;
  lum = [5.7, 4.3, 2.9, 1.9, 1.3, 0.8, 0.4, 0.1, -0.1, -0.4, -0.8, -1.2, -2.1]
  lummk=[5.,  10., 15., 20., 25., 30., 35., 40.,  45.,  50.,  55.,  60.,  65.]
  if inlum then begin
    h1 = sort(lum) & v_in = lum(h1) & f_in = lummk(h1)
  endif
  if oulum then begin & v_ou=lummk & f_ou=lum & endif
  ;
  teff = [47000., 38000., 34000., 30500., 23000., 18500., 15000., 13000.,$
	  12000., 9500.,  8300.,  7300.,  6600.,  5900.,  5600.,  5100.,$
	  4200.,  3700.,  3000.,  2500.]
  teffmk=[5.,     7.,     9.,     10.,    12.,    13.,     15.,    17.,$
	  18.,    20.,    25.,    30.,    35.,    40.,     45.,    50.,$
	  55.,    60.,    65.,    68.]
  if inteff then begin
    h1 = sort(teff) & v_in=teff(h1) & f_in=teffmk(h1)
  endif
  if outeff then begin & v_ou=teffmk & f_ou=teff & endif
  ;
  mass = [ 1.8,  1.6,  1.4, 1.2, 1.0, 0.8, 0.6, 0.4, 0.2, 0.0, -0.2, -0.4,$
  	  -0.6, -0.8, -1.0]
  massmk=[ 4.,   5.,   8.,  10., 13., 15., 18., 22., 30., 42.,  55.,  62.,$
	   64.,  65.,  66.]
  if inmass then begin
    h1 = sort(mass) & v_in=mass(h1) & f_in=massmk(h1)
  endif
  if oumass then begin & v_ou=massmk & f_ou=mass & endif
  ;
  rad = [1.25,0.87,0.58,0.40,0.24,0.13,0.08,0.02,-0.03,-0.07,-0.13,-0.20,-0.50]
  radmk=[5.,  10., 15., 20., 25., 30., 35., 40.,  45.,  50.,  55.,  60.,  65.]
  if inrad then begin
    h1 = sort(rad) & v_in=rad(h1) & f_in=radmk(h1)
  endif
  if ourad then begin & v_ou=radmk & f_ou=rad & endif
endif

if lclass eq 6 then begin
  inmv=0 & inmbol=0 & inbc=0 & inbv=0 & inlum=0 & inteff=0 & inrad=0 & inmass=0
  oumv=0 & oumbol=0 & oubc=0 & oubv=0 & oulum=0 & outeff=0 & ourad=0 & oumass=0
  mk = [0.,9.,10.,19.,20.,29.,30.,39.,40.,49.,50.,59.,60.,69.]
  if inmk then begin & v_in=mk & f_in=mk & endif
  if oumk then begin & v_ou=mk & f_ou=mk & endif
endif

if lclass eq 7 then begin
  inmv=0 & inmbol=0 & inbc=0 & inbv=0 & inlum=0 & inteff=0 & inrad=0 & inmass=0
  oumv=0 & oumbol=0 & oubc=0 & oubv=0 & oulum=0 & outeff=0 & ourad=0 & oumass=0
  mk = [0.,9.,10.,19.,20.,29.,30.,39.,40.,49.,50.,59.,60.,69.]
  if inmk then begin & v_in=mk & f_in=mk & endif
  if oumk then begin & v_ou=mk & f_ou=mk & endif
endif

if (inmk+inmv+inmbol+inbc+inbv+inlum+inteff+inmass+inrad) eq 0 then begin
  print,'requested input type not implemented' & return,x
endif
if (oumk+oumv+oumbol+oubc+oubv+oulum+outeff+oumass+ourad) eq 0 then begin
  print,'requested output type not implemented' & return,x
endif

if dblval eq 1 then begin
  message,'input function is double valued!',/informational
  if not keyword_set(dbval) then begin
    c1='===================================='
    print,c1 & print, 'X=',v_in & print,c1 & print, 'Y=',f_in & print,c1
    print, 'type in min & max of Y values to consider.  if X is not monotonic
    print, 'in the specified range, results may be garbage!'
    read,a,b & dbval = [a,b]
  endif
  y0 = min(dbval,max=y1)
  h1 = where(f_in ge y0 and f_in le y1) & f_in = f_in(h1) & v_in = v_in(h1)
  h1 = sort(f_in) & f_in = f_in(h1) & v_in = v_in(h1)
endif

y2_in = nr_spline(v_in,f_in)
xx = nr_splint(v_in,f_in,y2_in,x)
y2_ou = nr_spline(v_ou,f_ou)
y = nr_splint(v_ou,f_ou,y2_ou,xx)

return,y
end
