function dens2cumul,dens,inout=inout,topdown=topdown,x0=x0,y0=y0,$
	xmode=xmode,ymode=ymode,xmean=xmean,ymean=ymean,$
	xvar=xvar,yvar=yvar,verbose=verbose, _extra=e
;+
;function dens2cumul
;	given a 2D array of probability densities, compute and return a new
;	array that is the integrated probability from some point outwards
;
;parameters
;	dens	[INPUT; required] 2D array of the probability densities
;
;keywords
;	inout	[INPUT; default] if set, integrates out starting from (X0,Y0),
;		and expands monotonically outwards, all nearest neighbors at a
;		time
;	topdown	[INPUT] if set, accumulates the densities by level, ignoring
;		non-connectivity
;		* overrides INOUT
;	x0	[INPUT] if given, starts INOUT from this x-index, rather than
;		the mode's
;	y0	[INPUT] if given, starts INOUT from this y-index, rather than
;		the mode's
;		* X0 and Y0 are ignored if TOPDOWN is set
;	xmode	[OUTPUT] x-location of the mode
;	ymode	[OUTPUT] y-location of the mode
;	xmean	[OUTPUT] mean of pdf along x-axis, marginalized over y
;	ymean	[OUTPUT] mean of pdf along y-axis, marginalized over x
;	xvar	[OUTPUT] variance along x-axis, for pdf marginalized over y
;	yvar	[OUTPUT] variance along y-axis, for pdf marginalized over x
;	verbose	[INPUT] controls chatter
;	_extra	[JUNK] here only to prevent crashing the program
;
;history
;	vinay kashyap (MarMMVI)
;-

;	usage
ok='ok' & np=n_params() & nd=n_elements(dens) & szd=size(dens)
if np eq 0 then ok='Insufficient parameters' else $
 if nd eq 0 then ok='DENS: not defined' else $
  if szd[0] ne 2 then ok='DENS: must be 2-D array'
if ok ne 'ok' then begin
  print,'Usage: cumul=dens2cumul(dens,/inout,/topdown,x0=x0,y0=y0,$'
  print,'       xmode=xmode,ymode=ymode,xmean=xmean,ymean=ymean,$'
  print,'       xvar=xvar,yvar=yvar,verbose=verbose)'
  print,'  compute and return the cumulative probability from a given'
  print,'  probability density function'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	define output
cumul=0*dens

;	keywords

;verbosity
vv=0L & if keyword_set(verbose) then vv=long(verbose[0])>1

;X0,Y0
dmax=max(dens,imax) & nx=szd[1] & ny=szd[2]
xmode=imax mod nx
ymode=imax/nx
i0=xmode & if n_elements(x0) ne 0 then if x0[0] ge 0 and x0[0] lt nx then i0=x0[0]
j0=ymode & if n_elements(y0) ne 0 then if y0[0] ge 0 and y0[0] lt ny then j0=y0[0]

;	now make a bitmap of the same size as the density function
idens=make_array(nx,ny,/byte)

;	TOPDOWN
if keyword_set(topdown) then begin
  os=reverse(sort(dens))
  cdens=total(dens[os],/cumul)
  cumul[os]=cdens
  return,cumul
endif

;	INOUT
go_on=1 & k=0L & npix=nx*ny & mo0=npix
while go_on do begin		;{integrate 

  if keyword_set(topdown) then begin
    idens[os[k]]=1
    cumul[os[k]]=total(idens*dens)
    if k eq 500L*long(k/500L) and vv gt 10 then contour,cumul,level=[0.1,0.5,0.9]*max(cumul)
  endif else begin
    if vv gt 0 then kilroy,dot=strtrim(k,2)+'..'
    if k eq 0 then begin
      idens[i0,j0]=1
      cumul[i0,j0]=dens[i0,j0]
    endif
    o1=where(idens ne 0,mo1)
    jx=o1 mod nx
    jy=o1/nx
    ;
    idens2=idens
    idens2[jx+1,jy+0]=1
    idens2[jx+0,jy+1]=1
    idens2[jx-1,jy-0]=1
    idens2[jx-0,jy-1]=1
    oi=where(idens2-idens gt 0,moi)
    if moi gt 0 then cumul[oi]=total(dens*idens2)
    if vv gt 50 then contour,cumul,level=[0.1,0.5,0.9]*max(cumul)
    ;
    idens3=idens2
    ;idens3[jx+1,jy+1]=1
    ;idens3[jx-1,jy+1]=1
    ;idens3[jx-1,jy-1]=1
    ;idens3[jx+1,jy-1]=1
    ;oi=where(idens3-idens2 gt 0,moi)
    ;if moi gt 0 then cumul[oi]=total(dens*idens3)
    if vv gt 10 then contour,cumul,level=[0.1,0.5,0.9]*max(cumul)
    if vv gt 0 then wait,(vv/10. < 0.1)
    if vv gt 1000 then stop,'HALTing.  type .CON to continue'
    ;
    idens=idens3
  endelse

  k=k+1L
  if keyword_set(topdown) then begin
    mo0=npix-k > 0
  endif else o0=where(idens eq 0,mo0)
  if mo0 eq 0 then go_on=0
endwhile			;GO_ON}

return,cumul
end
