;+
;ECF.PRO
;given an input spectrum, multiplies the spectrum with the given
;instrument response, and obtains the counting rate, and hence the
;ecf (energy to count conversion factor).
;inputs:     fev, the spectrum in units of ergs/s/cm^2/keV/deg^2
;	     kev, the corresponding frequencies, in keV
;	     cm2sr, the instrument response, in cm^2 sr (or just cm^2)
;	     aev, the corresponding frequencies, in keV
;output:     ctrate, the photon counting rate /second.
;-

;---first, determine passband
	print, 'which passband? [be/b/c/m1/m2/m/i/j/he26/e/r]'
	c1 = ' ' & read, c1
	if c1 eq 'be'   or c1 eq 'Be'   then b = 0
	if c1 eq 'b'    or c1 eq 'B'    then b = 1
	if c1 eq 'c'    or c1 eq 'C'    then b = 2
	if c1 eq 'm1'   or c1 eq 'M1'   then b = 3
	if c1 eq 'm2'   or c1 eq 'M2'   then b = 4
	if c1 eq 'i'    or c1 eq 'I'    then b = 5
	if c1 eq 'j'    or c1 eq 'J'    then b = 6
	if c1 eq 'he26' or c1 eq 'HE26' then b = 7
	if c1 eq 'm'    or c1 eq 'M'    then b = 8
	if c1 eq 'e'    or c1 eq 'E'    then b = 9
	if c1 eq 'r'    or c1 eq 'R'    then b = 10
	band = ['Be', 'B', 'C', 'M1', 'M2', 'I', 'J', '2-6', 'M', 'E', 'R']
	bmin = [0.078, 0.1,  0.15, 0.45, 0.65, 0.85, 1.15, 2.0, 0.45,$
	0.15, 0.13]
	;0.15, 0.1]
	bmax = [0.11,  0.18, 0.28, 0.65, 0.85, 1.15, 2.0,  6.0, 0.85,$
	4.0,  0.284]
	;4.0,  2.4]

;---feed in the instrument responses:

	if b eq 0 then begin
	  openr,1,'/home0/kashyap/Spektrum/WISC_Be'
	  iar = 234
	  c1 = ' ' & var = fltarr(2,iar)
;	  var(0,*) is eV, var(1,*) is cm^2*sr
	  readf,1,c1 & readf,1,c1 & readf,1,var & close,1
	  aev = reform(var(0,*))*1e-3 & cm2sr = reform(var(1,*))
	endif

	if b ge 1 and b le 8 then begin
	  openr,1,'/home0/kashyap/Spektrum/WISC_ALLSKY'
	  iar = 560
	  c1 = ' ' & var = fltarr(8,iar)
;	  var(0,*) is keV, var(1-7,*) is cm^2*sr for B,C,M1,M2,I,J & 2-6 keV
	  readf,1,c1 & readf,1,var & close,1
	  aev = reform(var(0,*)) 
	  if b lt 8 then cm2sr = reform(var(b,*))
	  if b eq 8 then cm2sr = reform(var(3,*)) + reform(var(4,*))
	endif

	if b eq 9 then begin
	  openr,1,'/home0/kashyap/Spektrum/IPC'
	  iar = 85
	  c1 = ' ' & var = fltarr(10,iar)
;	  var(0,*) is keV, var(5,*) is cm^2
	  readf,1,var & close,1
	  aev = reform(var(0,*)) & cm2sr = reform(var(5,*))*(!pi/180.)^2
	endif

	if b eq 10 then begin
	  openr,1,'/home0/kashyap/Spektrum/PSPC'
	  iar = 729
	  c1 = ' ' & var = fltarr(3,iar)
;	  var(0,*) is keV, var(2,*) is cm^2
	  readf,1,var & close,1
	  aev = reform(var(0,*)) 
	  cm2sr = reform(var(2,*))*(!pi/(60.*180.))^2
	endif
;	note: fev is later multiplied by (180/pi)^2, so for IPC & PSPC,
;	the factors (pi/180)^2 get cancelled.

;---now read in the spectrum:
	print, 'type in file name containing spectrum' & c1 = ' ' & read, c1
	print, 'how many points?' & nsp = 0 & read, nsp
	openr,1,'/home2/kashyap/Computfil/Distc/' + c1
	var = fltarr(4,nsp) & readf,1,var & close,1
	kev = reform(var(0,*)) & fev = reform(var(3,*)) & var = 0

	;openr,1,'/home0/kashyap/Module/2t.spec.all'
	;nsp = 100 & c1 = ' ' & readf,1,c1
	;var = fltarr(3,nsp) & readf,1,var & close,1
	;kev = reform(var(1,*)) & fev = reform(var(2,*)) & var = 0

;---multiply each fev(kev) [ergs/s/cm^2/keV/deg^2], by cm2sr(aev) [cm^2*sr]
;---and clean up the units of fev to [ph/s]
;---if b=9 or b=10 then the units of cm2sr is cm^2, not cm^2*sr
	area = 0.*kev

	for i=0,nsp-1 do begin

	  if i lt nsp-1 then bin = kev(i+1)-kev(i)
	  if i lt nsp-1 then ee = (kev(i)+kev(i+1))*0.5
	  if i eq nsp-1 then ee = bin + (kev(nsp-1)+kev(nsp-2))*0.5
;---      convert fev from /keV to /bin:
	  fev(i) = fev(i)*bin

	  area(i) = -1. 
	  if b eq 0 then begin
	    if ee le 0.025 or ee gt 1.251 then area(i) = 0.
	  endif
	  if b ge 1 and b le 8 then begin
	    if ee le 0.0425 or ee gt 10.58 then area(i) = 0.
	  endif
	  if b eq 9 then begin
	    if ee lt 0.1 or ee gt 6.5 then area(i) = 0.
	  endif
	  if b eq 10 then begin
	    if ee lt 0.075 or ee gt 3.005 then area(i) = 0.
	  endif

	  if area(i) lt 0. then begin
	    hit = where(ee ge aev)
	    if hit(0) eq -1 then stop & mhit = max(hit)
	    if ee eq aev(mhit) then area(i) = cm2sr(mhit)
	    if ee ne aev(mhit) then begin
	      if mhit eq iar-1 then area(i) = cm2sr(iar-1)
	      if mhit lt iar-1 then area(i) = cm2sr(mhit) + $
	      (cm2sr(mhit+1)-cm2sr(mhit)) * (ee-aev(mhit)) /$
	      (aev(mhit+1)-aev(mhit))
	    endif				;end ee ne aev(mhit)
	  endif					;end area(i) lt 0.
	endfor

;---convert fev from ergs to ph, deg^2 to sr:

	hit = where(kev ge bmin(b) and kev le bmax(b))
	fxed = total(fev(hit))
	fev = fev*(180./!pi)^2/(1.602e-9*kev)
;---count rate [ph/s]:
	ctrate = total(fev(hit)*area(hit))

;---energy to count conversion factor:
	eccf = (ctrate/fxed)*1e-13
	print, '---------------------------------------------------------'
	print, 'Band:',band(b),':',bmin(b),' - ',bmax(b),' keV'
	print, fxed,' ergs/s/cm^2/deg^2 gives ',ctrate,' ct/s(/deg^2 (E), /(arcmin)^2 (R) )'
	print, '1e-13 ergs/s/cm^2/deg^2 gives ',eccf,' ct/s  (/sr)'
	print, '1 ct/s gives ',1e-13/eccf, 'ergs/s/cm^2/deg^2'
	print, '---------------------------------------------------------'

	end
