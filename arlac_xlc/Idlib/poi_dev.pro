function poi_dev,x,n,seed
;+
;function	poi_dev
;		generate poisson deviates for a given average x
;
;parameters	x	average from which to generate the deviates
;		n	number of deviates to generate {default=1}
;		seed	seed for random number generation
;
;keywords	NONE
;
;description
;	modified from the Numerical Recipes fortran progam of the same name
;
;history
;	* vinay kashyap (ASC/UC; Oct 95)
;	* changed name from POIDEV to POI_DEV to avoid conflict with
;	  IDLASTRO implementation (VK; Dec96)
;-

np=n_params(0)
if np eq 0 then begin
  print,'Usage: p=poi_dev(x,n,seed)'
  print,'  generate n poisson deviates for a given average x'
  return,-1L
endif
if np eq 1 then n=1
if x lt 0 then begin
  print,'sorry, cannot handle x<0' & return,-1L
endif

;initialize
p=findgen(n)

if x lt 12. then begin
  ip=intarr(n) & xp=where(ip eq 0) & t=randomu(seed,n)
  g=exp(-x) & em=fltarr(n)
  while xp(0) ne -1 do begin
    hp=where(ip eq 0 and t gt g) & if hp(0) ne -1 then em(hp)=em(hp)+1.
    h1=where(t le g) & if h1(0) ne -1 then ip(h1)=1
    t=t*randomu(seed,n) & xp=where(ip eq 0)
  endwhile
endif else begin
  ip1=intarr(n) & ip2=ip1 & xp1=where(ip1 eq 0) & xp2=where(ip2 eq 0)
  t=randomu(seed,n) & y=tan(!pi*t)
  sq=sqrt(2*x) & alxm=alog(x) & g=x*alxm-lngamma(x+1.) & em=fltarr(n)
  while xp2(0) ne -1 do begin
    while xp1(0) ne -1 do begin
      hp=where(ip1 eq 0) & em(hp)=sq*y(hp)+x
      h1=where(em ge 0) & if h1(0) ne -1 then ip1(h1)=1
      t=randomu(seed,n) & y=tan(!pi*t) & xp1=where(ip1 eq 0)
    endwhile
    em=float(long(em))
    z=em*alxm-lngamma(em+1.)-g & z=0.9*(1.+y^2)*exp(z)
    h1=where(randomu(seed,n) le z and ip2 eq 0) & if h1(0) ne -1 then ip2(h1)=1
    t=randomu(seed,n) & y=tan(!pi*t) & xp2=where(ip2 eq 0)
    hp=where(ip2 eq 0) & if hp(0) ne -1 then em(hp)=sq*y(hp)+x
    if hp(0) ne -1 then ip1(hp)=0 & xp1=where(ip1 eq 0)
  endwhile
endelse

return,em
end
