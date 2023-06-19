;+
;script	call_deepwrecon
;	calls deepwrecon to get the merged source list, filters out
;	the sources that have been already found, and writes out the
;	extra sources to a file
;
;usage
;	;these are necessary inputs
;	tilenum=32
;	band='broad'	;'broad','soft','medium','hard'
;
;	;these are optional inputs
;	wavdir='/data/cygob2/detection/v3/tile32/broad/'	;path to dir that contains scale subdirs
;	srcdir='/data/cygob2/kashyap/automate/tiles/tile031/'
;	outdir='/data/cygob2/kashyap/automate/tiles/tile031/'
;	scales=[1,2,4,8,16,32]	;scales to look at
;	
;	;and call deepwrecon
;	.run call_deepwrecon
;
;subroutines
;	IDLastro
;	DEEPWRECON [MORFO_SEGMENTO, KILROY]
;	PEASECOLR
;	RDB [STR_2_ARR, LEGALVAR]
;
;history
;	vinay k (2010dec14)
;	updated to account for new dir structures (VK; 2010dec18)
;-

;	initialize inputs
peasecolr & loadct,3 & peasecolr
if not keyword_set(tilenum) then tilenum=32
if not keyword_set(band) then band='broad'
;
if not keyword_set(wavdir) then wavdir='/data/cygob2/detection/v3'
if not keyword_set(srcdir) then srcdir='/data/cygob2/kashyap/automate/tiles'
if not keyword_set(outdir) then outdir='/data/cygob2/kashyap/automate/tiles'
;if not keyword_set(scales) then scales=[1,2,4,8,16,32]
if not keyword_set(verbose) then verbose=1
;
tiledir1='tile'+strtrim(tilenum,2)
tiledir2='tile'+string(tilenum-1,'(i3.3)')
;cwavdir=wavdir+'/'+tiledir1+'/'+band
;csrcdir=srcdir+'/'+tiledir2
;coutdir=outdir+'/'+tiledir2
cwavdir=wavdir
csrcdir=srcdir
coutdir=outdir

;	call deepwrecon
deepwrecon,$
	srcx,srcy,$	;source location x,y in physical coords
	wavdir=cwavdir,$	;path to directory that contains the ss## subdirectories
	scales=scales,$	;scales to look at
	/xedge,$	;exclude sources that fall on an edge in the masked correlation image
	/xfirst,$	;exclude sources that were found only in the first scale
	sclmin=sclmin,sclmax=sclmax,$	;which range of scales were the sources found at?
	srccor=srccor,$	;maximum of the correlations at all scales the source was found
	verbose=verbose	;controls chatter
nsrc=n_elements(srcx)

;	compare with regular run of wavdetect
origsrcfils=file_search(csrcdir+'/*'+band+'_wavdet_src_xy.rdb',count=nsfils)
if nsfils eq 0 then message,csrcdir+': does not contain any of the original source lists'

for i=0L,nsfils-1L do begin
  ;slst=mrdfits(origsrcfils[i],1,hslst)
  slst=rdb(origsrcfils[i])
  if i eq 0 then begin
    xx=slst.SKY_X & yy=slst.SKY_Y & exx=0*xx+0.2 & eyy=0*yy+0.2
  endif else begin
    xx=[xx,slst.SKY_X] & yy=[yy,slst.SKY_Y] & exx=[exx,0*slst.SKY_X+0.2] & eyy=[eyy,0*slst.SKY_Y+0.2]
  endelse
endfor
if verbose gt 0 then oplot,xx,yy,psym=7,col=2

;	exclude sources that have already been found
ikeep=lonarr(nsrc)+1
for i=0L,nsrc-1L do begin
  dd=sqrt((xx-srcx[i])^2+(yy-srcy[i])^2)
  edd=sqrt(exx^2+eyy^2+sclmax[i]^2)
  oo=where(dd lt edd,moo)
  if moo gt 0 then ikeep[i]=0
endfor
ok=where(ikeep eq 1,mok)
if mok gt 0 and verbose gt 0 then oplot,srcx[ok],srcy[ok],psym=7,col=1,thick=2

;	report
print,'' & print,'***> number of extra sources =',mok & print,''
openw,uw,coutdir+'/deepwrecon'+'_tile'+strtrim(tilenum,2)+'_'+band+'.rdb',/get_lun
printf,uw,'# extra sources detected with deepwavdetect'
printf,uw,'# SRCX: xpos of source'
printf,uw,'# SRCY: ypos of source'
printf,uw,'# SCLMIN: smallest scale in which source was found'
printf,uw,'# SCLMAX: largest scale in which source was found'
printf,uw,'# CORMAX: max correlation value for source'
printf,uw,'srcx	srcy	sclmin	sclmax	cormax'
printf,uw,'N	N	N	N	N'
for i=0L,mok-1L do printf,uw,srcx[ok[i]],srcy[ok[i]],sclmin[ok[i]],sclmax[ok[i]],srccor[ok[i]]
close,uw & free_lun,uw
spawn,'chmod a+r,g+w '+coutdir+'/deepwrecon'+'_tile'+strtrim(tilenum,2)+'_'+band+'.rdb'
spawn,'ls -l '+coutdir+'/deepwrecon'+'_tile'+strtrim(tilenum,2)+'_'+band+'.rdb'

end
