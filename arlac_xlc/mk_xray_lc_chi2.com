!path=!path+':/home/kashyap/Idlib'
!path=!path+':'+expand_path('+./Idlib')

mk_xray_lc_chi2, visual=0, root='K', libdir='sphrojlib'

exit
