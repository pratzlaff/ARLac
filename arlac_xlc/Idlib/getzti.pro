pro getzti,tstep,toff,pzti,delti,t_beg,t_end,wrt=wrt
;+
;procedure:	getzti
;		given a time interval step [tstep] and an offset [toff],
;		returns a ':' separated string [pzti] of all ti's in a
;		given bin, and an array of all sub-intervals of each bin
;		concatanated [delti].  reads data from file TIFILE (formatted
;		as in hyb$info/atra_choosen.tims) and obtains equal time bins
;		by splitting the time intervals if necessary.
;parameters	tstep	time interval step for binning
;		toff	offset from the beginning of the observations
;		pzti	':' separated string of of ti's in given bin
;		delti	time subintervals
;		t_beg	beginning time of each interval
;		t_end	ending time of each interval
;keywords	wrt	if set, writes PROS readable-like output of ti's.
;-

;	initialize
c1 = '' & c2 = '' & pzti = '' & o1 = 0 & delti = [0.]

;	read in time intervals
TIFILE = '/home6/kashyap/Hybrids/Workpad/info/atra_chosen.tims'
NCOLTIFIL = 6 & NROWTIFIL = 43
TIFIL = '/home7/kashyap/Mcorona/adleo.tims' & NCOLTIFIL = 2 & NROWTIFIL = 15
TIFIL = '/home7/kashyap/Mcorona/gl644a.tims' & NCOLTIFIL = 2 & NROWTIFIL = 8
;
fil = TIFIL & ncol = NCOLTIFIL & nrow = NROWTIFIL
openr,1,fil & var = dblarr(ncol,nrow) & readf,1,var & close,1
t0 = reform(var(0,*)) & t1 = reform(var(1,*))

;	obtain cumulative observation times
delt = t1-t0 & for i=1,nrow-1 do delt(i) = delt(i) + delt(i-1)

;	correct for 'wrong' offsets
while -toff ge tstep do toff = toff + tstep
if toff ge delt(nrow-1) then begin
  print, 'no data beyond this offset' & return
endif

;	starting point
if toff lt 0. then begin
  tstrt = 0. & ttot = abs(toff)
endif else begin
  n0 = min(where(delt gt toff)) & tstrt = delt(n0) - toff
  tstrt = t1(n0) - tstrt & ttot = 0. & t0(n0) = tstrt
endelse

;	open file for writing time intervals
c1 = 'zti_'+strtrim(fix(tstep),2)+'_'+strtrim(fix(toff),2)
if keyword_set(wrt) then openw,2,c1

c1='time=('+strcompress(tstrt)+':' & o1 = 1 & tleft = tstep
t_beg = [tstrt] & k_end = 0

;	go through each TI, and break them down
for i=n0,nrow-1 do begin
  delt = t1(i)-t0(i) & pzti = pzti + strcompress(i) & tbeg = t0(i)
  ;
  ;	the case of a too large interval
  while delt gt tleft do begin
    if o1 gt 0 then begin
      if tbeg eq t0(i) then c1 = '      '+strcompress(t0(i))+':'
      c1 = c1 + strcompress(t0(i)+tleft) + ')'
      t0(i) = t0(i) + tleft & delt = t1(i) - t0(i)
      delti = [delti,tleft] & o1 = 0 & tleft = tstep
      if k_end eq 0 then begin
	t_end = [ t0(i) ] & k_end = k_end + 1
      endif else begin
	t_end = [t_end,t0(i)] & k_end = k_end + 1
      endelse
      pzti = pzti + ':' + strcompress(i)
      ;print, c1, delt, tleft, i, o1
      if keyword_set(wrt) then printf,2,c1
    endif else begin
      c1 = 'time=('+strcompress(t0(i))+':' & o1 = 1 & tleft = tstep
      t_beg = [t_beg,t0(i)]
    endelse
  endwhile
  ;
  ;	the case of a too small interval
  if delt le tleft then begin
    if o1 gt 0 then begin
      if o1 gt 1 then begin
        c1 = '      '+strcompress(t0(i))+':'+strcompress(t1(i))+','
      endif else begin
        c1 = c1 + strcompress(t1(i)) + ',' 
      endelse
      o1 = o1 + 1
    endif else begin
      c1 = 'time=('+strcompress(t0(i))+':'+strcompress(t1(i))+',' & o1 = 2
      t_beg = [t_beg,t0(i)]
    endelse
    tleft = tleft - delt & if tleft eq 0. then tleft = tstep
    delti = [delti,delt]
    ;print, c1, delt, tleft, i, o1
    if keyword_set(wrt) then printf,2,c1
  endif
  ;read, c2
  if i eq nrow-1 then begin
    if k_end eq 0 then begin
      t_end = [ t1(i)] & k_end = k_end + 1
    endif else begin
      t_end = [t_end,t1(i)] & k_end = k_end + 1
    endelse
  endif
endfor

if keyword_set(wrt) then close,2

return
end
