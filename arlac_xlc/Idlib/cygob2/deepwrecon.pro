pro deepwrecon,srcx,srcy,wavdir=wavdir,scales=scales,xedge=xedge,xfirst=xfirst,$
	sclmin=sclmin,sclmax=sclmax,srccor=srccor,verbose=verbose,$
	_extra=e
;+
;procedure	deepwrecon
;	run through the output of multi-obsid wtransforms for different scales,
;	extract the necessary files, identify sources and return their locations
;
;syntax
;	deepwrecon,srcx,srcy,wavdir=wavdir,scales=scales,/xedge,/xfirst,$
;	sclmin=sclmin,sclmax=sclmax,srccor=srccor,verbose=verbose
;
;parameters
;	srcx	[OUTPUT; required] sky-x coordinates of the source
;	srcy	[OUTPUT; required] sky-y coordinates of the source
;
;keywords
;	wavdir	[INPUT] path to directory under which to find the scale-wise wtransfrom outputs
;		* default is './'
;	scales	[INPUT] scales to include while merging sources
;		* must be an integer array
;		* if given, looks for directories named WAVDIR/ss##
;		* if not given, searches for and uses all the subdirs WAVDIR/ss##
;	xedge	[INPUT] if set, exclude any source that falls on an edge
;		as defined in merge_correl.fits in the given scale
;		* if set to something other than 1, excludes sources that
;		  fall on the edges in merge_correl.fits in _any_ of the scales
;		  -- this is only for debugging, don't use in analysis!
;	xfirst	[INPUT] if set, exclude sources that are found in only the
;		first scale
;	sclmin	[OUTPUT] smallest scale in which source was first found
;	sclmax	[OUTPUT] largest scale in which source was last found
;	srccor	[OUTPUT] largest correlation value (returned only for
;		entertainment -- not to be used for anything quantitative)
;	verbose	[INPUT] controls chatter
;		1: draws plots
;		>1000: STOPs at the end
;	_extra	[JUNK] here only to prevent crashing the program
;
;subroutines
;	IDLastro routines MRDFITS(), SXPAR(), etc.
;	PINTofALE routines MORFO_SEGMENTO(), PEASECOLR, KILROY,
;		RDB(), STR_2_ARR(), LEGALVAR()
;
;example
;	.run deepwrecon
;
;history
;	vinay kashyap (Dec2010)
;-

;	usage
np=n_params() & ok='ok'
if np lt 2 then ok='Insufficient parameters'
if ok ne 'ok' then begin
  print,'Usage: deepwrecon,srcx,srcy,wavdir=wavdir,scales=scales,/xedge,/xfirst,$'
  print,'       sclmin=sclmin,sclmax=sclmax,srccor=srccor,verbose=verbose'
  print,'  return locations of sources found for multi-obsid wavdetect'
  if np ne 0 then message,ok,/informational
  return
endif

;	keywords
vv=0L & if keyword_set(verbose) then vv=long(verbose[0])>1

if not keyword_set(wavdir) then wdir='./' else wdir=wavdir[0]
print,wavdir
ns=n_elements(scales)
if ns eq 0 then begin
  ff=file_search(wdir+'/ss*',/mark_directory,/test_directory,count=nf)
  if nf eq 0 then begin
    message,'No scale-specific directories found in '+wdir,/informational
    return
  endif
  ss=intarr(nf) & ndirlen=strlen(wdir)
  for i=0,nf-1 do ss[i]=long(strmid(ff[i],ndirlen+3,2))
  cs=string(ss,'(i2.2)') & sdir=ff
endif else begin
  ss=long(scales)
  cs=string(ss,'(i2.2)') & sdir=wdir+'/ss'+cs
endelse
ns=n_elements(ss)

