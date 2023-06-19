function xtevtfilt,evt,chans,pcu=pcu,lyrl=lyrl,lyrr=lyrr,chrng=chrng,$
	_extra=e
;+
;function	xtevtfilt
;	filters the events in an XTE event file according to the specified
;	instrument configuration and returns the position indices of the
;	selected events in a longword array.
;
;	WARNING: NO GTI filtering is done!
;
;parameters
;	evt	[INPUT; required] 24bit code describing the instrument
;		configuration, given as a 3xNph byte array
;	chans	[OUTPUT] channel numbers of the selected photons [0-255]
;
;keywords
;	pcu	[INPUT] 5 element array describing whether to include (1)
;		or exclude (0) the given PCU
;		* e.g., [1,1,1,0,0] selects PCU0,PCU1,PCU2
;		* default: [1,1,1,1,1]
;	lyrl	[INPUT] 3 element array describing whether to include (1)
;		or exclude (0) a given LEFT layer of anodes
;		* e.g., [1,0,0] selects L1, [0,0,1] selects L3, etc.
;		* default: [1,1,1]
;	lyrr	[INPUT] as LYRL, but for RIGHT anodes
;		* e.g., [1,0,0] selects R1, [0,0,1] selects R3, etc.
;		* default: [1,1,1]
;	chrng	[INPUT] 2-element array containing minimum and maximum
;		channel numbers to include (channels go from 0..255)
;		* default: [0,255]
;		* if scalar, CHRNG=[0,CHRNG]
;		* if 1-element vector, CHRNG=[CHRNG(0),255]
;
;description
;	the event code is as follows:
;	1: data is good=1; this is the default
;	2-6: S tokens; ignore
;	7: Propane bit; ignore in this version
;	8-10: Detector number (0..5==000,001,010,011,100)
;	11-16: anode element (E) code (L1=1,L2=4,L3=16) & (R1=2,R2=8,R3=32)
;	17-24: channel number
;
;restrictions
;	requires subroutine B11001001
;
;history
;	vinay kashyap (Jul97)
;-

;	usage
sz=size(evt)
ok=''		;assume everything is OK
if sz(0) ne 2 then ok='Input not 2D array' else $
  if sz(1) ne 3 then ok='event length mismatch' else $
    if sz(3) ne 1 then ok='input should be a byte array'
if ok ne '' then begin
  message,ok,/info
  print,'Usage: oo=xtevtfilt(evt,chans,pcu=pcu,lyrl=lyrl,lyrr=lyrr,chrng=chrng)'
  print,'  returns position indices of selected XTE events by filtering on'
  print,'  instrument configuration'
  return,-1L
endif
nevt=sz(2)

;	keywords are fine
;	channels
nch=n_elements(chrng)
if nch eq 0 then chrng=[0,255]
if nch eq 1 then chrng=[0,chrng(0)]
if nch gt 2 then chrng=[min(chrng),max(chrng)]
;	PCUs
npc=n_elements(pcu) & pc=[1,1,1,1,1]
for i=0,npc-1 do pc(i)=pcu(i)
cpc=indgen(5) & oo=where(pc eq 0,moo) & if moo gt 0 then cpc(oo)=255
;	Anodes
nll=n_elements(lyrl) & lrl=[1,1,1] & for i=0,nll-1 do lrl(i)=lyrl(i)
nlr=n_elements(lyrr) & lrr=[1,1,1] & for i=0,nlr-1 do lrr(i)=lyrr(i)
cand=[2^(indgen(3)*2),2^(indgen(3)*2+1)]
oo=where([lrl,lrr] eq 0,moo) & if moo gt 0 then cand(oo)=255
;codanod=lrl(0)+4*lrl(1)+16*lrl(2) + 2*lrr(0)+8*lrr(1)+32*lrr(2)

;	break the event code's 1st 16 bits into positional code
p1=b11001001(reform(evt(0,*)),/otto) & p2=b11001001(reform(evt(1,*)),/otto)

;	which detector?
det=bytarr(nevt) & det(*)=p2(6,*)+2*(p2(7,*))+4*(p1(0,*))

;	which anodes?
anode=bytarr(nevt)
anode(*)=p2(0,*)+2*(p2(1,*))+4*(p2(2,*))+8*(p2(3,*))+16*(p2(4,*))+32*(p2(5,*))

;	which channels?
chans=reform(evt(2,*))

;	select
oo=where((det eq cpc(0) or det eq cpc(1) or det eq cpc(2) or $
   det eq cpc(3) or det eq cpc(4)) and (anode eq cand(0) or $
   anode eq cand(1) or anode eq cand(2) or anode eq cand(3) or $
   anode eq cand(4) or anode eq cand(5)) and (chans ge chrng(0) and $
   chans le chrng(1)),moo)
if moo gt 0 then chans=chans(oo) else chans=-1L

return,oo
end
