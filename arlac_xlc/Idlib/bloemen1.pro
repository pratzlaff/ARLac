;BLOEMEN1.PRO
;--------------------------------------------------------------------------
;---calculates the hydrogen column density to a given distance using the
;---3 component model of Bloemen, J.B.G.M., 1987, ApJ, 322, 694.
;---cold HI: n(z) = 0.3*exp(-0.5*(z/135)^2) cm^-3
;---warm HI: n(z) = 0.07*exp(-0.5*(z/135)^2) + 0.1*exp(-z/400) cm^-3
;--------------------------------------------------------------------------

	print, 'type latitude(degrees) and distance(pc)'
	b = 0. & r = 0. & read,b,r
	print, 'tot. col. density?'
	nhinf = 4e20 & read, nhinf & if nhinf eq 0. then nhinf = 4e20

	if b eq 0. then b = 90.
	if b lt 0. then b = -b
	sinb = sin(!pi*b/180.)
	if r eq 0. then r = 8000./sinb
	alpha = sinb/(135.*sqrt(2.)) & beta = sinb/400.
	alfa2 = sinb/(70.*sqrt(2.))  & bet2 = sinb/128.

	nexp = (0.1/beta)*(1.-exp(-r*beta))
	ngauss = (0.37*sqrt(!pi)/(alpha*2.))*errorf(alpha*r)
	nh2 = (0.3*sqrt(!pi)/(alfa2*2.))*errorf(alfa2*r)
	nh3 = nhinf * (1.-exp(-r*bet2))
	nh = (ngauss + nexp)*3.1e18
	print, 'latitude, N(HI), N(H2)/N(HI), NH(exp)'
	print, b,nh,nh2*3.1e18/nh,nh3

	end
