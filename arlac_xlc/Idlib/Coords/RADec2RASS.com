;+
;RADec2RASS.com
;	how to go from a specified RA,Dec to a pixel value in a RASS map
;
;vinay k (31May2007)
;-

;	what is the RA and what is the DEC?
if n_elements(RA) ne 1 then message,'RA is undefined'
if n_elements(Dec) ne 1 then message,'Dec is undefined'
if size(RA,/type) eq 7 then message,'RA must be in [deg]'
if size(Dec,/type) eq 7 then message,'Dec must be in [deg]'

;	first, convert the (RA,Dec) to (l2,b2)
if not keyword_set(equinox) then equinox=2000.0
glactc,RA,Dec,equinox,l2,b2,1,/degree

;	find the nearest RASS map
;	see ftp://legacy.gsfc.nasa.gov/rosat/data/pspc/images/sxrb_maps/xray_highres_maps/
ll=[0,0,0,90,180,270] & bb=[-90,0,90,0,0,0]
sep=deltang(ll,bb,l2,b2,/deg) & jnk=min(sep,imn) & llmin=ll[imn] & bbmin=bb[imn]
if bb lt 0 then sgn='m' else sgn='p'
filroot='g'+string(llmin,'(i3.3)')+sgn+string(abs(bbmin),'(i2.2)')

;	read in all the maps
if n_tags(r27) eq 0 then begin & $
  for i=0L,n_elements(ll)-1L do begin & $
    if bb[i] lt 0 then sgn='m' else sgn='p' & $
    rassfil='g'+string(ll[i],'(i3.3)')+sgn+string(abs(bb[i]),'(i2.2)') & $
    if n_tags(r1) eq 0 then r1=create_struct(rassfil,readfits(rassfil+'r1.fits',hdr)) else $
	r1=create_struct(r1,rassfil,readfits(rassfil+'r1.fits',hdr)) & $
    if n_tags(r2) eq 0 then r2=create_struct(rassfil,readfits(rassfil+'r2.fits',hdr)) else $
	r2=create_struct(r2,rassfil,readfits(rassfil+'r2.fits',hdr)) & $
    if n_tags(r3) eq 0 then r3=create_struct(rassfil,readfits(rassfil+'r3.fits',hdr)) else $
	r3=create_struct(r3,rassfil,readfits(rassfil+'r3.fits',hdr)) & $
    if n_tags(r4) eq 0 then r4=create_struct(rassfil,readfits(rassfil+'r4.fits',hdr)) else $
	r4=create_struct(r4,rassfil,readfits(rassfil+'r4.fits',hdr)) & $
    if n_tags(r5) eq 0 then r5=create_struct(rassfil,readfits(rassfil+'r5.fits',hdr)) else $
	r5=create_struct(r5,rassfil,readfits(rassfil+'r5.fits',hdr)) & $
    if n_tags(r6) eq 0 then r6=create_struct(rassfil,readfits(rassfil+'r6.fits',hdr)) else $
	r6=create_struct(r6,rassfil,readfits(rassfil+'r6.fits',hdr)) & $
    if n_tags(r7) eq 0 then r7=create_struct(rassfil,readfits(rassfil+'r7.fits',hdr)) else $
	r7=create_struct(r7,rassfil,readfits(rassfil+'r7.fits',hdr)) & $
    if n_tags(r27) eq 0 then r27=create_struct(rassfil,r2.(i)+r3.(i)+r4.(i)+r5.(i)+r6.(i)+r7.(i)) else $
	r27=create_struct(r27,rassfil,r2.(i)+r3.(i)+r4.(i)+r5.(i)+r6.(i)+r7.(i)) & $
  endfor & $
endif

;	read in one of the maps, say r1, to get the header
rassimg=readfits(filroot+'r1.fits',hrass)
ctype=[sxpar(hrass,'CTYPE1'),sxpar(hrass,'CTYPE2')]
crval=[sxpar(hrass,'CRVAL1'),sxpar(hrass,'CRVAL2')]
cdelt=[sxpar(hrass,'CDELT1'),sxpar(hrass,'CDELT2')]
crxy=[sxpar(hrass,'CRPIX1'),sxpar(hrass,'CRPIX2')]*cdelt
szr=size(rassimg) & nx=szr[1] & ny=szr[2]

;	convert (l2,b2) to image (x,y)
wcssph2xy,l2,b2,xx,yy,ctype=ctype,crval=crval,crxy=crxy
ix=nx+xx/cdelt[0] & iy=ny+yy/cdelt[1]

;	read out the value from the maps
rassrt=(r27.(imn))[ix,iy]
