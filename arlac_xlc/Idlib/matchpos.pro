function matchpos,x1,y1,x2,y2,s1=s1,s2=s2,sy1=sy1,sy2=sy2,thresh=thresh,$
	verbose=verbose,best=best,del=del,_extra=e
;+
;function	matchpos
;	matches two list of positions and returns a string array of
;	indices in *second* list identified with given entry of *first*
;	list.
;
;parameters
;	x1	[INPUT; required] list 1 x-positions
;	y1	[INPUT; required] list 1 y-positions
;	x2	[INPUT; required] list 2 x-positions
;	y2	[INPUT; required] list 2 y-positions
;
;keywords
;	s1	[INPUT] errors on x1
;	s2	[INPUT] errors on x2
;	sy1	[INPUT] errors on y1
;	sy2	[INPUT] errors on y2
;		* errors are assumed to be gaussian, i.e., the supplied
;		  values are std.deviations
;		* if not specified, SY2 assumed to be identical to S2,
;		  SY1 to S1, S2 to <S1>
;		* if S1 is not specified, estimated in situ
;		* if scalar, assumed to be constant for all corresponding
;		  positions
;		* if vector, MUST match the length of position arrays
;		  (else ignored)
;	thresh	[INPUT; default=0.5] threshold probability of match.  the
;		probability is computed as the overlap integral of the
;		gaussians involved
;		* if THRESH < 0, then assumed to mean a distance threshold
;		  (i.e., positions are matched if their distances are
;		  < ABS(THRESH))
;	verbose	[INPUT] if set, blabbers
;	best	[INPUT] if set, returns only the best match (i.e., one with
;		the highest probability -- note that this is not necessarily
;		the nearest)
;	del	[OUTPUT] string array in same format as output, but containing
;		distances to each of the matched points.
;
;history
;	vinay kashyap (Dec97)
;-

;	usage
n1=n_elements(x1) & m1=n_elements(y1) & n2=n_elements(x2) & m2=n_elements(y2)
if n1 eq 0 or m1 eq 0 or n2 eq 0 or m2 eq 0 then begin
  print,'Usage: match=matchpos(x1,y1,x2,y2,s1=s1,s2=s2,sy1=sy1,sy2=sy2,$'
  print,'       thresh=thresh,verbose=v,best=best,del=del,_extra=e'
  print,'  returns string array of indices of (x2,y2) matching (x1,y1)'
  return,''
endif

;	error check
c1='ok'
if n1 ne m1 then c1='Xpos and Ypos in list 1 incompatible' else $
  if n2 ne m2 then c1='Xpos and Ypos in list 2 incompatible'
if c1 ne 'ok' then begin
  message,c1,/info & return,strarr(n1)
endif

;	collect variables
x=[x1(*)] & y=[y1(*)] & xx=[x2(*)] & yy=[y2(*)]

;	decipher keywords
p1=n_elements(s1) & p2=n_elements(s2) & q1=n_elements(sy1) & q2=n_elements(sy2)
;
case p1 of		;{is sigma_x1 given?
  0: begin		;(estimate sigma_x1
    xmin=0*x
    for i=0L,n1-1L do begin
      dx=abs(x-x(i)) & ox=where(dx gt 0,mox)
      if mox gt 0 then xmin(i)=min(dx(ox)) else xmin(i)=0
    endfor
    oo=where(xmin gt 0,moo)
    if moo eq 0 then xs1=1+0*x else xs1=total(xmin(oo))/moo + 0*x
  end			;sigma_x1 from x1)
  1: xs1=0*x+s1(0)
  else: begin
    if p1 eq n1 then xs1=[s1(*)] else xs1=0*x+s1(0)
  end
endcase			;sigma_x1}
;
case p2 of		;{is sigma_x2 given?
  0: xs2=total(xs1)/n1 + 0*xx
  1: xs2=0*xx+s2(0)
  else: begin
    if p2 eq n2 then xs2=[s2(*)] else xs2=0*xx+s2(0)
  end
endcase			;sigma_x2}
;
case q1 of		;{is sigma_y1 given?
  0: ys1=xs1
  1: ys1=0*y+sy1(0)
  else: begin
    if q1 eq m1 then ys1=[sy1(*)] else ys1=0*y+sy1(0)
  end
endcase			;sigma_y1}
;
case q2 of		;{is sigma_y2 given?
  0: ys2=xs2
  1: ys2=0*yy+sy2(0)
  else: begin
    if q2 eq m2 then ys2=[sy2(*)] else ys2=0*yy+sy2(0)
  end
endcase			;sigma_y2}
;
if not keyword_set(thresh) then thresh=0.5

;	define the arrays to contain the outputs
cat=strarr(n1) & del=cat

;	step through the positions and find the matches
for i=0L,n1-1L do begin			;{for each position in list 1
  if keyword_set(verbose) then begin
    kilroy,dot=strtrim(i,2)+' '
    plot,x,y,/nodata,xr=x(i)+xs1(i)*[2,-2],yr=y(i)+ys1(i)*[2,-2],/xs,/ys,$
	title='('+strtrim(x(i),2)+','+strtrim(y(i),2)+')'
    oplot,[x(i)],[y(i)],psym=4
  endif

  d=sqrt((x(i)-xx)^2+(y(i)-yy)^2)
  if thresh(0) lt 0 then begin		;(use distance cut-off threshold
    prb=-d
  endif else begin			;)(compute probabilities
    ;NOT IMPLEMENTED YET!
    ;currently uses a simple distance/variance based metric
    prb=(1.-sqrt(((x(i)-xx)/xs1(i))^2+((y(i)-yy)/ys1(i))^2)) > 0
  endelse				;end thresholding)

  oo=where(prb gt thresh(0),moo)
  if moo gt 0 then begin		;(found match!
    pp=prb(oo) & dd=d(oo)
    op=reverse(sort(pp)) & pp=pp(op) & dd=dd(op) & ii=oo(op)
    if keyword_set(best) then j1=0L else j1=moo-1L
    for j=0,j1 do begin
      cat(i)=cat(i)+strtrim(ii(j),2)+' '
      del(i)=del(i)+strtrim(dd(j),2)+' '
    endfor
    if keyword_set(verbose) then begin
      xa=xx(oo) & ya=yy(oo)
      xa=xa(op) & ya=ya(op)
      oplot,[xa(0)],[ya(0)],psym=7
      for j=0,moo-1L do oplot,[xa(j)],[ya(j)],psym=1
      for j=0,moo-1L do xyouts,xa(j),ya(j),strtrim(ii(j),1),align=-0.5
      c1='hit any key to continue, q to stop' & print,c1
      c1=get_kbrd(1) & if c1 eq 'q' then stop
    endif
  endif					;matched)
endfor					;I=0,N1-1}

return,cat
end
