set_source("faked", xsphabs.abs1 * ( xsapec.kT1+xsapec.kT2+xsapec.kT3+xsapec.kT4) )
abs1.nh=2e-4
kT1.kT=0.122 ; kT2.kT=0.6845 ; kT3.kT=1.93 ; kT4.kT=10.85
kT1.norm=0.1 ; kT2.norm=10. ; kT3.norm=10. ; kT4.norm = 1.
dataspace1d(0.5, 5.0, 0.025, id="faked")
#plot_source("faked")

from sherpa_contrib.utils import *
save_instmap_weights("faked", "./spectrum/spectrum_erg_wide.txt", fluxtype="erg")
save_instmap_weights("faked", "./spectrum/spectrum_ph_wide.txt")

