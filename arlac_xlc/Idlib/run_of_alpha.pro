;+
; dN/dx = k*x^(-a)
; dNlo/dxlo = k*xlo^(-a) => log(dNlo)-log(dxlo)=-a*log(xlo)+log(k)
; dNhi/dxhi = k*xhi^(-a) => log(dNhi)-log(dxhi)=-a*log(xhi)+log(k)
; => log(dNlo/dNhi)-log(dxlo/dxhi)=-a*log(xlo/xhi)
; => a = (log(dxlo/dxhi)-log(dNlo/dNhi))/log(xlo/xhi)
;-

readcol,'/home/kashyap/radii.lst',rr

os=sort(rr) & xx=rr[os] & nx=n_elements(xx)

xu=xx[uniq(xx,sort(xx))] & nu=n_elements(xu) & alf=fltarr(nu-1L)

for i=1L,nu-2L do begin
  xlo=xu[i-1L] & xmi=xu[i] & xhi=xu[i+1L]
  mxlo=0.5*(xlo+xmi) & mxhi=0.5*(xmi+xhi)
  dxlo=xmi-xlo & dxhi=xhi-xmi
  jnk=where(rr ge xlo and rr lt xmi,dnlo)
  jnk=where(rr ge xmi and rr lt xhi,dnhi)
  alf[i]=(alog10(dxlo/dxhi)-alog10(float(dnlo)/float(dnhi)))/(alog10(mxlo/mxhi))
endfor

;ii=indgen(nx-2L)
;xlo=xx[ii-1L] & xmi=xx[ii] & xhi=xx[ii+1L]
;xxlo=0.5*(xlo+xmi) & xxhi=0.5*(xmi+xhi)
;dlo=xmi-xlo & dhi=xhi-xmi
;alf=alog10(dhi/dlo)/alog10(xxhi/xxlo)

oo=where(xu gt 300)
plot,xu[0:nu-2],alf,psym=1,/xlog,yr=[-150,150],/xs
print,'mean+-sig,mode[hipd_int],median for all',mean(alf,/nan),'+-',stddev(alf,/nan),modalpoint(alf),'[',hipd_interval(alf,/fsample),']',median(alf)
print,'mean+-sig,mode[hipd_int],median for R>300',mean(alf[oo],/nan),'+-',stddev(alf[oo],/nan),modalpoint(alf[oo]),'[',hipd_interval(alf[oo],/fsample),']',median(alf[oo])

end
