function freqompress,bkg,emap,exptime=exptime,flatb=flatb,$
	infq=infq,bzero=bzero,bdelt=bdelt,ezero=ezero,edelt=edelt,$
	ethresh=ethresh,bnbin=bnbin,enbin=enbin,$
	x0nom=x0nom,y0nom=y0nom,platescale=platescale,$
	verbose=verbose, _extra=e
;+
;function	freqompress
;	compress a potentialy humongous set of image pairs
;	(such as background maps and expmaps) to a manageable
;	size by discretizing the values in each, making a
;	frequency table for each unique value pair, and
;	returning the list of these unique values and a
;	count of how many of each pair.  The output is an
;	IDL structure of the form
;		{BZERO, BDELT, EZERO, EDELT, IBG, IEP, IFQ,
;		IFQ_00_02,IFQ_02_04,IFQ_04_06,
;		IFQ_06_08,IFQ_08_10,IFQ_10_12,
;		IFQ_12_14,IFQ_14_16,IFQ_16_00}
;	where [B|E][ZERO|DELT] are defined below,
;		IBG = index corresponding to BKG,
;		IEP = index corresponding to EMAP,
;		IFQ = number of points in (BKG,EMAP)
;		      with (IBG[i],IEP[i])
;	and i=1..NUNIQ, where NUNIQ are the number of unique
;	pairs of (IBG[i],IEP[i]), and IFQ_AA_BB are the number
;	of unique pairs between off-axis angles AA and BB
;	(currently optimized for Chandra/ACIS data).
;
;	For a given pair, the BKG and EMAP values are
;		BZERO+BDELT*IBG[i] < BKG < BZERO+BDELT*(IBG[i]+1)
;	and	EZERO+EDELT*IEP[i] < EMAP < EZERO+EDELT*(IEP[i]+1)
;
;syntax
;	fq = freqcompress(bkg,emap,exptime=exptime,flatb=flatb,$
;	infq=infq,bzero=bzero,bdelt=bdelt,ezero=ezero,edelt=edelt,$
;	ethresh=ethresh,bnbin=bnbin,enbin=enbin,x0nom=x0nom,$
;	y0nom=y0nom,platescale=platescale,verbose=verbose)
;
;parameters
;	bkg	[INPUT; required] the background image(s)
;	emap	[INPUT; required] the exposure map(s)
;		* usually 2-D float arrays, doesn't really
;		  matter if multi-D or 1-D
;		* if string, taken to mean the full path to
;		  a FITS file and the image is read in from
;		  that file.  If image is not in the primary
;		  extension, be sure to specify the correct
;		  extension by appending a ",EXTEN_NO=#" to
;		  the actual filename.
;		* BKG and EMAP are supposed to be paired and
;		  matched pixel to pixel, so the number of
;		  elements _must_ match.
;		* if read in from FITS file, an additional
;		  calculation to split the frequency table
;		  into different regimes of off-axis angles
;		  are carried out.
;
;keywords
;	exptime	[INPUT] an exposure time to multiply EMAP with
;		prior to discretizing
;		* the default value for this is first determined
;		  from the header of EMAP (if FITS file), then if
;		  still undefined, from the header of BKG (if
;		  FITS file _and_ number of elements matches EMAP),
;		  and finally from this keyword.
;		* hardcoded default is 1.0
;	flatb	[INPUT] if set, assumes that the input background
;		has been flat-fielded and so multiplies BKG by
;		EMAP*FLATB/max(EMAP) prior to discretization
;		* if FLATB < 0, then multiplies by EMAP*abs(FLATB)
;		* ignored if there is a size mismatch between
;		  BKG and EMAP
;	infq	[INPUT] a pre-existing frequency table compilation,
;		whose values will be added on to the output, and
;		whose [B|E][ZERO|DELT] will override the keywords
;		below.
;	bzero	[INPUT] the 0-point for the BKG image values
;		* the default value is determined as follows:
;		- if INFQ is defined, take it from INFQ.BZERO
;		- otherwise, first filter EMAP to include only those
;		  pixels with values greater than max(EMAP)*ETHRESH
;		  and then min(BKG) from among these pixels
;		- 0 otherwise
;	bdelt	[INPUT] the discretization of the BKG values
;		* the default value is determined as follows:
;		- if INFQ is defined, take it from INFQ.BDELT
;		- otherwise, take the range of the BKG values
;		  filtered for ETHRESH as above, and compute the
;		  BDELT that produces BNBIN bins 
;	ezero	[INPUT] the 0-point for the EMAP image values
;		* the default value is determined as follows:
;		- if INFQ is defined, take it from INFQ.EZERO
;		- otherwise, use max(EMAP)*ETHRESH
;	edelt	[INPUT] the discretization of the EMAP values
;		* the default value is determined as follows:
;		- if INFQ is defined, take it from INFQ.EDELT
;		- otherwise, compute it such that there are
;		  ENBIN bins
;		NOTE: BZERO and EZERO are _always_ (re)set in the
;		output such that the smallest index in the column
;		is 0, regardless of what is input via INFQ, BZERO,
;		EZERO, and ETHRESH.
;	ethresh	[INPUT] a threshold below which to ignore EMAP values
;		and all BKG values corresponding to those pixels
;		* default is 0.1
;		* if >0 and <1, assumed to be a fraction
;		* if >1 and <100, assumed to be a percentage
;		* if >100, assumed to be an absolute threshold value
;		* if <0, abs(ETHRESH) is assumed to be an absolute value
;	bnbin	[INPUT] number of bins to bin the BKG values into
;		* default is 32
;	enbin	[INPUT] number of bins to bin the EMAP values into
;		* default is 32
;	x0nom	[INPUT] physical X-pixel location of nominal aim point
;		* default is 4096.5, corresponding to Chandra/ACIS
;	y0nom	[INPUT] physical Y-pixel location of nominal aim point
;		* default is 4096.5, corresponding to Chandra/ACIS
;	platescale	[INPUT] number of arcsec/pixel
;			* default is 0.5"
;	verbose	[INPUT]	controls chatter
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap (Jul03)
;	bug correction with zeroing (VK; Aug03)
;	updated for IDL5.6 keyword_set([0]) behavior change for vectors
;	  (VK; 28Mar2006)
;-

