;+
;MK_XRAY_LC.PRO
;
; test pro to see if one can easily compute the light curve of an
; eclipsing system.  Method uses Vinay's ccircle.pro that makes a 
; 512x512 image of a circle.  The idea is then to get the total
; light vs time from the combined images of both stellar disks.
; The orbital period is broken into an arbitrary number of time
; bins (eg 100) and the light curve computed as a function of 
; phase.  Because the total is pixelised, it will have "noise"
; associated with it.
;
; first set up the stellar parameters (since only one period is
; computed there is no need for double precision in the period).
; all length units in solar radii; period in days; angles converted to
; radians; brightnesses b1 & b2 relative to each other.
;
;copied from optic_lc.pro, 1999.apr23.22.00
;and further mangled by VK
;and modified to match the AR Lac system rather than YY Gem (VK; MIM.X)
;and changed to use SPHROJ/PATHPROJ rather than SPHERVOL (VK; MIM.XI)
;-

if not keyword_set(p) then p=1.983222		;Strassmeier (table 4)
if not keyword_set(m1) then m1=1.30		;Strassmeier (table 5)
if not keyword_set(m2) then m2=1.30		;Strassmeier (table 5)
if not keyword_set(r1) then r1=1.80		;Strassmeier (table 5)
if not keyword_set(r2) then r2=3.10		;Strassmeier (table 5)
if not keyword_set(h1) then h1=0.4		;scale height
if not keyword_set(h2) then h2=0.4		;scale height
drad = h1/2. < (h2/2.)				;slice size
if not keyword_set(inc) then inc=87.0*!pi/180.
if not keyword_set(b1) then b1=1.		;fraction of flux from star 1
if not keyword_set(b2) then b2=1.		;fraction of flux from star 2
if not keyword_set(cc) then cc=89.99		;cone angle
if not keyword_set(npt) then npt=25
			; number of points with which to cover each eclipse
if not keyword_set(nx) then nx=512
if not keyword_set(ny) then ny=512
;
if not keyword_set(rfunct) then rfunct='exp'	;type of radial profile
if n_elements(visual) eq 0 then visual=0	;display or not
window,0 & window,2 & wset,0

if not keyword_set(om1) then om1=m1*2
if not keyword_set(om2) then om2=m2*2
if not keyword_set(or1) then or1=r1*2
if not keyword_set(or2) then or2=r2*2
if not keyword_set(oh1) then oh1=h1*2
if not keyword_set(oh2) then oh2=h2*2
if not keyword_set(onx) then onx=nx*2
if not keyword_set(ony) then ony=ny*2
if not keyword_set(ofunct) then ofunct='radial function not defined'

; Kepler's 3rd for semi-diameter of orbit A  cf. Budding et al 1996,
; Astrophys. Space Sci., 236, 215
; JJD thing A is twice as large as it should be

A=(p^2.*(m1+m2)/0.0134)^0.33333
a=a/2.

; radii of orbits for each component a1 & a2

a1=m2*2.*a/m1/(1.+ m2/m1) & a2=m1*2.*a/m2/(1.+ m1/m2)

; work out rough phases of contact by assuming inc=90 deg for making 
; t grid - needs to be fine in region of eclipse - and make grid for
; phases from 0 to 1

;rought=asin((r1+r2)/a)/2./!pi
;trange=rought*1.1
phgrid=0.25*(0.5+findgen(npt))/(npt) 
tgrid=[0.,phgrid,0.5+[reverse(-phgrid),phgrid],1.-reverse(phgrid),1.]
nt=n_elements(tgrid)
lc=fltarr(nt)

