function oddsource1,nb,ns,ab,as,alpha=alpha,beta=beta
;+
;-

alpha=1.
beta=0.

A=ab+as & N=nb+ns

tmp=dblarr(ns+1L)
for k=0L,ns do tmp[k]=k*alog(A/as)+lngamma(ns+1.)+lngamma(N-k+0.)-lngamma(ns-k+1.)
tmpnorm=max(tmp) & dtmp=tmp-tmpnorm
tmpsum=total(exp(dtmp))

odds=tmpnorm+alog(tmpsum)-alog(alpha)-lngamma(N)

odds=exp(odds)

return,odds
end