;	usage
ok='ok' & np=n_params() & nbkg=n_elements(bkg) & nemap=n_elements(emap)
if np lt 2 then ok='Insufficient parameters' else $
 if nbkg eq 0 then ok='BKG: not defined' else $
  if nemap eq 0 then ok='EMAP: not defined' else $
   if nbkg ne nemap then ok='BKG and EMAP appear to be incompatible'
if ok ne 'ok' then begin
  print,'Usage: fq = freqcompress(bkg,emap,exptime=exptime,flatb=flatb,$'
  print,'            infq=infq,bzero=bzero,bdelt=bdelt,ezero=ezero,edelt=edelt,$'
  print,'            ethresh=ethresh,bnbin=bnbin,enbin=enbin,$'
  print,'            x0nom=x0nom,y0nom=y0nom,platescale=platescale,$'
  print,'            verbose=verbose)'
  print,'  compress a potentialy humongous set of image pairs (such as background'
  print,'  maps and expmaps) to a manageable size by discretizing the values'
  print,'  in each, making a frequency table for each unique value pair, and'
  print,'  returning the list of these unique values and a count of how many'
  print,'  of each pair.'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	VERBOSE
vv=0 & if keyword_set(verbose) then vv=long(verbose[0])>1

;	[XY]0NOM
xnom=4096.5 & if n_elements(x0nom) gt 0 then xnom=float(x0nom[0])
ynom=4096.5 & if n_elements(y0nom) gt 0 then ynom=float(y0nom[0])

;	PLATESCALE
pltscl=0.5 & if keyword_set(platescale) then pltscl=float(platescale[0])

;	BKG
szb=size(bkg) & nszb=n_elements(szb) & nsliceB=1L & npixB=nbkg
if szb[0] gt 2 then begin	;(multi-D
  npixB=szb[1]*szb[2]
  for i=3L,szb[0]-1L do nsliceB=nsliceB*szb[i]
endif				;multi-D)
if szb[nszb-2L] eq 7 then nsliceB=nbkg	;array of filenames

;	EMAP
sze=size(emap) & nsze=n_elements(sze) & nsliceE=1L & npixE=nemap
if sze[0] gt 2 then begin	;(multi-D
  npixE=sze[1]*sze[2]
  for i=3L,sze[0]-1L do nsliceE=nsliceE*sze[i]
endif				;multi-D)
if sze[nsze-2L] eq 7 then nsliceE=nemap	;array of filenames

