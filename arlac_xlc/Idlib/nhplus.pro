pro nhplus,t,frac
;+
;procedure	nhplus	procedure to obtain the number of ionized H using
;			the Saha equation
;parameters	t	temperature of gas in local thermodynamic equilibrium
;		frac	ratio of n_H+ to n_H, calculated for various n_e
;-

me=9.109534e-28 & h=6.626176e-27 & kb=1.380662e-16 & e=4.8e-10 & mp=1.66056e-24

mred = me/(1+(me/mp))
ryd = alog(2*!pi^2)+alog(mred)+4*alog(e)-2*alog(h) & ryd = exp(ryd)

cI = 1.5*(2*alog(h)-alog(2*!pi)-alog(me)-alog(kb)-alog(t))

zi = findgen(1000)+1 & rydi = (1.-1./zi^2)*ryd
zhi = alog(2)+2.*alog(zi)-rydi/(kb*t) & zhi = exp(zhi) & zh = total(zhi)

frac = 1.5*alog(t)-ryd/(kb*t)-cI-alog(zh) & frac = exp(frac)

return
end
