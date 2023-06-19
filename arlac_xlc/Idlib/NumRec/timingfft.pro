so='/home6/kashyap/Idlib/NumRec/sginr.so' & e_pt = 'sgimain'

;so='/home6/kashyap/Idlib/NumRec/sunnr.so' & e_pt = 'sunmain'
;set_plot,'x'
;device,ret=2,pseudo_color=8,/install

sig=[4,16] & ndim = 2 & nn = [512,256] & isign = 1
iarg = long([ndim,isign,nn])
darg = [0.D]
farg = shift(mexhat(ndim,nbin=nn,sig=sig),nn(0)/2,nn(1)/2)
h1 = where(abs(farg) lt 1e-8) & farg(h1)=0.

mh = farg & farg = complex(mh) & nr_name = 'spfourn'
spawn,'date',/noshell
i=call_external(so,e_pt,nr_name,iarg,farg,darg)
spawn,'date',/noshell

fmh1 = farg & farg=complex(mh) & nr_name='fourn'
spawn,'date',/noshell
i=call_external(so,e_pt,nr_name,iarg,farg,darg)
spawn,'date',/noshell & fmh2 = farg

end
