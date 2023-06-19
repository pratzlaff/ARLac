; look at the different X-ray measurements of AR Lac over 
; time.
; Use pimms to convert count rates to fluxes in X-ray band
; adopt the 0.5-5kev band using a coronal T of 1 keV

; Einstein IPC 1980 june 14 1.8 ct/s +/- 0.2  3.4e-11
; EXOSAT LE 1984 july 4 0.2 ct/s +/- 0.02  
; EXOSAT ME 0.6 ct/s   2.6e-11
; ROSAT PSPC 1990.75 7.72+/- 0.1   5.0e-11
; ASCA SIS 1993 june 2  1.2 +/- 0.15   4.4-11
; HETG 2000, sept 16 7.9 e30 erg/s 3.7 e-11 --> 3.5e-11
; 1 ct/s summed heg+meg 1.7-25 AA

instmt=['Einstein IPC','EXOSAT LE','ROSAT PSPC','ASCA SIS','Chandra HETG',$
  'Chandra HRC-I','Chandra HRC-S']

year=[1980.452,1984.506,1990.75,1993.419,2000.71]
ctr=[1.8,0.6,7.72,1.2,1.0]
ctre=[0.2,0.1,0.1,0.15,0.2]
flx=[3.4e-11,2.6e-11,5.0e-11,4.4e-11,3.7e-11]
flxe=flx*ctre/ctr

set_plot,'ps'
device,/color,file='xrayvstime.ps'
drakopy,'jeremy'

setkolor,'navyblue',50
setkolor,'forestgreen',70
setkolor,'orange',90
setkolor,'red',110
setkolor,'purple',130
setkolor,'brown',150

kols=[50,70,90,110,130,150]

xra=[1979,2010]
yra=[0.,1.e-10]
xtit='Year'
ytit='Flux [erg cm!u-2!n s!u-1!n]'

plot,year,flx,xra=xra,yra=yra,xtit=xtit,ytit=ytit,/nodata,/xsty

for i=0,n_elements(ctr)-1 do begin
  poaintsym,'square',psize=1.3,col=kols[i],/fill
  plots,year[i],flx[i],psym=8
endfor

hrci2erg=6.6e-12  ; erg per count

readcol,'lc_bin=400.rdb',hjd,phase,time,time_bin,rate,rate_err,flux,$
  flux_err,src,bg,area_ratio,bg_corr,dtf,dtf_err,obsid,theta,phi,vignette
caldat,hjd,monthi,dayi,yeari
year=yeari+monthi/12.+dayi/365.

oo=where(phase gt 0.2 and phase lt 0.8)
oplot,year[oo],rate[oo]*hrci2erg,psym=1,col=kols[0]

readcol,'lc_hrcs_bin=400.rdb',hjd,phase,time,time_bin,rate,rate_err,flux,$
  flux_err,src,bg,area_ratio,bg_corr,dtf,dtf_err,obsid,theta,phi,vignette
caldat,hjd,months,days,years
year=yeari+monthi/12.+dayi/365.

oplot,year[oo],rate[oo]*hrci2erg,psym=1,col=kols[3]

device,/close
set_plot,'x'

end
