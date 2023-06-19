function beta_cf,a,b,x
;+
;function	beta_cf	continued fraction for incomplete beta function,
;			used by BETAI
;			(from Numerical Recipes, Press et al. 1986, p168)
;parameters	a
;		b
;		x
;description
;       I_x(a,b) = {{x^a (1-x)^b} \over {a B(a,b)}}
;		 (1/1+(d_1/1+(d_2/1+...))),
;	where
;	d_{2m} = {{m (b-m) x} \over {(a + 2m - 1) (a + 2m)}, and
;	d_{2m+1} = -{{(a + m) (a + b + m) x} \over {(a + 2m) (a + 2m + 1)}
;-

itmax = 100 & eps = 3.e-7

am = 1. & bm = 1. & az = 1. & qab = a+b & qap = a+1. & qam = a-1.
bz = 1. - qab*x/qap

for m=1,itmax do begin
  em = m & tem = em+em
  d = em*(b-m)*x/((qam+tem)*(a+tem))
  ap = az+d*am & bp = bz+d*bm
  d = -(a+em)*(qab+em)*x/((a+tem)*(qap+tem))
  app = ap+d*az & bpp = bp+d*bz
  aold = az & am = ap/bpp & bm = bp/bpp & az = app/bpp & bz = 1.
  if abs(az-aold) lt eps*abs(az) then return,az
endfor

print, 'A or B too big, or ITMAX too small in BETACF',a,b,itmax,az,aold

return,az
end
