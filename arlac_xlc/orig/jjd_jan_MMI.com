;+
;JJD_JAN_MMI.COM
;
;Jeremy wanted plots of the AR Lac eclipsing coronae model light
;curves, superposed on the HRC-I data
;-

;	latest HRC-I data are in Pete's directory
if not keyword_set(petedir) then petedir='~rpete/rpete7/flight/ARLac/'

;	and the data are in RDB files  -- uncomment ONE
;lcfile='lc_timebin=100_new'
;lcfile='lc_timebin=100'
;lcfile='lc_timebin=400'
if not keyword_set(lcfile) then lcfile='lc_timebin=400'

;	read that in
if n_tags(lc) eq 0 then lc=rdb(lcfile,rdbdir=petedir)

lcdatmin=min(lc.rate)	;everything will get tied to this

;	and now restore the model light curves
restore,'/data/fubar/kashyap/ARLac/arlac_xlc.sav',/ver

;	environment
drakopy,'original'
set_plot,'ps' & device,file='/data/fubar/kashyap/ARLac/jjd_jan_MMI.ps',/color

;	plot it, from 0 to 1.5
plot,[0],/nodata,xrange=[0.,1.5],yrange=[0.,10],xtitle='Phase',$
	ytitle='Rate [ct s!u-1!n]',title='AR Lac: HRC-I',color=1,$
	charthick=1.7,charsize=2.
oplot,[lc.phase,1+lc.phase],[lc.rate,lc.rate],psym=6,color=2,$
	symsize=1.7,thick=1.7
for i=0L,n_elements(lc.rate)-1L do oplot,(lc.phase)[i]*[1,1],$
	(lc.rate)[i]+(lc.rate_err)[i]*[-1,1],color=3,thick=2
for i=0L,n_elements(lc.rate)-1L do oplot,1+(lc.phase)[i]*[1,1],$
	(lc.rate)[i]+(lc.rate_err)[i]*[-1,1],color=3,thick=2

lcmodmin=min(lc_01) & lc_01=lc_01*lcdatmin/lcmodmin
oplot,-0.5+[tgrid_01,1+tgrid_01],[lc_01,lc_01],color=4,thick=2
oplot,[0.1,0.4],1.05*lcdatmin*[1,1],color=4,thick=2
xyouts,0.4,1.0*lcdatmin,' h=0.1 R!dsun!n',color=4,charsize=2

lcmodmin=min(lc_10) & lc_10=lc_10*lcdatmin/lcmodmin
oplot,-0.5+[tgrid_10,1+tgrid_10],[lc_10,lc_10],color=5,thick=2
oplot,[0.1,0.4],0.85*lcdatmin*[1,1],color=5,thick=2
xyouts,0.4,0.8*lcdatmin,' h=1.0 R!dsun!n',color=5,charsize=2

lcmodmin=min(lc_20) & lc_20=lc_20*lcdatmin/lcmodmin
oplot,-0.5+[tgrid_20,1+tgrid_20],[lc_20,lc_20],color=6,thick=2
oplot,[0.1,0.4],0.65*lcdatmin*[1,1],color=6,thick=2
xyouts,0.4,0.6*lcdatmin,' h=2.0 R!dsun!n',color=6,charsize=2

lcmodmin=min(lc_40) & lc_40=lc_40*lcdatmin/lcmodmin
oplot,-0.5+[tgrid_40,1+tgrid_40],[lc_40,lc_40],color=7,thick=2
oplot,[0.1,0.4],0.45*lcdatmin*[1,1],color=7,thick=2
xyouts,0.4,0.4*lcdatmin,' h=10. R!dsun!n',color=7,charsize=2

;	colors
setcolor,'DarkGreen',1
setcolor,'red',2
setcolor,'yellow',3
setcolor,'pink',4
setcolor,'orange',5
setcolor,'aquamarine',6
setcolor,'magenta',7

device,/close & set_plot,'x'
