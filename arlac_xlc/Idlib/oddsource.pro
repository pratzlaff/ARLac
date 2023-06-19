function oddsource,nb,ns,ab,as,fS=fS,fB=fB,alfa=alfa,beta=beta
;+
;-

fB=0. & fS=1.

if n_elements(alfa) eq 0 then alfa=ns+1.
if n_elements(beta) eq 0 then beta=as/(as+ab)
alfa = alfa > 1
beta = beta > 0

A=ab+as & N=nb+ns & f=fB+fS

tmp=dblarr(ns+1L)
for k=0L,ns do tmp[k]=$
	k*alog(1+(ab/as))-(k+alfa)*alog(1.+beta)+$
	lngamma(ns+1)+lngamma(k+alfa)+lngamma(ns+nb-k+1)-lngamma(k+1)+lngamma(ns-k+1)

tmpnorm=max(tmp) & dtmp=tmp-tmpnorm
tmpsum=total(exp(dtmp))

if beta gt 0 then const=alfa*alog(beta) else const=0.D
const=const+lngamma(alfa)

odds=tmpnorm+alog(tmpsum)+const-lngamma(ns+nb+1)

odds=exp(odds)

return,odds
end
