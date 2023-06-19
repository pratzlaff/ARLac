;+
;FIT_GRIDPAR
;	fit the model light-curves to data
;
;vinay kashyap (Jun2001)
;-

;	read in model light curves
if n_elements(all_lc) eq 0 then restore,'eclipse_gridpar.save',/ver

;	read in data
if not keyword_set(lcfil) then lcfil=$
	'/home/rpete/rpete7/flight/ARLac/final/lc_timebin=100.rdb'
if n_tags(lc) eq 0 then lc=rdb(lcfil)

;	choose phase range of data to fit models to
op=where(lc.phase le 0.1 or lc.phase ge 0.8)
op=where(lc.phase le 0.25 or lc.phase ge 0.75)
op=where(lc.phase le 0.15 or (lc.phase gt 0.4 and lc.phase lt 0.5) or lc.phase ge 0.75)
op=where(lc.phase le 0.28 or (lc.phase gt 0.36 and lc.phase lt 0.5) or lc.phase ge 0.72)
phasdat=(lc.phase)[op] & ratedat=(lc.rate)[op] & rterrdat=(lc.rate_err)[op]

;	step through the grid of parameters and get chisqs
chisq=fltarr(ng1,ng2,ng3) & modnorm=chisq+5.
phsmod=tgrid+0.5 & oo=where(phsmod gt 1) & phsmod[oo]=phsmod[oo]-1.
os=sort(phsmod) & phsmod=phsmod[os]
best_h1=0. & best_h2=0. & best_b21=0. & minchi=1e10
best_i=-1L & best_j=-1L & best_k=-1L
for i=0L,ng1-1L do begin		;{h1
  for j=0L,ng2-1L do begin		;{h2
    ;plot,lc.phase,lc.rate,psym=4
    print,i,j
    for k=0L,ng3-1L do begin		;{b1/b2
      
      lcmod=all_lc[os,i,j,k]

      ;	interpolate the model to suit the data
      lcmodr=interpol(lcmod,phsmod,phasdat)

      ;	compute chisq by renormalizing the model
      norm=renormod(ratedat,lcmodr,rterrdat,/uchisq,statval=s)
      chisq[i,j,k]=s
      modnorm[i,j,k]=norm
      if s lt minchi then begin
	best_h1=grid_h1[i] & best_h2=grid_h2[j] & best_b21=grid_b21[k]
	best_i=i & best_j=j & best_k=k
	minchi=s
	print,i,j,k,minchi,best_h1,best_h2,best_b21
      endif
      ;chisq[i,j,k]=total((modnorm*lcmodr-ratedat)^2/rterrdat^2)

      ;	report
      ;kilroy,dot=strtrim(chisq[i,j,k],2)+'['+strtrim(i,2)+','+$
      ;	strtrim(j,2)+','+strtrim(k,2)+'] '
      ;oo=sort(phasdat)
      ;oplot,phasdat[oo],norm*lcmodr[oo],col=200

    endfor				;k=0,ng3-1}
  endfor				;j=0,ng2-1}
endfor					;i=0,ng1-1}

save,file='fit_gridpar.save',all_lc,tgrid,ng1,ng2,ng3,$
	grid_h1,grid_h2,grid_b21,lc,op,phasdat,ratedat,rterrdat,$
	chisq,modnorm,phsmod,os,$
	best_h1,best_h2,best_b21,minchi,best_i,best_j,best_k

oo=sort(phasdat)
lcmod=all_lc[os,best_i,best_j,best_k]
lcmodr=interpol(lcmod,phsmod,phasdat)
plot,lc.phase,lc.rate,psym=4
oplot,phasdat[oo],modnorm[best_i,best_j,best_k]*lcmodr[oo],col=200,psym=-1

print,'H1=',best_h1
print,'H2=',best_h2
print,'B2/B1=',best_b21
print,'min Chisq=',minchi
print,'model norm=',modnorm[best_i,best_j,best_k]
print,'i,j,k:',best_i,best_j,best_k

end