;	double check again
if nsliceE ne nsliceB or npixE ne npixB then begin
  message,'BKG and EMAP are incompatible',/informational
  return,-1L
endif
nslice=nsliceB & npix=npixB

;	EXPTIME
etime=dblarr(nsliceE)+1
if keyword_set(exptime) then begin
  nxp=n_elements(exptime)
  if nxp lt nsliceE then etime[0L:nxp-1L]=exptime[*] else $
   etime[*]=exptime[0L:nxp-1L]
endif

;	FLATB
bflat=dblarr(nsliceB)+1
if keyword_set(flatb) then begin
  if vv gt 0 then message,'BKG will be flat-fielded',/informational
  nbf=n_elements(flatb)
  if nbf lt nsliceB then bflat[0L:nbf-1L]=flatb[*] else $
   bflat[*]=flatb[0L:nbf-1L]
endif

;	correct for EXPTIME and FLATB
for i=0L,nslice-1L do begin		;{for each slice
  if szb[nszb-2L] eq 7 then begin	;(read from file
    cmdB='tmpB=readfits("'+bkg[i]+'",hdrB)'
    cmdE='tmpE=readfits("'+emap[i]+'",hdrE)'
    if vv gt 3 then print,cmdB,' ',cmdE
    jnk=execute(cmdB) & jnk=execute(cmdE)
    if keyword_set(tmpB) and keyword_set(tmpE) and $
     (n_elements(tmpB) eq n_elements(tmpE)) then begin
      eB=0 & eB=sxpar(hdrB,'EXPOSURE')
      if not keyword_set(eB) then eB=sxpar(hdrB,'LIVETIME')
      if not keyword_set(eB) then eB=sxpar(hdrB,'EXPTIME')
      if not keyword_set(eB) then etime[i]=eB
      eE=0 & eE=sxpar(hdrE,'EXPOSURE')
      if not keyword_set(eE) then eE=sxpar(hdrE,'LIVETIME')
      if not keyword_set(eE) then eE=sxpar(hdrE,'EXPTIME')
      if not keyword_set(eE) then etime[i]=eE
      ;	EXPOSURE
      tmpE=tmpE*eE
      ;	FLATB
      if keyword_set(flatb) then begin
	if bflat[i] gt 0 then tmpB=tmpB*(tmpE*bflat[i]/(max(tmpE)>1)) else $
	  tmpB=tmpB*(tmpE*abs(bflat[i]))
      endif
      ;	ETHRESH
      thrE=0.1
      if keyword_set(ethresh) then begin
	if ethresh[0] gt 0 and ethresh[0] lt 1 then thrE=ethresh[0]
	if ethresh[0] ge 1 and ethresh[0] lt 100 then thrE=ethresh[0]/100.
	if ethresh[0] ge 100 then thrE=ethresh[0]*max(tmpE)
	if ethresh[0] lt 100 then thrE=abs(ethresh[0])*max(tmpE)
      endif
      oE=where(tmpE gt thrE,moE)
      ;
      crval1=sxpar(hdrB,'CRVAL1P') & if not keyword_set(crval1) then crval1=sxpar(hdrE,'CRVAL1P')
      cdelt1=sxpar(hdrB,'CDELT1P') & if not keyword_set(cdelt1) then cdelt1=sxpar(hdrE,'CDELT1P')
      crval2=sxpar(hdrB,'CRVAL2P') & if not keyword_set(crval2) then crval1=sxpar(hdrE,'CRVAL2P')
      cdelt2=sxpar(hdrB,'CDELT2P') & if not keyword_set(cdelt2) then cdelt2=sxpar(hdrE,'CDELT2P')
      if not keyword_set(crval1) then crval1=0. & if not keyword_set(cdelt1) then cdelt1=0.
      if not keyword_set(crval2) then crval2=0. & if not keyword_set(cdelt2) then cdelt2=0.
      tmpO=0.*tmpB	;offaxis angles
      sz=size(tmpO) & nx=sz[1] & ny=sz[2]
      xo=findgen(nx)*cdelt1+crval1 & yo=findgen(ny)*cdelt2+crval2
      for k=0L,nx-1L do tmpO[k,*]=sqrt((xo[k]-xnom)^2+(yo-ynom)^2)*pltscl/60.	;[arcmin]
      ;message,'make off-axis angles image'
      ;
      ;	accumulate
      if moE gt 0 then begin
	if vv gt 3 then print,'Using '+strtrim(moE,2)+' of '+strtrim(n_elements(tmpE),2)+' pixels'
	if not (size(barr,/n_dim) gt 0 or keyword_set(barr)) then barr=[tmpB[oE]] else $
		barr=[barr,tmpB[oE]]
	if not (size(earr,/n_dim) gt 0 or keyword_set(earr)) then earr=[tmpE[oE]] else $
		earr=[earr,tmpE[oE]]
	if not (size(oarr,/n_dim) gt 0 or keyword_set(oarr)) then oarr=[tmpO[oE]] else $
		oarr=[oarr,tmpO[oE]]
      endif
    endif
  endif else begin			;file)(data array
    if not keyword_set(kmin) then kmin=0L & kmax=kmin+npix
    tmpB=bkg[kmin:kmax-1L] & tmpE=emap[kmin:kmax-1L]
    kmin=kmax & kmax=kmin+npix
    ;	EXPOSURE
    tmpE=tmpE*etime[i]
    ;	FLATB
    if keyword_set(flatb) then begin
      if bflat[i] gt 0 then tmpB=tmpE*bflat[i]/(max(tmpE)>1) else $
	tmpB=tmpE*abs(bflat[i])
    endif
    ;	ETHRESH
    thrE=0.1
    if keyword_set(ethresh) then begin
      if ethresh[0] gt 0 and ethresh[0] lt 1 then thrE=ethresh[0]
      if ethresh[0] ge 1 and ethresh[0] lt 100 then thrE=ethresh[0]/100.
      if ethresh[0] ge 100 then thrE=ethresh[0]*max(tmpE)
      if ethresh[0] lt 100 then thrE=abs(ethresh[0])*max(tmpE)
    endif
    oE=where(tmpE gt thrE,moE)
    ;	accumulate
    if moE gt 0 then begin
      if vv gt 3 then print,'Using '+strtrim(moE,2)+' of '+strtrim(n_elements(tmpE),2)+' pixels'
      if not (size(barr,/n_dim) gt 0 or keyword_set(barr)) then barr=[tmpB[oE]] else $
	barr=[barr,tmpB[oE]]
      if not (size(earr,/n_dim) gt 0 or keyword_set(earr)) then earr=[tmpE[oE]] else $
	earr=[earr,tmpE[oE]]
      if not (size(oarr,/n_dim) gt 0 or keyword_set(oarr)) then oarr=intarr(moE) else $
	oarr=[oarr,intarr(moE)]
    endif
  endelse				;SZB[NSZB-2])
endfor					;I=0,NSLICE-1}

