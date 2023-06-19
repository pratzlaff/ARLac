;!path=!path+':/home/kashyap/Idlib'
!path=!path+':'+expand_path('+./Idlib')

visual=0

b1=0.5 & b2=1.

mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir

exit
