;+
;wc02
;	how many will one get right if predictions are made
;	totally randomly for the world cup draws?
;-

;	results from stage 1.  arbitrarily given for team 1 v/s team 2,
;	with 1=win for team 1, -1=win for team 2, 0=tie
res1=[-1, 0,-1,1, 0,0,1,1, -1,1,1, -1,0,1, 1,1,0, 0,1,0, 1,1,-1,$
	1,-1,1, 1,0,1, 0,0,1, 1,0,-1,-1, 0,0,-1,-1, -1,1,0,1, -1,1,-1,1]
n1=n_elements(res1)
;	results from stage 2.  no ties in this case
res2=[1,-1,-1,1,-1,1,-1,1,-1,1,-1,-1,1,1,-1]
n2=n_elements(res2)

;	number of simulations
nsim=10000L & r1=randomu(seed,n1,nsim) & r2=randomu(seed,n2,nsim)
;	store the "record" in these arrays
s1=intarr(n1,nsim) & s2=intarr(n2,nsim)

;	for stage 1:
;	if r1>0.67 that's a predicted win for team 1
;	if r1<0.33 that's a predicted win for team 2
;	if r1>0.33 and r1<0.67 that's a predicted tie
;	prediction assumed to be correct if:
;	team 1 wins as predicted, or team 2 wins as predicted, or tie as predicted (s1==1)
;	prediction assumed to be wrong if:
;	team 1 wins instead of team 2, team 2 wins instead of team 1, predicted tie doesn't occur (s1==-1)
;	prediction assumed to be a "no decision" if:
;	team 1 or team 2 predicted to win, but the actual result is a tie (s1==0)
for i=0,n1-1 do begin
  oyes=where((r1[i,*] gt 0.67 and res1[i] eq 1) or $
	(r1[i,*] lt 0.33 and res1[i] eq -1) or $
	(r1[i,*] ge 0.33 and r1[i,*] le 0.67 and res1[i] eq 0),moyes)
  onoo=where((r1[i,*] lt 0.33 and res1[i] eq 1) or $
	(r1[i,*] gt 0.67 and res1[i] eq -1) or $
	(r1[i,*] ge 0.33 and r1[i,*] le 0.67 and res1[i] ne 0),monoo)
  omid=where((r1[i,*] lt 0.33 or r1[i,*] gt 0.67) and res1[i] eq 0,momid)
  if moyes gt 0 then s1[i,oyes]=1
  if monoo gt 0 then s1[i,onoo]=-1
  if momid gt 0 then s1[i,omid]=0
endfor

;	for stage 2:
;	same as for stage 1, except there are no ties, so the
;	break point is at 0.5 instead of 0.33 and 0.67
for i=0,n2-1 do begin
  oyes=where((r2[i,*] gt 0.5 and res2[i] eq 1) or $
	(r1[i,*] le 0.5 and res2[i] eq -1),moyes)
  onoo=where((r2[i,*] lt 0.5 and res2[i] eq 1) or $
	(r1[i,*] ge 0.5 and res2[i] eq -1),monoo)
  if moyes gt 0 then s2[i,oyes]=1
  if monoo gt 0 then s2[i,onoo]=-1
endfor

y1=intarr(nsim) & n1=y1 & t1=y1 & y2=y1 & n2=y1
for i=0,nsim-1 do begin
  y1[i]=n_elements(where(s1[*,i] eq 1))
  n1[i]=n_elements(where(s1[*,i] eq -1))
  t1[i]=n_elements(where(s1[*,i] eq 0))
  y2[i]=n_elements(where(s2[*,i] eq 1))
  n2[i]=n_elements(where(s2[*,i] eq -1))
endfor
y1ave=total(y1)/nsim & n1ave=total(n1)/nsim & t1ave=total(t1)/nsim
y2ave=total(y2)/nsim & n2ave=total(n2)/nsim
y1err=sqrt(total(y1^2)/nsim-y1ave^2)
n1err=sqrt(total(n1^2)/nsim-n1ave^2)
t1err=sqrt(total(t1^2)/nsim-t1ave^2)
y2err=sqrt(total(y2^2)/nsim-y2ave^2)
n2err=sqrt(total(n2^2)/nsim-n2ave^2)

print,'Number of simulations = ',nsim
print,'Expected record after stage 1: '+$
	string(y1ave,'(f4.1)')+'+-'+string(y1err,'(f4.2)')+'  -  '+$
	string(n1ave,'(f4.1)')+'+-'+string(n1err,'(f4.2)')+'  -  '+$
	string(t1ave,'(f4.1)')+'+-'+string(t1err,'(f4.2)')
ok1=where(y1 ge 19 and n1 le 17 and t1 ge 12,mok1)
print,'probability of achieving >19-<17->12 as a fluctuation =',mok1/float(nsim)
print,'Expected record after stage 2: '+$
	string(y2ave,'(f4.1)')+'+-'+string(y2err,'(f4.2)')+'  -  '+$
	string(n2ave,'(f4.1)')+'+-'+string(n2err,'(f4.2)')
ok2=where(n2 ge 8,mok2)
print,'probability of achieving >8-<8 as a fluctuation =',mok2/float(nsim)

end
