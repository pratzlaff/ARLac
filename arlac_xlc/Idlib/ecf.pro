function ecf,emin,emax,spec=spec,kev=kev,units=units,wis=wis,ein=ein,ros=ros
;+
;function	ecf
;		returns the energy-to-count conversion factor [ergs/cm^2/ct]
;		for the given instrument over the given passband
;
;parameters	emin	minimum energy of passband [keV]
;		emax	maximum energy of passband [keV]
;
;keywords	spec	input spectrum [ergs/s/cm^2/keV/...] {def: flat}
;			if scalar, of the form kev^(-spec)
;		kev	energy values at which spec is given [keV]
;		units	dimensions of input sectrum
;			if -ve, "/keV" is assumed to be "/bin" below
;			0: [ergs/s/cm^2/keV/deg^2]
;			1: [ergs cm^3/s/keV/...]
;			2: [ergs/s/cm^2/keV/sr]
;			3: [ph/s/cm^2/keV/deg^2]
;			4: [ph/s/cm^2/keV/sr]
;		wis	Wisconsin instrument responses
;			1:Be 2:B 3:C 4:M1 5:M2 6:I 7:J
;			8:H (High Energy 2-6 keV)
;		ein	Einstein effective areas
;			1:IPC 2:HRI
;		ros	1:PSPC-B 2:PSPC-C 3:HRI
;
;requires
;	files wis_Be, wis_B, wis_C, wis_M1, wis_M2, wis_I, wis_J, wis_H,
;	ein_ipc, ein_hri, ros_pb, ros_pc, ros_h
;	in the directory /home6/kashyap/Idlib/DATA/.
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: x = ecf(emin,emax,spec=spec,kev=kev,units={-4...4},$
  print, '           [wis={1...8}|ein={1,2}|ros={1...3}])'
  print, '  returns energy-to-count conversion factor [ergs/cm^2/ct]'
  return,0.
endif

if np eq 1 then emax = 10.*emin
en = (emax-emin)*findgen(100)/(100.-1.)+emin

if keyword_set(spec) then begin
  sz = size(spec)
  if sz(0) lt 1 then begin
    indx = spec & xs = en^(-indx)
  endif else begin
    if not keyword_set(kev) then stop,'kev not defined for input spectrum'
    xs = spec & en = kev
  endelse
endif else xs = 0.*en + 1.

if keyword_set(units) then begin
  if units lt 0 then xs = temporary(xs)/en
  ;multiply by an 'emission measure', (1/tmp) cm^-5
  if abs(units) eq 1 then begin
    tmp = total(xs)*(max(en)-min(en)) & xs = temporary(xs) / tmp
  endif
  ;convert to /deg^2
  if abs(units) eq 2 or abs(units) eq 4 then xs = temporary(xs)*(!pi/180.)^2
endif else units = 0

datadir = '/home6/kashyap/Idlib/DATA/'

if keyword_set(wis) then begin
  if wis eq 1 then fil = datadir + 'wis_Be'
  if wis eq 2 then fil = datadir + 'wis_B'
  if wis eq 3 then fil = datadir + 'wis_C'
  if wis eq 4 then fil = datadir + 'wis_M1'
  if wis eq 5 then fil = datadir + 'wis_M2'
  if wis eq 6 then fil = datadir + 'wis_I'
  if wis eq 7 then fil = datadir + 'wis_J'
  if wis eq 8 then fil = datadir + 'wis_H'
  nl = wc(fil) & var = fltarr(2,nl)
  openr,uw,fil,/get_lun & readf,uw,var & close,uw & free_lun,uw
  ;col 1: energy (evar) [keV], col 2: effective area (effar) [cm^2 sr]
  evar = reform(var(0,*)) & effar = reform(var(1,*)) & var = 0
  effar = temporary(effar)*(180./!pi)^2			;[cm^2 deg^2]
endif

if keyword_set(ein) then begin
  fil = datadir + 'ein_IPC'
  nl = wc(fil) & var = fltarr(2,nl)
  openr,ue,fil,/get_lun & readf,ue,var & close,ue & free_lun,ue
  ;col 1: energy (evar) [keV], col 2: effective area (effar) [cm^2]
  evar = reform(var(0,*)) & effar = reform(var(1,*)) & var = 0
endif

if keyword_set(ros) then begin
  fil = datadir + 'ros_PB'
  nl = wc(fil) & var = fltarr(2,nl)
  openr,ur,fil,/get_lun & readf,ur,var & close,ur & free_lun,ur
  ;col 1: energy (evar) [keV], col 2: effective area (effar) [cm^2]
  evar = reform(var(0,*)) & effar = reform(var(1,*)) & var = 0
endif

evmin = min(evar) & evmax = max(evar) & h1 = where(en ge evmin and en le evmax)
if h1(0) eq -1 then return,0.
area = 0.*en & nn = n_elements(h1)

for i=0,nn-1 do begin
  j = h1(i) & ee = en(j)
  hh = where(evar ge ee) & k = hh(0)
  if k eq -1 then stop,'bug in ECF.PRO'
  if k eq 0 then area(j) = effar(0)
  if k gt 0 then begin
    area(j) = effar(k-1)+(evar(k)-ee)*(effar(k)-effar(k-1))/(evar(k)-evar(k-1))
  endif
endfor

xs = 0.5*(xs(1:*)+xs) & de = en(1:*)-en & en = 0.5*(en(1:*)+en)
area = 0.5*(area(1:*)+area)
fx = total(xs*de)				;ergs/s/cm^2/...

;convert ergs to ph
if abs(units) lt 3 then xs = temporary(xs) / (en*1.602e-9)
ct = total(xs*area*de)				;ph/s/...

ecf = fx/ct					;ergs/cm^2/ct

return,ecf
end
