;+
;LOCKEY.PRO
;___given the latitude (& longitude, which is unnecessary) computes the
;___observed" N(H) according to the formula given in Dickey & Lockman, 1990,
;___ARAA, 28:
;___ N(H) = (3.84* cosec(|b|) - 2.11) * 1e20 cm ^-2
;-

	ib = 38
	openr,1,'/home0/kashyap/Module/uname'
	var = fltarr(2,ib) & readf,1,var & close,1
	bb = reform(var(0,*)) & ll = reform(var(1,*))

	bb = bb*!pi/180. & nh = 3.84/sin(abs(bb)) - 2.11  & bb = bb*180./!pi
	openw,1,'/home0/kashyap/Module/unameit'
	for i=0,ib-1 do printf,1,bb(i),ll(i),nh(i)*1e20,bb(i),ll(i),' 0.'
	close,1

	end