if vv gt 5 then message,'completed reading in to BARR,EARR',/informational
if vv gt 100 then stop,'halting.  type .CON to continue'

;	double check
if n_elements(barr) ne n_elements(earr) then message,'BUG?!'

;	split according to offaxis
o_00_02=where(oarr le 02,mo_00_02)
o_02_04=where(oarr gt 02 and oarr le 04,mo_02_04)
o_04_06=where(oarr gt 04 and oarr le 06,mo_04_06)
o_06_08=where(oarr gt 06 and oarr le 08,mo_06_08)
o_08_10=where(oarr gt 08 and oarr le 10,mo_08_10)
o_10_12=where(oarr gt 10 and oarr le 12,mo_10_12)
o_12_14=where(oarr gt 12 and oarr le 14,mo_12_14)
o_14_16=where(oarr gt 14 and oarr le 16,mo_14_16)
o_16_00=where(oarr gt 16,mo_16_00)

;	BZERO
B0=min(barr) & if keyword_set(bzero) then B0=bzero[0]
;	EZERO
E0=min(earr) & if keyword_set(ezero) then E0=ezero[0]

;	BNBIN
nbinB=32L & if keyword_set(bnbin) then nbinB=long(bnbin[0])>1
;	ENBIN
nbinE=32L & if keyword_set(enbin) then nbinE=long(enbin[0])>1

