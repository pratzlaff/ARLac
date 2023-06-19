function oddsource,nb,ns,ab,as,fS=fS,fB=fB,$
	alfaS=alfaS,betaS=betaS,alfaB=alfaB,betaB=betaB
;+
;-

fB=0. & fS=1.

if n_elements(alfaB) eq 0 then alfaB=nb+1.
if n_elements(betaB) eq 0 then betaB=ab/(as+ab)
if n_elements(alfaS) eq 0 then alfaS=ns+1.
if n_elements(betaS) eq 0 then betaS=as/(as+ab)
alfaB = alfaB > 1
alfaS = alfaS > 1
betaB = betaB > 0
betaS = betaS > 0

A=ab+as & N=nb+ns & f=fB+fS

tmp=dblarr(ns+1L)
for k=0L,ns do tmp[k]=$
	k*alog(f+betaS)-k*alog(f*(1.+betaB)*A)-(ns-k)*alog(as)+$
	lngamma(ns+alfaS-k)+lngamma(nb+alfaB+k)-lngamma(k+1)-lngamma(ns-k+1)

tmpnorm=max(tmp) & dtmp=tmp-tmpnorm
tmpsum=total(exp(dtmp))

if betaS gt 0 then const=alfaS*alog(betaS) else const=1.
const=ns*alog(f)+lngamma(ns+1)+ns*alog(A)+ns*alog(1+betaB) -$
	lngamma(alfaS)-(ns+alfaS)*alog(f+betaS)-lngamma(N+alfaB)

odds=tmpnorm+alog(tmpsum)+const

odds=exp(odds)

return,odds
end
