function gammln,xx
;+
;function	gammln
;		returns the value ln(\Gamma(xx)) for xx > 0.  full accuracy
;		is obtained for xx > 1.  for 0 < xx < 1, the reflection
;		formula, \Gamma(1-z) = {{\pi z} \over {\Gamma(1+z)
;		sin(\pi z)} can be used first.
;
;parameters	xx
;
;description
;	\Gamma(x) = \int{0}{\infty} t^{z-1} e^{-t} dt
;-

cof = [ 76.18009173d0, -86.50532033d0, 24.01409822d0, -1.231739516d0,$
	.120858003d-2, -.536382d-5 ]
stp = 2.50662827465d0 & half = 0.5d0 & one = 1.0d0 & fpf = 5.5d0
iflag = 0
if xx eq 0. then stop, 'xx=0 in GAMMLN'

x = xx-one & tmp = x+fpf & tmp = (x+half)*alog(tmp)-tmp & ser = one
for j=0,6-1 do begin
  x = x+one & ser = ser+cof(j)/x
endfor
val = tmp+alog(stp*ser)

return,val
end
