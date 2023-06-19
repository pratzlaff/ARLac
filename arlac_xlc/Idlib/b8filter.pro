function b8filter,sbit,sfilter,verbose=verbose, _extra=e
;+
;function	b8filter
;	filter on multi-column 8-bit "status" arrays, such as those found in
;	Chandra datasets
;
;syntax
;	sok=b8filter(sbit,sfilter,verbose=verbose)
;
;parameters
;	sbit	[INPUT; required] 4-column byte array containing the status
;		information.
;		* MUST be bytes, and each column has information about
;		  8 bits apiece
;	sfilter	[INPUT] string of "x"s and "1"s describing which
;		bit positions to filter on
;		* bit positions with "x"s are not filtered, those with
;		"0"s (excluded) and "1"s (included) are.
;		* default is the Chandra HRC-S/LETG filter,
;		  xxxxxx00xxxx0xxx0000x000x00000xx
;		* if it is a string array, then it is first concatenated
;		  with STRJOIN and then used
;		* if integer array, 0s and 1s have the usual meaning and
;		  everything else is assumed to be an "x"
;		* for that matter, everything is assumed to be an "x" even
;		  in a string array if it is not a 0 or a 1.
;		* only the first NCOL*8 characters/elements are used
;		* if fewer than NCOL*8, then the rest are padded out with "0"s
;
;keywords
;	verbose	[INPUT] controls chatter
;	_extra	[JUNK] here only to avoid crashing the program
;
;subroutines
;	b11001001
;	kilroy
;
;history
;	vinay kashyap (May02)
;-

;	usage
ok='ok' & np=n_params()
nb=n_elements(sbit) & szb=size(sbit) & nszb=n_elements(szb)
if np eq 0 then ok='Insufficient parameters' else $
 if nb eq 0 then ok='StatusBIT: undefined' else $
  if szb[0] gt 2 then ok='SBIT: must be 2-dimensional array'
   if szb[nszb-2] ne 1 then ok='SBIT: must be a byte array'
if ok ne 'ok' then begin
  print,'Usage: sok=b8filter(sbit,sfilter)'
  print,'  filter status array bitwise'
  if np ne 0 then message,ok,/info
  return,-1L
endif

;	initialize
;each column holds information on 8 bits
ncol=1 & nrow=1 & nbyt=8
if szb[0] gt 1 then ncol=szb[1]
if szb[0] gt 1 then nrow=szb[2]
if szb[0] gt 1 then nbyt=ncol*8

;	keywords
vv=0L & if keyword_set(verbose) then vv=long(verbose[0]) > 1

;	now let's see what the filter looks like
def_filt='xxxxxx00xxxx0xxx0000x000x00000xx'	;the default
nf=n_elements(sfilter) & szf=size(sfilter) & nszf=n_elements(szf)
if nf ne 0 then begin
  filt=sfilter[0]
  if szf[nszf-2] eq 7 then begin
    if nf gt 1 then filt=strmid(strjoin(sfilter),0,nbyt)
    lfilt=strlen(filt)
    if lfilt lt nbyt then filt=filt+strjoin(replicate('0',nbyt-lfilt))
  endif else begin
    nn=nf < nbyt
    filt=strjoin(replicate('0',nn))
    for i=0,nn-1 do begin
      if byte(sfilter[i]) eq 0 then strput,filt,'0',i else $
       if byte(sfilter[i]) eq 1 then strput,filt,'1',i
    endfor
  endelse
endif else filt=def_filt
if vv gt 1 then message,'filtering with :'+filt,/info

;	and now decode the filter
lfilt=strlen(filt) < nbyt
ifilt=intarr(nbyt)-1
for i=0,lfilt-1 do begin
  c=strmid(filt,i,1) & if c eq '0' or c eq '1' then ifilt[i]=fix(c)
endfor

;	and now filter SBIT
msok=0L & sok=lindgen(szb[2])
for ic=0,ncol-1 do begin
  tmp=b11001001(reform(sbit[ic,*]),/otto)
  jb=ic*8+indgen(8) & ok=where(ifilt[jb] ge 0,mok)
  if vv gt 1 then kilroy,dot=':'+strmid(filt,ic*8,8)+':'
  if vv gt 10 then print,strtrim(ifilt[jb],2)
  for ib=0,mok-1 do begin
    if vv gt 1 then kilroy
    i=jb[ok[ib]]
    if ifilt[i] ge 0 then o0=where(tmp[7-ok[ib],*] eq ifilt[i],mo0)
    if mo0 gt 0 then begin
      if vv gt 2 then kilroy,dot=strtrim(mo0,2)
      if msok eq 0 then begin
        sok=o0 & msok=mo0
      endif else sok=whither(sok,o0,msok)
      if vv gt 2 then kilroy,dot='('+strtrim(msok,2)+')'
    endif else return,-1L
  endfor
endfor

return,sok
end
