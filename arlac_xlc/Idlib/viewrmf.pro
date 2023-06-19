pro viewrmf,rmf,rmstr=rmstr,effar=effar,xr0=xr0,yr0=yr0, _extra=e
;+
;procedure	viewrmf
;	browse an OGIP-compatible Response Matrix File
;
;syntax
;	viewrmf,rmf,rmstr=rmstr,effar=effar,xr0=xr0,yr0=yr0
;
;parameters
;	rmf	[INPUT; required] name of OGIP-compatible Redistribution
;		Matrix File or structure read in via RD_OGIP_RMF()
;		* if not a structure that has the appropriate fields
;		  (see below), then looks to read in the matrix from
;		  the named file
;
;keywords
;	rmstr	[OUTPUT] if RMF is a filename, then output will be
;		placed in this variable as a structure of the form
;		{NNRG,ELO,EHI,NCHAN,EMN,EMX,N_GRP,F_CHAN,N_CHAN,MATRIX}
;		(see RD_OGIP_RMF())
;	effar	[OUTPUT] effective area as a function of RMSTR.ELO
;	xr0	[INPUT] zoom into effar in this Ang range
;	yr0	[INPUT] zoom into effar in this cm^2 range
;	_extra	[INPUT ONLY] use this to pass defined keywords to subroutines
;		-- PLOT
;
;restrictions
;	requires the IDLASTRO library
;	requires X-window display capabilities
;	requires function IS_KEYWORD_SET()
;
;history
;	vinay kashyap (Sep2001)
;	updated for IDL5.6 keyword_set([0]) behavior change for vectors
;	  (VK; 20Mar2006)
;-

;	usage
ok='ok' & np=n_params()
nr=n_elements(rmf) & szr=size(rmf) & nszr=n_elements(szr) & nrt=n_tags(rmf)
if np eq 0 then ok='Insufficient parameters' else $
 if nr eq 0 then ok='RMF undefined' else $
  if szr[nszr-2] ne 7 and nrt eq 0 then ok='RMF neither filename nor structure'
if ok ne 'ok' then begin
  print,'Usage: viewrmf,rmf,rmstr=rmstr,effar=effar,xr0=xr0,yr0=yr0'
  print,'  browse an OGIP-compatible RMF'
  if np ne 0 then message,ok,/info
  return
endif

;	check input and read file if necessary
if szr[nszr-2] eq 7 then begin	;(is a string
  if nr gt 0 then message,'using only first element of input RMF array',/info
  filnam=rmf[0]
  rmstr=rd_ogip_rmf(filnam)
endif else rmstr=rmf		;filename)

;	check structure for all relevant tag names
nrt=n_tags(rmstr) & rnam=tag_names(rmstr) & iok=0L
for i=0,nrt-1 do begin
  if rnam[i] eq 'ELO' then iok=iok+1L
  if rnam[i] eq 'EHI' then iok=iok+1L
  if rnam[i] eq 'EMN' then iok=iok+1L
  if rnam[i] eq 'EMX' then iok=iok+1L
  if rnam[i] eq 'N_GRP' then iok=iok+1L
  if rnam[i] eq 'F_CHAN' then iok=iok+1L
  if rnam[i] eq 'N_CHAN' then iok=iok+1L
  if rnam[i] eq 'MATRIX' then iok=iok+1L
  if rnam[i] eq 'FIRSTCHAN' then iok=iok+1L
endfor
if iok lt 8 then begin
  message,'RMF cannot be understood; returning',/info
  return
endif
shift1=rmstr.FIRSTCHAN

;	extract variables from RMF
elo=RMSTR.ELO & ehi=RMSTR.EHI	;the photon energies
whi=12.3985/elo & wlo=12.3985/ehi	;photon wavelengths
emn=RMSTR.EMN & emx=RMSTR.EMX	;the detector channels
wmx=12.3985/emn & wmn=12.3985/emx	;channel boundaries in wvl
n_grp=RMSTR.N_GRP	;number of non-zero groups
f_chan=RMSTR.F_CHAN	;first non-zero channel of each group
n_chan=RMSTR.N_CHAN	;number of non-zero channels in each group
rsp=RMSTR.MATRIX	;the non-zero numbers
szn=size(n_chan)

;	figure out effective area
nnrg=n_elements(elo) & effar=fltarr(nnrg)
effar=total(rsp,1)
;for i=0L,nnrg-1L do begin	;{for each photon energy
;  ngrp=n_grp[i] & jbeg=0
;  for j=0L,ngrp-1L do begin	;{for each group
;    if szn[0] gt 1 then iw=n_chan[j,i] else iw=n_chan[i]
;    ;iw=(reform(n_chan,ngrp,nnrg))[j,i]
;    if iw gt 0 then effar[i]=effar[i]+total(rsp[jbeg:jbeg+iw-1L,i])
;    jbeg=jbeg+iw
;  endfor			;J=0,NGRP-1}
;endfor				;I=0,NNRG-1}

