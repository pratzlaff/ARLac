;+
;mk_psfsize_image.pro
;	given a binned image, computes the size of the PSF at each pixel
;	and writes out an image with an identical header
;
;usage
;	imgfil='/data/cygob2/kashyap/testmosaic/obs10954_ccd3_broad.img'
;	eefrac=0.393	;default in wavdetect
;	energy=1.5
;	.run mk_psfsize_image
;
;vinay k (2010sep20)
;-

;	initialize
if not keyword_set(imgfil) then message,'IMGFIL is not defined'
if size(imgfil,/type) ne 7 then message,'IMGFIL not given as a string'
if n_elements(imgfil) gt 1 then message,'IMGFIL must be a scalar'
outfil=imgfil+'_psfsiz'
if not keyword_set(eefrac) then eefrac=0.393
if not keyword_set(energy) then energy=1.5

;	read in the image
img=mrdfits(imgfil,0,himg)
szi=size(img) & if szi[0] ne 2 then message,imgfil+': IMGFIL does not seem to contain an image?'
nx=szi[1] & ny=szi[2]
;mid-point of pixel #(1,1)
xmin=sxpar(himg,'CRVAL1P')+sxpar(himg,'CRPIX1P') & ymin=sxpar(himg,'CRVAL2P')+sxpar(himg,'CRPIX2P')
xdelt=sxpar(himg,'CDELT1P') & ydelt=sxpar(himg,'CDELT2P')
ii=lindgen(nx) & jj=lindgen(ny) & xx=xmin+ii#(intarr(ny)+1)*xdelt & yy=ymin+(intarr(nx)+1)#jj*ydelt

psfsiz=chandra_psfsize(xx[*],yy[*],eefrac=eefrac[0],energy=energy[0],verbose=10,instrum='ACIS-I')
psfimg=reform(psfsiz,nx,ny)/0.492	;[arcsec]/[arcsec/pix]
mwrfits,psfimg,outfil,/create

end
