function xy2img,x,y,ox=ox,oy=oy,minx=minx,miny=miny,maxx=maxx,maxy=maxy,$
	nbinx=nbinx,nbiny=nbiny,binx=binx,biny=biny,$
	rotat=rotat,cenx=cenx,ceny=ceny, _extra=e
;+
;function	xy2img
;	bins arrays into 2D images.  essentially a wrapper to HIST2D.
;
;syntax
;	img=xy2img(x,y,ox=ox,oy=oy,minx=minx,miny=miny,maxx=maxx,maxy=maxy,$
;		nbinx=nbinx,nbiny=nbiny,binx=binx,biny=biny,$
;		rotat=rotat,cenx=cenx,ceny=ceny)
;
;parameters
;	x	[INPUT; required] array for X positions
;	y	[INPUT; required] array for Y positions
;
;keywords
;	ox	[OUTPUT] output grid mid-values along X
;	oy	[OUTPUT] output grid mid-values along Y
;	minx	[INPUT] minimum value to use -- default is min(X)
;	miny	[INPUT] minimum value to use -- default is min(Y)
;	maxx	[INPUT] maximum value to consider -- default is max(X)
;	maxy	[INPUT] maximum value to consider -- default is max(Y)
;	nbinx	[INPUT] number of bins along X -- default is 512L
;	nbiny	[INPUT] number of bins along Y -- default is NBINX
;	binx	[INPUT] bin size along X -- no default, overrides NBINX
;	biny	[INPUT] bin size along Y -- no default, overrides NBINY
;	rotat	[INPUT] if non-zero, rotate the arrays first by ROTAT degrees
;	cenx	[INPUT] center of rotation -- default is 0
;	ceny	[INPUT] center of rotation -- default is 0
;
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap
;-

;	usage
ok='ok' & np=n_params() & nx=n_elements(x) & ny=n_elements(y)
if np lt 2 then ok='Insufficient parameters' else $
 if nx eq 0 then ok='X array undefined' else $
  if ny eq 0 then ok='Y array undefined'
if ok ne 'ok' then begin
  print,'Usage: img=xy2img(x,y,ox=ox,oy=oy,minx=minx,miny=miny,$'
  print,'       maxx=maxx,maxy=maxy,nbinx=nbinx,nbiny=nbiny,$'
  print,'       binx=binx,biny=biny,rotat=rotat,cenx=cenx,ceny=ceny)'
  print,'  bin arrays into 2D images'
  if np ne 0 then message,ok,/info
  return,-1L
endif

;	first rotate (X,Y) if necessary
if keyword_set(rotat) then begin
  if n_elements(cenx) eq 0 then cenx=0.
  if n_elements(ceny) eq 0 then ceny=0.
  xx=(x-cenx[0])*cos(!dtor*rotat[0])+(y-ceny[0])*sin(!dtor*rotat[0])
  yy=-(x-cenx[0])*sin(!dtor*rotat[0])+(y-ceny[0])*cos(!dtor*rotat[0])
  if n_elements(minx) eq 0 then minx=min(xx)
  if n_elements(miny) eq 0 then miny=min(yy)
  if n_elements(maxx) eq 0 then maxx=max(xx)
  if n_elements(maxy) eq 0 then maxy=max(yy)
endif

;	figure out keywords
if n_elements(minx) eq 0 then minx=min(x)
if n_elements(miny) eq 0 then miny=min(y)
if n_elements(maxx) eq 0 then maxx=max(x)
if n_elements(maxy) eq 0 then maxy=max(y)
if maxx lt minx then begin
  message,'ERROR! max(X) < min(X)??  Returning',/info & return,-1L
endif
if maxy lt miny then begin
  message,'ERROR! max(Y) < min(Y)??  Returning',/info & return,-1L
endif
if minx eq maxx then begin
  message,'min(X) = max(X)?  forcing max to min+1',/info & maxx=minx+1
endif
if miny eq maxy then begin
  message,'min(Y) = max(Y)?  forcing max to min+1',/info & maxy=miny+1
endif
if not keyword_set(nbinx) then nbinx=512L
if not keyword_set(nbiny) then nbiny=nbinx
if keyword_set(binx) then nbinx=long((maxx-minx)/double(binx)+0.5) else $
  binx=(maxx-minx)/float(nbinx)
if keyword_set(biny) then nbiny=long((maxy-miny)/double(biny)+0.5) else $
  biny=(maxy-miny)/float(nbiny)

;	call HIST2D
if keyword_set(rotat) then $
  img=hist_2d([xx[*]],[yy[*]],bin1=binx,bin2=biny,max1=maxx,max2=maxy,min1=minx,min2=miny) else $
  img=hist_2d([x[*]],[y[*]],bin1=binx,bin2=biny,max1=maxx,max2=maxy,min1=minx,min2=miny)

;	the other output
ox=findgen(nbinx+1L)*binx+minx & oy=findgen(nbiny+1L)*biny+miny

return,img
end