;	read in merged cor img and merged thresholded image
for i=0L,ns-1L do begin
  srcimg=mrdfits(sdir[i]+'/merge_'+cs[i]+'0_'+cs[i]+'0_pos.fits',0,hsrc)
  xoff=sxpar(hsrc,'CRVAL1P') & yoff=sxpar(hsrc,'CRVAL2P')
  corimg=mrdfits(sdir[i]+'/merge_correl.fits',0,hcor)
  spawn,'cat '+sdir[i]+'/merge.thr',thrfil      ;this is the merged thresh file
  print,'ss'+cs[i]+'/'+thrfil[0]
  thr=mrdfits(sdir[i]+'/'+thrfil[0],0,hthr)

  ;	find the edges in CORIMG (to discount any source that lies on it)
  tmp=corimg ne 0 & tmp2=roberts(tmp) & oy=where(tmp2 ne 0)
  sz=size(tmp2) & mx=sz[1] & my=sz[2] & ixx=(oy mod mx)+xoff & jyy=(oy/mx)+yoff
  if i eq 0 then begin
    xxi=ixx & yyj=jyy
  endif else begin
    xxi=[xxi,ixx] & yyj=[yyj,jyy]
  endelse

  ;	find the locations of all the sources
  oimg=morfo_segmento(srcimg,areas,verbose=vv)
  ksrc=max(oimg) & sz=size(oimg) & nx=sz[1] & ny=sz[2]
  print,i,ss[i],ksrc
  if ksrc gt 0 then begin	;(are any sources found here?
    xpos=fltarr(ksrc) & ypos=xpos & cormax=xpos & thrmax=xpos & sclpos=intarr(ksrc)
    iedge=intarr(ksrc)	;flag to say whether it is close to some edge
    for j=0,ksrc-1L do begin
      oo=where(oimg eq j+1,moo)
      ii=oo mod nx & jj=oo/nx
      if moo eq 0 then message,'BUG!'
      cor=srcimg[oo]
      ;xpos[j]=total(cor*ii)/total(cor) & ypos[j]=total(cor*jj)/total(cor)
      cormax[j]=max(cor,imx) & thrmax[j]=max(thr[oo])
      xpos[j]=ii[imx]+xoff & ypos[j]=jj[imx]+yoff
      ; close to edge?
      if keyword_set(xedge) then begin
        if xedge[0] eq 1 then dd=sqrt((xpos[j]-ixx)^2+(ypos[j]-jyy)^2) else $	;remove only sources close to edge for current scale
         dd=sqrt((xpos[j]-xxi)^2+(ypos[j]-yyj)^2)					;remove sources close to edges from all scales
         oy=where(dd lt ss[i],moy) & if moy gt 0 then iedge[j]=1
      endif
    endfor
    ;	exclude anything close to edge if asked
    if keyword_set(xedge) then begin
      oy=where(iedge eq 1,moy,complement=oz)
      if moy gt 0 then begin
        ksrc=ksrc-moy
        if ksrc gt 0 then begin
          xpos=xpos[oz] & ypos=ypos[oz] & cormax=cormax[oz]
        endif
      endif
    endif
  endif				;KSRC>0)
  ;
  if i eq 0 then begin	;(for first scale, everything is a source
    if ksrc gt 0 then begin	;(just in case
      srcx=xpos & srcy=ypos & sclmin=0*srcx+ss[i] & sclmax=sclmin & srccor=cormax
    endif			;are there any sources to count?)
  endif else begin	;I=0)(scales I>0
    if not keyword_set(srcx) and ksrc gt 0 then begin	;(in case nothing has been found yet
      srcx=xpos & srcy=ypos & sclmin=0*srcx+ss[i] & sclmax=sclmin & srccor=cormax
    endif						;SRCX undefined and KSRC>0)
    for j=1L,ksrc do begin
      dd=sqrt((srcx-xpos[j-1])^2+(srcy-ypos[j-1])^2)
      ddmin=min(dd,imn)
      if ddmin le ss[i] then begin	;(src J of scale I has an overlap with existing source
	if srccor[imn]/ss[i-1]^2 le cormax[j-1]/ss[i]^2 then begin	;(new cormax < old cormax
          ; same old source
	endif else begin						;newcor<oldcor)(new cormax > old cormax
	  ; same old source, but with updated scale info
	  sclmax[imn]=ss[i]
	  srccor[imn]=cormax[j-1]
	endelse								;newcor>oldcor)
      endif else begin			;DDMIN<SS[I])(no overlap, new source
        if not keyword_set(newsrcx) then begin		;(start making new source list to avoid confusion with DD
	  newsrcx=[xpos[j-1]] & newsrcy=[ypos[j-1]] & newsclmin=[ss[i]] & newsclmax=newsclmin & newsrccor=[cormax[j-1]]
	endif else begin				;NEWSRCX)(add to new source list
	  newsrcx=[newsrcx,xpos[j-1]] & newsrcy=[newsrcy,ypos[j-1]]
	  newsclmin=[newsclmin,ss[i]] & newsclmax=[newsclmax,ss[i]]
	  newsrccor=[newsrccor,cormax[j-1]]
	endelse						;NEWSRCX)
      endelse				;DDMIN>SS[I])
    endfor
    if keyword_set(newsrcx) then begin
      ; add the new sources from this scale to the list
      nnew=n_elements(newsrcx)
      if n_elements(srcx) gt 0 then begin
        srcx=[srcx,newsrcx] & srcy=[srcy,newsrcy]
        sclmin=[sclmin,lonarr(nnew)+ss[i]] & sclmax=[sclmax,lonarr(nnew)+ss[i]]
        srccor=[srccor,newsrccor]
      endif else begin
        srcx=newsrcx & srcy=newsrcy & sclmin=0*srcx+ss[i] & sclmax=sclmin & srccor=newsrccor
      endelse
    endif
    newsrcx=0	;reset the counter
    if vv gt 0 then begin
      plot,xxi,yyj,/xs,/ys,/nodata
      oplot,xxi,yyj,psym=3,col=3,symsize=5
      if n_elements(srcx) gt 0 then begin
        uscl=uniq(sclmin,sort(sclmin)) & nuscl=n_elements(uscl)
        for j=0,nuscl-1 do begin
	  sclsiz=sclmin[uscl[j]]
          oo=where(sclmin eq sclsiz,moo)
	  if moo eq 0 then message,'BUG!'
	  for k=0,moo-1 do oplot,srcx[oo[k]]+sclsiz*[-1,1,1,-1,-1],srcy[oo[k]]+sclsiz*[-1,-1,1,1,-1]
        endfor
      endif
    endif
  endelse		;I>0)
