;+
;freqompress.com
;	an example script to test the functionality of
;	freqompress()
;
;usage
;	@freqompress.com
;
;vinay kashyap (Aug03)
;-

;	find the background and expmap files for some ObsID, any ObsID
bfils=findfile('/proj/champx1/XPIPE/OBS00839/XPIPE/wav*B*bkg*')
efils=findfile('/proj/champx1/XPIPE/OBS00839/XPIPE/expmap*')
nbfils=n_elements(bfils)
ebfils=n_elements(efils)
if nbfils ne nefils then message,'INCOMPATIBLES wav*B*bkg* AND expmap* FILES!'

;	get the frequencies of unique background,exposure pixel pairs
fq1=freqompress( $
	bfils[0],$	;use only the first of the background files
	efils[0],$	;and the first of the expmap files
	/flatb,$	;this is needed because the backgrounds are flatfielded
	ethresh=0.5,$	;this ignores all values of EXPMAP < 0.5*max(EXPMAP)
	verbose=10)

if nbfils gt 1 then $
  fq2=freqompress(bfils[1:nbfils-1],$	;now include the rest of the background files
	efils[1:nefils-1],$		;now include the rest of the expmap files
	/flatb,$
	ethresh=0.5,$
	infq=fq1,$	;this is the prior info, and the output includes it
	verbose=10)

;	now some other ObsID
bfils=findfile('/proj/champx1/XPIPE/OBS00838/XPIPE/wav*B*bkg*')
efils=findfile('/proj/champx1/XPIPE/OBS00838/XPIPE/expmap*')

;	get new set of frequencies
fq3=freqompress(bfils,$		;all the new background filenames
	efils,$			;all the new expmap filenames
	/flatb, ethresh=0.5,$
	infq=fq2,$		;include result of previous run
	verbose=10)

;	and some other ObsID
bfils=findfile('/proj/champx1/XPIPE/OBS00841/XPIPE/wav*B*bkg*')
efils=findfile('/proj/champx1/XPIPE/OBS00841/XPIPE/expmap*')

;	update frequencies
fq2=freqompress(bfils,efils,/flatb,ethresh=0.5,$
	infq=fq3,$	;FQ3 was previous result, FQ2 is now overwritten
	verbose=10)

;	now write out an ASCII file containing the frequencies
fq=fq2
narr=n_elements(fq.IBG)
openw,ufq,'freqompress.out',/get_lun
printf,ufq,'#BKG ZERO POINT = ',fq.BZERO
printf,ufq,'#BKG DELTA = ',fq.BDELT
printf,ufq,'#EXPMAP ZERO POINT = ',fq.EZERO
printf,ufq,'#EXPMAP DELTA = ',fq.EDELT
printf,ufq,'#columns: BKG INDEX; EXPMAP INDEX; FREQUENCY: ALL, <2, 2-4, 4-6, 6-8, 8-10, 10-12, 12-14, 14-16, >16'
for i=0L,narr-1L do printf,ufq,(fq.IBG)[i],(fq.IEP)[i],(fq.IFQ)[i],$
	(fq.IFQ_00_02)[i], (fq.IFQ_02_04)[i], (fq.IFQ_04_06)[i],$
	(fq.IFQ_06_08)[i], (fq.IFQ_08_10)[i], (fq.IFQ_10_12)[i],$
	(fq.IFQ_12_14)[i], (fq.IFQ_14_16)[i], (fq.IFQ_16_00)[i],$
	form='(i6,1x,i6,1x,10(f10.2,1x))'
close,ufq & free_lun,ufq

message,'output is in file freqompress.out in the directory',/informational
spawn,'pwd'