;	BDELT
dB=(max(barr)-B0)/nbinB & if keyword_set(bdelt) then dB=float(bdelt[0])
;	EDELT
dE=(max(earr)-E0)/nbinE & if keyword_set(edelt) then dE=float(edelt[0])

;	INFQ
if n_tags(infq) gt 0 then begin
  tname=tag_names(infq)
  if tname[0] eq 'BZERO' and tname[1] eq 'BDELT' and $
  	tname[2] eq 'EZERO' and tname[3] eq 'EDELT' and $
  	tname[4] eq 'IBG' and tname[5] eq 'IEP' and $
	tname[6] eq 'IFQ' then begin
    B0=infq.(0) & E0=infq.(2)
    dB=infq.(1) & dE=infq.(3)
    oldibg=infq.(4)
    oldiep=infq.(5)
    oldifq=infq.(6)
    if n_elements(tname) gt 7 then oldifq_00_02 = infq.(7) else oldifq_00_02 = oldifq*0
    if n_elements(tname) gt 8 then oldifq_02_04 = infq.(8) else oldifq_02_04 = oldifq*0
    if n_elements(tname) gt 9 then oldifq_04_06 = infq.(9) else oldifq_04_06 = oldifq*0
    if n_elements(tname) gt 10 then oldifq_06_08 = infq.(10) else oldifq_06_08 = oldifq*0
    if n_elements(tname) gt 11 then oldifq_08_10 = infq.(11) else oldifq_08_10 = oldifq*0
    if n_elements(tname) gt 12 then oldifq_10_12 = infq.(12) else oldifq_10_12 = oldifq*0
    if n_elements(tname) gt 13 then oldifq_12_14 = infq.(13) else oldifq_12_14 = oldifq*0
    if n_elements(tname) gt 14 then oldifq_14_16 = infq.(14) else oldifq_14_16 = oldifq*0
    if n_elements(tname) gt 15 then oldifq_16_00 = infq.(15) else oldifq_16_00 = oldifq*0
  endif else begin
    if vv gt 2 then message,'INFQ not in standard format; ignoring',/informational
  endelse
endif

if vv gt 5 then message,'completed defining B0,E0,dB,dE',/informational
if vv gt 100 then stop,'halting.  type .CON to continue'

;	now convert the BKG and EMAP into integer indices
ibarr=floor((barr-B0)/dB) & iearr=floor((earr-E0)/dE)

if vv gt 5 then message,'completed making IBARR,IEARR',/informational
if vv gt 100 then stop,'halting.  type .CON to continue'

