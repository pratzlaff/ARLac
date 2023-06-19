compile_opt idl2, hidden
;!path=!path+':/home/kashyap/Idlib'
!path=!path+':./arlac_xlc:/data/fubar/kashyap/ARLac/fest_2013apr:'+expand_path('+./arlac_xlc/Idlib')

visual=0
root='K'
libdir='/data/fubar/kashyap/ARLac/fest_2013apr/sphrojlib'
libdir='./arlac_xlc/sphrojlib'

nx=1024 & ny = 1024

b2=1.

h1=0.15 & h2=1.7 & b1=0.38
h1=0.10 & h2=1.6 & b1=0.47
h1=0.10 & h2=1.6 & b1=0.50
h1=0.25 & h2=1.7 & b1=0.29

h2 = [ 0.01, 1.30, 2.5 ]
h1 = h2
b1 = [ .44, .44, .44 ]

for i = 0, n_elements(h1)-1 do begin $
&  filename = string( [ h1[i], h2[i], b1[i] ], format='(%"models/%0.2f_%0.2f_%0.2f.rdb")') $
&  print, filename $
&  mk_xray_lc, h1=h1[i], h2=h2[i], b1=b1[i], b2=b2, visual=visual, root=root, libdir=libdir, lc=lc, tgrid=tgrid, nx=nx, ny=ny $
&  openw, lun, filename, /get_lun $
&  printf, lun, h1[i], h2[i], b1[i], b2, format='(%"# h1=%f, h2=%f, b1=%f, b2=%f")' $
&  printf, lun, format='(%"phase\tintensity")' $
&  printf, lun, format='(%"N\tN")' $
&  for j = 0, n_elements(tgrid)-1 do printf, lun, tgrid[j], lc[j], format='(%"%f\t%f")' $
&  free_lun, lun $
& endfor

;; h1 = [ 0.12, 0.15, 0.42 ]
;; h2 = [ 1.67, 1.70, 1.78 ]
;; b1 = [ 0.35, 0.38, 0.44 ]

;; for i = 0, n_elements(h1)-1 do begin $
;; &  for j = 0, n_elements(h2)-1 do begin $
;; &    for k = 0, n_elements(b1)-1 do begin $
;; &      filename = string( [ h1[i], h2[j], b1[k] ], format='(%"models/%0.2f_%0.2f_%0.2f.rdb")') $
;; &      print, filename $
;; &      mk_xray_lc, h1=h1[i], h2=h2[j], b1=b1[k], b2=b2, visual=visual, root=root, libdir=libdir, lc=lc, tgrid=tgrid, nx=ny, ny=ny $
;; &      openw, lun, filename, /get_lun $
;; &      printf, lun, h1[i], h2[j], b1[k], b2, format='(%"# h1=%f, h2=%f, b1=%f, b2=%f")' $
;; &      printf, lun, format='(%"phase\tintensity")' $
;; &      printf, lun, format='(%"N\tN")' $
;; &      for ii = 0, n_elements(tgrid)-1 do printf, lun, tgrid[ii], lc[ii], format='(%"%f\t%f")' $
;; &      free_lun, lun $
;; &    endfor $
;; &  endfor $
;; & endfor

exit