;	sundry variables
;xr00=12.3985/[max(ehi),min(elo)] & yr00=[min(effar),max(effar)]
xr00e=[min(elo),max(ehi)]
if xr00e[0] eq 0 then xr00e[0]=min(ehi)
if finite(xr00e[1]) eq 0 then xr00e[1]=max(elo)
xr00=12.3985/reverse(xr00e)
yr00=[min(effar),min(effar)]
if finite(yr00[1]) eq 0 then yr00[1]=1.
if yr00[0] eq 0 then yr00[0]=yr00[1]/1e5
if is_keyword_set(xr0) then xr00=xr0
if is_keyword_set(yr0) then yr00=yr0
;xr00e=12.3985/reverse(xr00)
xr00=xr00e
xx=elo & xt0='ENERG_LO [keV]'
zz=emn & xt2='EMIN'

;	plot the effective area
window,0 & plot,xx,effar,xtitle=xt0,ytitle='EFFAR',$
	xrange=minmax(elo),yrange=minmax(effar),psym=1
window,2

;	and now plot the response at interactively selected energies
message,'LEFT BUTTON to view response at that energy',/info
message,'MIDDLE BUTTON for (enhanced) keyboard control',/info
message,'RIGHT BUTTON to exit program',/info
go_on=1
while go_on do begin		;{unending loop
  wset,0 & plot,xx,effar,xtitle=xt0,ytitle='EFFAR',xrange=xr00,yrange=yr00
  cursor,x,y,/up,/data

  if !MOUSE.BUTTON eq 1 then begin	;(show response at this energy/wavelength
    i0=0
    tmp=min(abs(xx-x),i0)
    if effar[i0] gt 0 then begin
    ngrp=n_grp[i0] & jbeg=0L
    fwhm=fltarr(ngrp)
    for j=0L,ngrp-1L do begin
      ;ibeg=(reform(f_chan,ngrp,nnrg))[j,i0]
      ;iw=(reform(n_chan,ngrp,nnrg))[j,i0]
      if szn[0] gt 1 then begin
	ibeg=f_chan[j,i0] & iw=n_chan[j,i0]
      endif else begin
	ibeg=f_chan[i0] & iw=n_chan[i0]
      endelse
      if keyword_set(shift1) then ibeg=ibeg-1	;IDL index correction, if necessary
      if j eq 0 then zz=emn[ibeg:ibeg+iw-1L] else zz=[zz,emn[ibeg:ibeg+iw-1L]]
      if j eq 0 then jj=lindgen(iw)+jbeg else jj=[jj,lindgen(iw)+jbeg]
      yy=rsp[jbeg:jbeg+iw-1L,i0] & ymx=max(yy,iy)
      x0=emn[ibeg] & x1=emn[ibeg+iw-1L]
      if iy gt 1 then x0=interpol((emn[ibeg:ibeg+iw-1L])[0:iy],yy[0:iy],0.5*ymx)
      if iy lt iw-1 then x1=interpol((emn[ibeg:ibeg+iw-1L])[iy:*],yy[iy:*],0.5*ymx)
      if not keyword_set(ikev) then x0=12.3984/x0
      if not keyword_set(ikev) then x1=12.3984/x1
      if j eq 0 then fwhm=abs(x1-x0) else fwhm=[fwhm,abs(x1-x0)]
      if j eq 0 then ymax=ymx else ymax=[ymax,ymx]
      if j eq 0 then xmax=(emn[ibeg:ibeg+iw-1L])[iy] else xmax=[xmax,(emn[ibeg:ibeg+iw-1L])[iy]]
      jbeg=jbeg+iw
    endfor
    endif else begin
      jj=lindgen(iw)
    endelse
    ;
    if not keyword_set(ikeV) then begin
      zz=12.3984/zz
      xmax=12.3984/xmax
      xx=12.3984/elo ;& xr0=[min(xx),max(xx)]
      xr00=12.3985/reverse(xr00e)
      xt0='ENERG_LO ['+string(byte(197))+']'
      xt2='EMIN ['+string(byte(197))+']'
    endif else begin
      xx=elo & xr0=[min(xx),max(xx)]
      xt0='ENERG_LO [keV]'
      xt2='EMIN [keV]'
    endelse
    ;
    xr2=[min(zz),max(zz)]
    wset,2
    plot,zz,rsp[jj,i0],xtitle=xt2,ytitle='RESPONSE',title=total(rsp[jj,i0]),$
	_extra=e
    for j=0,ngrp-1 do xyouts,xmax[j],ymax[j],'FWHM='+strtrim(fwhm[j],2),/align,/noclip
  endif					;LEFT)

  if !MOUSE.BUTTON eq 2 then begin	;(keyboard control of various extra features
    message,'nothing implemented yet!',/info
    print,'x to stop, anything else to continue'
    c='' & c=get_kbrd(1)
    if strlowcase(c) eq 'x' then stop,'HALTing.  type .CON to continue'
  endif					;MIDDLE)

  if !MOUSE.BUTTON eq 4 then go_on=0	;exit

endwhile			;GO_ON}

return
end
