function poisson,avg,num,cdf=cdf,xcdf=xcdf,seed=seed
;+
;FUNCTION	POISSON
;		returns a poisson realization of a quantity with the given
;		mean
;
;PARAMETERS
;		avg	mean value of quantity
;		num	number of realizations (default=1)
;
;KEYWORDS
;		cdf	stores the cumulative Poisson distribution
;		xcdf	absissae for cdf
;		seed	random number seed
;
;DESCRIPTION
;	uses the incomplete Gamma function to construct a cumulative
;	Poisson distribution with the specified mean, then using a
;	random set of numbers obtained from the system clock, computes
;	the Poisson realization.
;
;SUBROUTINES
;	GAMMAQ
;	GAMMLN
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: poi_rand = poisson(avg,num,cdf=cdf,xcdf=xcdf,seed=seed)'
  print, '  returns random poisson events for a specified mean'
  return,[0]
endif

if np eq 1 then num=1L else num=long(num) & poi = intarr(num)

pmax = avg + 10.*(sqrt(avg)+1.) & pmin = avg - 10.*(sqrt(avg)+1.)
if pmin lt 0 then pmin = 0.
prng = fix(pmax-pmin+1.) & xcdf = findgen(prng) + float(fix(pmin))

cdf = 0.*xcdf & for i=1,prng-1 do cdf(i) = gammaq(double(xcdf(i)),avg)

rx = randomu(seed,num)
for i=0L,num-1L do begin
  rr = rx(i) & poi(i) = xcdf([min(where(cdf ge rr))-1])
endfor

return,poi
end