; get X-ray "image" by assuming that emissivity is constant/volume
xra=[-(2.*a + r1+r2)*1.2/2.,(2.*a + r1+r2)*1.2/2.] & yra=xra
; the following two are time consuming, so don't repeat unless all
; variables have changed
if or1 ne r1 or oh1 ne h1 or om1 ne m1 or om2 ne m2 or ofunct ne rfunct then $
  img1= sphroj(r1,r1+5*h1,verbose=visual,xrange=xra,yrange=yra,nx=nx,ny=ny,$
	 sclht=h1,rfunct=rfunct,coneang=cc)
  ;sphroj(r1,r1+h1,v=visual,xrange=xra,yrange=yra,nx=nx,ny=ny,rfunct=rfunct)
  ;img1=sphervol(r1,r1+h1,drad=drad,v=visual,xrange=xra,yrange=yra,nx=nx,ny=ny)
if or2 ne r2 or oh2 ne h2 or om1 ne m1 or om2 ne m2 or ofunct ne rfunct then $
  img2= sphroj(r2,r2+5*h2,verbose=visual,xrange=xra,yrange=yra,nx=nx,ny=ny,$
	 sclht=h2,rfunct=rfunct,coneang=cc)
  ;sphroj(r2,r2+h2,v=visual,xrange=xra,yrange=yra,nx=nx,ny=ny,rfunct=rfunct)
  ;img2=sphervol(r2,r2+h2,drad=drad,v=visual,xrange=xra,yrange=yra,nx=nx,ny=ny)
;renormalize
img1=img1*b1/total(img1)
img2=img2*b2/total(img2)
x0=0. & y0=0.
frnt1=ccircle(x0,y0,r1,xra=xra,yra=yra,nx=nx,ny=ny)
frnt2=ccircle(x0,y0,r2,xra=xra,yra=yra,nx=nx,ny=ny)

; positions vs time.  Assume that phase 0 is with component 1 in front
; and moving to the right.  Star in front has -ve y
; loop over time (phase)

dx=(xra(1)-xra(0))/(nx-1.) & dy=(yra(1)-yra(0))/(ny-1.)

for i=0,nt-1 do begin

  t=tgrid[i]

  x1=a1*sin(2.*!pi*t)
  y1=cos(inc+!pi)*a1*cos(2.*!pi*t)
  ix1=(x1-x0)/dx+(nx/2) & iy1=(y1-y0)/dy+(ny/2)

  x2=a2*sin(2.*!pi*t+!pi)
  y2=cos(inc)*a2*cos(2.*!pi*t)
  ix2=(x2-x0)/dx+(nx/2) & iy2=(y2-y0)/dy+(ny/2)

  ; get circle images, first setting up size etc of region; allow axis +
  ; radii of stars + 10% either side for x, same in y; default 512x512

  if y1 lt 0 then begin
    front=b1*shift(img1,nx/2-ix1,ny/2-iy1)
    back=b2*shift(img2,nx/2-ix2,ny/2-iy2)
    ofront=b1*shift(frnt1,nx/2-ix1,ny/2-iy1)
    ;ofront=b1*ccircle(x1,y1,r1,xra=xra,yra=yra,nx=nx,ny=ny)
    ;oback=b2*ccircle(x2,y2,r2,xra=xra,yra=yra,nx=nx,ny=ny)
  endif else begin
    back=b1*shift(img1,nx/2-ix1,ny/2-iy1)
    front=b2*shift(img2,nx/2-ix2,ny/2-iy2)
    ofront=b2*shift(frnt2,nx/2-ix2,ny/2-iy2)
    ;ofront=b2*ccircle(x2,y2,r2,xra=xra,yra=yra,nx=nx,ny=ny)
    ;oback=b1*ccircle(x1,y1,r1,xra=xra,yra=yra,nx=nx,ny=ny)
  endelse 

  ; intersect the two images such that star in front blocks star behind

  i0=where(ofront gt 0)
  back[i0]=0.

  ; compute total light curve 

  lc[i]=total(front+back)/(b1+b2)

  tvscl,2*front+back
  ;print,i,lc(i)

endfor

; normalise to 1 maximum.

lc=lc/max(lc)
wset,2
plot,[tgrid,1.+tgrid],[lc,lc]

; update old values
om1=m1 & om2=m2 & or1=r1 & or2=r2 & oh1=h1 & oh2=h2
onx=nx & ony=ny & ofunct=rfunct

end

