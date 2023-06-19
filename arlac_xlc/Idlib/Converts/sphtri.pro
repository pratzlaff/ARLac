pro sphtri,os,sa=sa,sb=sb,sc=sc,alf=alf,bet=bet,gam=gam
;+
;procedure	sphtri
;	given 3 angles of a spherical triangle OABC, computes the others
;
;parameters
;	os	[OUTPUT] structure containing results of calculation
;
;keywords
;	sa	[INPUT; default=pi/2] angle subtended by side BC at O
;	sb	[INPUT; default=pi/2] angle subtended by side CA at O
;	sc	[INPUT; default=pi/2] angle subtended by side AB at O
;	alf	[INPUT; default=pi/2] included angle opposite BC, i.e., BAC
;	bet	[INPUT; default=pi/2] included angle opposite CA, i.e., ABC
;	gam	[INPUT; default=pi/2] included angle opposite AB, i.e., BCA
;
;history
;	vinay kashyap (Jun97)
;-

;	usage
if n_params() eq 0 then begin
  print,'Usage: sphtri,os,sa=sa,sb=sb,sc=sc,alf=alf,bet=bet,gam=gam'
  print,'  compute missing angles in a spherical triangle'
  return
endif

message,'not written',/info

return
end
