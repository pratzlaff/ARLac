compile_opt idl2, hidden
;!path=!path+':/home/kashyap/Idlib'
!path=!path+':./arlac_xlc:/data/fubar/kashyap/ARLac/fest_2013apr:'+expand_path('+./arlac_xlc/Idlib')

root='K'
libdir='/data/fubar/kashyap/ARLac/fest_2013apr/sphrojlib'
libdir='./arlac_xlc/sphrojlib'

window,xsize=1024,ysize=1024 & device,decomposed=0 & loadct,3

h2 = 1.3
h1 = h2
b2=1.
b1 = 0.44

nx=1024 & ny = 1024

visual=5

; hit Ctrl-C once phase gets to about 0.92, then set visual=101 and
; use .CON to get to the image wanted, take a screenshot with gimp

mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir, lc=lc, tgrid=tgrid, nx=nx, ny=ny