;	make frequency table of unique pairs
mxb=max(ibarr,min=mnb) & mxe=max(iearr,min=mne)
mbinb=(mxb-mnb)+1L & mbine=(mxe-mne)+1L
if mbinb le mbine then begin
  ;h=(ibarr-mnb)+mbinb*(iearr-mne)
  h=(iearr-mne)+mbine*(ibarr-mnb)
  for i=0L,mbinb-1L do begin
    hh=histogram(h,min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_00_02 eq 0 then hh_00_02=0*hh else hh_00_02=histogram(h[o_00_02],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_02_04 eq 0 then hh_02_04=0*hh else hh_02_04=histogram(h[o_02_04],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_04_06 eq 0 then hh_04_06=0*hh else hh_04_06=histogram(h[o_04_06],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_06_08 eq 0 then hh_06_08=0*hh else hh_06_08=histogram(h[o_06_08],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_08_10 eq 0 then hh_08_10=0*hh else hh_08_10=histogram(h[o_08_10],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_10_12 eq 0 then hh_10_12=0*hh else hh_10_12=histogram(h[o_10_12],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_12_14 eq 0 then hh_12_14=0*hh else hh_12_14=histogram(h[o_12_14],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_14_16 eq 0 then hh_14_16=0*hh else hh_14_16=histogram(h[o_14_16],min=i*mbine,max=(i+1L)*mbine-1L)
    if mo_16_00 eq 0 then hh_16_00=0*hh else hh_16_00=histogram(h[o_16_00],min=i*mbine,max=(i+1L)*mbine-1L)
    oh=where(hh gt 0,moh)
    if moh gt 0 then begin
      if not (size(iB,/n_dim) gt 0 or keyword_set(iB)) then begin
	iB = lonarr(moh)+i+mnb
	iE = oh+mne
	ifq = double(hh[oh])
	ifq_00_02 = double(hh_00_02[oh])
	ifq_02_04 = double(hh_02_04[oh])
	ifq_04_06 = double(hh_04_06[oh])
	ifq_06_08 = double(hh_06_08[oh])
	ifq_08_10 = double(hh_08_10[oh])
	ifq_10_12 = double(hh_10_12[oh])
	ifq_12_14 = double(hh_12_14[oh])
	ifq_14_16 = double(hh_14_16[oh])
	ifq_16_00 = double(hh_16_00[oh])
      endif else begin
	iB = [iB,lonarr(moh)+i+mnb]
	iE = [iE,oh+mne]
	ifq = [ifq,hh[oh]]
	ifq_00_02 = [ifq_00_02,double(hh_00_02[oh])]
	ifq_02_04 = [ifq_02_04,double(hh_02_04[oh])]
	ifq_04_06 = [ifq_04_06,double(hh_04_06[oh])]
	ifq_06_08 = [ifq_06_08,double(hh_06_08[oh])]
	ifq_08_10 = [ifq_08_10,double(hh_08_10[oh])]
	ifq_10_12 = [ifq_10_12,double(hh_10_12[oh])]
	ifq_12_14 = [ifq_12_14,double(hh_12_14[oh])]
	ifq_14_16 = [ifq_14_16,double(hh_14_16[oh])]
	ifq_16_00 = [ifq_16_00,double(hh_16_00[oh])]
      endelse
    endif
  endfor
endif else begin
  ;h=(iearr-mne)+mbine*(ibarr-mnb)
  h=(ibarr-mnb)+mbinb*(iearr-mne)
  for i=0L,mbine-1L do begin
    hh=histogram(h,min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_00_02 eq 0 then hh_00_02=0*hh else hh_00_02=histogram(h[o_00_02],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_02_04 eq 0 then hh_02_04=0*hh else hh_02_04=histogram(h[o_02_04],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_04_06 eq 0 then hh_04_06=0*hh else hh_04_06=histogram(h[o_04_06],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_06_08 eq 0 then hh_06_08=0*hh else hh_06_08=histogram(h[o_06_08],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_08_10 eq 0 then hh_08_10=0*hh else hh_08_10=histogram(h[o_08_10],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_10_12 eq 0 then hh_10_12=0*hh else hh_10_12=histogram(h[o_10_12],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_12_14 eq 0 then hh_12_14=0*hh else hh_12_14=histogram(h[o_12_14],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_14_16 eq 0 then hh_14_16=0*hh else hh_14_16=histogram(h[o_14_16],min=i*mbinb,max=(i+1L)*mbinb-1L)
    if mo_16_00 eq 0 then hh_16_00=0*hh else hh_16_00=histogram(h[o_16_00],min=i*mbinb,max=(i+1L)*mbinb-1L)
    oh=where(hh gt 0,moh)
    if moh gt 0 then begin
      if not (size(iB,/n_dim) gt 0 or keyword_set(iB)) then begin
	iB = oh+mnb
	iE = lonarr(moh)+i+mne
	ifq = double(hh[oh])
	ifq_00_02 = double(hh_00_02[oh])
	ifq_02_04 = double(hh_02_04[oh])
	ifq_04_06 = double(hh_04_06[oh])
	ifq_06_08 = double(hh_06_08[oh])
	ifq_08_10 = double(hh_08_10[oh])
	ifq_10_12 = double(hh_10_12[oh])
	ifq_12_14 = double(hh_12_14[oh])
	ifq_14_16 = double(hh_14_16[oh])
	ifq_16_00 = double(hh_16_00[oh])
      endif else begin
	iB = [iB,oh+mnb]
	iE = [iE,lonarr(moh)+i+mne]
	ifq = [ifq,hh[oh]]
	ifq_00_02 = [ifq_00_02,double(hh_00_02[oh])]
	ifq_02_04 = [ifq_02_04,double(hh_02_04[oh])]
	ifq_04_06 = [ifq_04_06,double(hh_04_06[oh])]
	ifq_06_08 = [ifq_06_08,double(hh_06_08[oh])]
	ifq_08_10 = [ifq_08_10,double(hh_08_10[oh])]
	ifq_10_12 = [ifq_10_12,double(hh_10_12[oh])]
	ifq_12_14 = [ifq_12_14,double(hh_12_14[oh])]
	ifq_14_16 = [ifq_14_16,double(hh_14_16[oh])]
	ifq_16_00 = [ifq_16_00,double(hh_16_00[oh])]
      endelse
    endif
  endfor
endelse
nrow=n_elements(ifq)
print,nrow
if vv gt 5 then message,'completed making frequency table of unique pairs',/informational
if vv gt 100 then stop,'halting.  type .CON to continue'

;	append preexisting table
if n_tags(infq) gt 0 then begin
  mrow=n_elements(oldifq)
  bmax=max(iB) > max(oldibg)
  emax=max(iE) > max(oldiep)
  bmin=min(iB) < min(oldibg)
  emin=min(iE) < min(oldiep)
  hn=(iB-bmin) + (bmax-bmin)*(iE-emin)
  hm=(oldibg-bmin) + (bmax-bmin)*(oldiep-emin)
  for i=0L,mrow-1L do begin
    oi=where(hm[i] eq hn,moi)
    if moi eq 0 then begin
      iB=[iB,oldibg[i]]
      iE=[iE,oldiep[i]]
      ifq=[ifq,oldifq[i]]
      ifq_00_02 = [ifq_00_02,oldifq_00_02[i]]
      ifq_02_04 = [ifq_02_04,oldifq_02_04[i]]
      ifq_04_06 = [ifq_04_06,oldifq_04_06[i]]
      ifq_06_08 = [ifq_06_08,oldifq_06_08[i]]
      ifq_08_10 = [ifq_08_10,oldifq_08_10[i]]
      ifq_10_12 = [ifq_10_12,oldifq_10_12[i]]
      ifq_12_14 = [ifq_12_14,oldifq_12_14[i]]
      ifq_14_16 = [ifq_14_16,oldifq_14_16[i]]
      ifq_16_00 = [ifq_16_00,oldifq_16_00[i]]
    endif else begin
      ifq[oi[0]]=ifq[oi[0]]+oldifq[i]
      ifq_00_02[oi[0]] = ifq_00_02[oi[0]]+oldifq_00_02[i]
      ifq_02_04[oi[0]] = ifq_02_04[oi[0]]+oldifq_02_04[i]
      ifq_04_06[oi[0]] = ifq_04_06[oi[0]]+oldifq_04_06[i]
      ifq_06_08[oi[0]] = ifq_06_08[oi[0]]+oldifq_06_08[i]
      ifq_08_10[oi[0]] = ifq_08_10[oi[0]]+oldifq_08_10[i]
      ifq_10_12[oi[0]] = ifq_10_12[oi[0]]+oldifq_10_12[i]
      ifq_12_14[oi[0]] = ifq_12_14[oi[0]]+oldifq_12_14[i]
      ifq_14_16[oi[0]] = ifq_14_16[oi[0]]+oldifq_14_16[i]
      ifq_16_00[oi[0]] = ifq_16_00[oi[0]]+oldifq_16_00[i]
    endelse
  endfor
  if vv gt 5 then message,'completed appending preexisting table',/informational
  if vv gt 100 then stop,'halting.  type .CON to continue'
endif

;	reset BZERO and EZERO
ibmin=min(iB) & iemin=min(iE)
B0=B0+ibmin*dB & E0=E0+iemin*dE
iB=iB-ibmin & iE=iE-iemin

if vv gt 5 then message,'completed re-zeroing',/informational
if vv gt 100 then stop,'halting.  type .CON to continue'

;	output
fq=create_struct('BZERO',B0,'BDELT',dB,'EZERO',E0,'EDELT',dE,'IBG',iB,'IEP',iE,'IFQ',ifq,$
	'IFQ_00_02',ifq_00_02,'IFQ_02_04',ifq_02_04,'IFQ_04_06',ifq_04_06,$
	'IFQ_06_08',ifq_06_08,'IFQ_08_10',ifq_08_10,'IFQ_10_12',ifq_10_12,$
	'IFQ_12_14',ifq_12_14,'IFQ_14_16',ifq_14_16,'IFQ_16_00',ifq_16_00)

if vv gt 5 then message,'all done. exiting',/informational

return,fq
end
