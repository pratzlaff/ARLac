pro ks2,data1,data2,d,prob, _extra=e
;+
;procedure	ks2
;	compute Kolmogorov-Smirnov sstatistic and significance for 2 datasets
;	based on NumRecC2, 14.3, 625
;
;parameters
;	data1	[INPUT; required] first dataset (must be an array)
;	data2	[INPUT; required] second dataset (must be an array)
;	d	[OUTPUT] K-S statistic
;	prob	[OUTPUT] significance of D
;
;keywords
;	_extra	[INPUT] use this to pass defined keywords to PROBKS
;
;description
;	given an array DATA1[N1] and DATA2[N2], this routine returns the K-S
;	statistic D and the significance level PROB for the null hypothesis
;	that the datasets are drawn from the same distribution.  Small values
;	of PROB show that the cdf of DATA1 is significantly different from
;	that of DATA2.
;
;subroutines
;	PROBKS
;	
;history
;	translated to IDL by Vinay Kashyap (Mar98)
;	vectorized the algorithm, added keyword _EXTRA (VK; Nov98)
;	replaced calls to INTERPOL by calls to INTERPOLATE/FINDEX;
;	  speeds up program by anywhere from 30-90% (VK; 99Jun)
;-

;	usage
n1=n_elements(data1) & n2=n_elements(data2)
if n1 le 1 or n2 le 1 then begin
  print,'Usage: ks2,data1,data2,d,prob, nterm=nterm,eps1=eps1,eps2=eps2'
  print,'  compute K-S statistic and significance for 2 data sets'
  return
endif

;	sort inputs (if necessary)
tmp=data1(1:*)-data1 & oo=where(tmp lt 0,moo)
if moo gt 0 then d1=data1(sort(data1)) else d1=data1
tmp=data2(1:*)-data2 & oo=where(tmp lt 0,moo)
if moo gt 0 then d2=data2(sort(data2)) else d2=data2

;	initialize
en1=float(n1) & en2=float(n2) & d=0.

;{VK	the following is the original code from NumRec.  As one may suspect,
;VK	it is not optimized for IDL.  Following this block is a vectorized
;VK	version that does the same thing but saves hours.
;VK	
;VK	j1=1L & j2=1L & fn1=0. & fn2=0.
;VK	while j1 lt n1 and j2 lt n2 do begin
;VK	  dd1=d1(j1-1L) & dd2=d2(j2-1L)
;VK	  if dd1 le dd2 then begin
;VK	    fn1=j1/en1 & j1=j1+1L
;VK	  endif
;VK	  if dd2 le dd1 then begin
;VK	    fn2=j2/en2 & j2=j2+1L
;VK	  endif
;VK	  dt=abs(fn2-fn1)
;VK	  if dt gt d then d=dt
;VK	endwhile
;VK}

;{VK	beginning of new version

;	make CDFs
cdf1=(findgen(n1)+1.)/en1 & cdf2=(findgen(n2)+1.)/en2

;	interpolate one to the grid of the other
;
;(-- originally used interpol, thusly:
;	if n1 ge n2 then begin
;	  cdf12=((interpol(cdf1,d1,d2) < 1) > 0)
;	  d=max(abs(cdf12-cdf2))
;	endif else begin
;	  cdf21=((interpol(cdf2,d2,d1) < 1) > 0)
;	  d=max(abs(cdf21-cdf1))
;	endelse
;-- but found interpolate/findex to be a bit faster)
;
if n1 ge n2 then begin
  cdf12=((interpolate(cdf1,findex(d1,d2)) < 1) > 0)
  d=max(abs(cdf12-cdf2))
endif else begin
  cdf21=((interpolate(cdf2,findex(d2,d1)) < 1) > 0)
  d=max(abs(cdf21-cdf1))
endelse

;VK	end of new version}

en=sqrt(en1*en2/(en1+en2))
prob=probks((en+0.12+0.11/en)*d)

case n_params() of
  2: print,'Dmax = '+strtrim(d,2)+'	Significance of null hypothesis='+$
	strtrim(prob,2)
  3: print,'Significance of null hypothesis='+strtrim(prob,2)
  else:	;nothing
endcase

return
end
