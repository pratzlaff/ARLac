;+
;obsid_overlap.pro
;	figure out all the ObsID/CCD_ID combos that overlap all the
;	ObsID/CCD_IDs in the CygOB2 dataset
;
;vinay kashyap (Aug2010)
;-

message,'this does not work unless coordinates are in RA,Dec'

peasecolr & loadct,3 & peasecolr

;	first, get the complete list of all CygOB2 ObsIDs
arcdir='/data/cygob2/data/archive/'
spawn,'ls -d '+arcdir+'obs*',obs & nobs=n_elements(obs)
sobsid=strarr(nobs) & for i=0,nobs-1 do sobsid[i]=strmid(obs[i],strlen(arcdir)+3,10) & obsid=long(sobsid)

;	step through the obsids and read in the fov files
if n_tags(fovstr) ne nobs then begin
  for i=0L,nobs-1L do begin
    if i eq 0 then fovstr=0
    ;	find the fov file
    fovfil=findfile(arcdir+'obs'+sobsid[i]+'/*fov1*',count=nfov)
    if nfov eq 0 then message,'fov1 file not found for ObsID '+sobsid[i]
    if nfov gt 1 then message,'too many fov1 files found for ObsID '+sobsid[i]
    fov=mrdfits(fovfil[0],1,hfov)
    ;	extract the relevant info
    ccd_id=fov.ccd_id & nccd=n_elements(ccd_id) & xx=fov.X & yy=fov.Y
    ;	store in structure
    tmp=create_struct('CCD_ID',ccd_id,'X',xx,'Y',yy)
    if n_tags(fovstr) eq 0 then $
     fovstr=create_struct('obs'+sobsid[i],tmp) else $
     fovstr=create_struct(fovstr,'obs'+sobsid[i],tmp)
  endfor
endif

;	step through each ObsID/CCD_ID combo and find all overlapping ObsID/CCDs
olap_obsccd=''
for i=0L,nobs-1L do begin 	;{for each ObsID
  tmp=fovstr.(i) & ccd_id=tmp.CCD_ID & xx=tmp.X & yy=tmp.Y
  for j=0L,nccd-1L do begin 	;{for each CCD_ID
    ;	find the bounding box for CCD_ID=j
    xxj=xx[*,j] & yyj=yy[*,j] & plot,xxj,yyj,title=sobsid[i]+'['+strtrim(ccd_id[j],2)+']'
    xmin=min(xxj,max=xmax) & ymin=min(yyj,max=ymax)
    if not keyword_set(olap_obsccd) then begin
      olap_obsccd=[sobsid[i]+'[ccd_id='+strtrim(ccd_id[j],2)+'] :: '] & ii=0L
    endif else begin
      olap_obsccd=[olap_obsccd,sobsid[i]+'[ccd_id='+strtrim(ccd_id[j],2)+'] :: '] & ii=ii+1L
    endelse
    ;	now step through all others and find the overlaps
    for k=0L,nobs-1L do begin	;{compare with all ObsIDs
      ztmp=fovstr.(k) & zccd=ztmp.CCD_ID & zx=ztmp.X & zy=ztmp.Y
      for l=0L,nccd-1L do begin	;{compare with all CCD_IDs
        zxl=zx[*,l] & zyl=zy[*,l] & zxl0=mean(zxl) & zyl0=mean(zyl)
	zxl=[zxl,zxl0] & zyl=[zyl,zyl0]
	oo=where(zxl gt xmin and zyl lt xmax and zyl gt ymin and zyl lt ymax,moo)
	if k eq i then moo=0
	if moo ne 0 then olap_obsccd[ii]=olap_obsccd[ii]+' '+sobsid[k]+'[ccd_id='+strtrim(zccd[l],2)+']'
	if moo ne 0 then oplot,zxl,zyl,col=2
      endfor			;L=0,NCCD-1}
    endfor			;K=0,NOBS-1}
    stop
  endfor			;J=0,NCCD-1}
endfor				;I=0,NOBS-1}

end
