pro mk_xray_lc_chi2, visual=visual, root=root, libdir=libdir

openw, lun, 'xray_lc_1.bin', /get_lun

h1_lo = 0.9
h1_hi = 1.5
h1_inc = 0.05

b1_lo = .1
b1_hi = .6
b1_inc = 0.1
b2=1.

    for b1=b1_lo, b1_hi, b1_inc do begin
for h1=h1_lo, h1_hi, h1_inc do begin
    h2=h1
        print, format='(%"b1=%f, b2=%f, h1=%f, h2=%f")', b1, b2, h1, h2
        mk_xray_lc, b1=b1, b2=b2, h1=h1, h2=h2, visual=visual, lc=lc, tgrid=tgrid, root=root, libdir=libdir
        writeu, lun, n_elements(lc), h1, b1, tgrid, lc
    endfor

endfor

close, lun

end
