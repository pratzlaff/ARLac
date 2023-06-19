;!path=!path+':/home/kashyap/Idlib'
!path=!path+':'+expand_path('+./Idlib')

visual=1
root='K'
libdir='./sphrojlib'

b2=1.

; following are all good fits

h1=1.4 & h2=h1
b1=0.1
mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir

h1=1.3 & h2=h1
b1=0.35
mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir

h1=1.2 & h2=h1
b1=0.4
mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir

; a bit of secondary eclipse

h1=0.6 & h2=1.2
b1=0.5
mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir

h1=1.15 & h2=h1
b1=0.55
mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir

; too much secondary eclipse

h1=0.4 & h2=h1
b1=1.0
mk_xray_lc, h1=h1, h2=h2, b1=b1, b2=b2, visual=visual, root=root, libdir=libdir


; with h1,h2 > 1.5 the primary is not deep enough


;exit