endfor

;	exclude anything that has only been found in the first scale
if keyword_set(xfirst) then begin
  ox=where(sclmin eq ss[0] and sclmax eq ss[0],mox,complement=ok,ncomplement=mok)
  if mox gt 0 and vv gt 0 then begin
    oplot,srcx[ox],srcy[ox],psym=2,symsize=2
  endif
  if mok gt 0 then begin
    srcx=srcx[ok] & srcy=srcy[ok] & sclmin=sclmin[ok] & sclmax=sclmax[ok] & srccor=srccor[ok]
  endif
endif

if vv gt 1000 then stop,'HALTing; type .CON to continue'

return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	this is an example script that calls deepwrecon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	initialize inputs
peasecolr & loadct,3 & peasecolr
;if not keyword_set(wavdir) then wavdir='/data/cygob2/kashyap/testmosaic' & scales=[1,2,4,8,16,32]
if not keyword_set(wavdir) then wavdir='/data/cygob2/detection/v3/tiles/032/broad' & scales=[1,2,4,8,16,32]
if not keyword_set(verbose) then verbose=1

;	call deepwrecon
deepwrecon,srcx,srcy,wavdir=wavdir,scales=scales,/xedge,/xfirst,$
	sclmin=sclmin,sclmax=sclmax,srccor=srccor,verbose=verbose
nsrc=n_elements(srcx)

;	compare with regular run of wavdetect
s1=rdb('/data/cygob2/kashyap/automate/tiles/tile031/obs10954_ccd3_broad_wavdet_src_xy.rdb')
s2=rdb('/data/cygob2/kashyap/automate/tiles/tile031/obs10955_ccd2_broad_wavdet_src_xy.rdb')
s3=rdb('/data/cygob2/kashyap/automate/tiles/tile031/obs10957_ccd0_broad_wavdet_src_xy.rdb')
s4=rdb('/data/cygob2/kashyap/automate/tiles/tile031/obs10959_ccd1_broad_wavdet_src_xy.rdb')
;s1=mrdfits('/data/cygob2/data/baseline/v3/obs10954/ccd3/broad/wavdet_src.fits',1,h1)
;s2=mrdfits('/data/cygob2/data/baseline/v3/obs10955/ccd2/broad/wavdet_src.fits',1,h2)
;s3=mrdfits('/data/cygob2/data/baseline/v3/obs10957/ccd0/broad/wavdet_src.fits',1,h3)
;s4=mrdfits('/data/cygob2/data/baseline/v3/obs10959/ccd1/broad/wavdet_src.fits',1,h4)
xx=[s1.SKY_X,s2.SKY_X,s3.SKY_X,s4.SKY_X] & yy=[s1.SKY_Y,s2.SKY_Y,s3.SKY_Y,s4.SKY_Y] & nn=n_elements(xx)
;exx=[s1.X_ERR,s2.X_ERR,s3.X_ERR,s4.X_ERR] & eyy=[s1.Y_ERR,s2.Y_ERR,s3.Y_ERR,s4.Y_ERR]
exx=0*xx+0.2 & eyy=exx
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
print,'number of extra sources =',mok
;openw,uw,wavdir+'/deepwrecon.rdb',/get_lun
openw,uw,'/pool14/vinay/deepwrecon.rdb',/get_lun
printf,uw,'# extra sources detected with deepwavdetect'
printf,uw,'# SRCX: xpos of source'
printf,uw,'# SRCY: ypos of source'
printf,uw,'# CORMAX: max correlation value for source'
printf,uw,'srcx	srcy	cormax'
printf,uw,'N	N	N'
for i=0L,mok-1L do printf,uw,srcx[ok[i]],srcy[ok[i]],srccor[ok[i]]
close,uw & free_lun,uw

end
