function pds_eqhor,lat,pp,qq,gethor=gethor,geteq=geteq,$
	_extra=e
;+
;procedure	pds_eqhor
;	converts celestial coordinates in horizon system (azimuth,altitude)
;	into equatorial coordinates (hour-angle,declination) and vice versa
;	and returns the output in a structure of the form {AZ,ALT} or {HA,DEC}
;
;syntax
;	.run pds_eqhor
;	azalt=pds_eqhor(lat,ha,dec,/gethor)
;	hadec=pds_eqhor(lat,az,alt,/geteq)
;
;parameters
;	lat	[INPUT; required] latitude of observation
;	pp	[INPUT; required] azimuth xor hour angle [degrees]
;	qq	[INPUT; required] altitude xor declination [degrees]
;		* if the array sizes of LAT,PP,QQ match, output will
;		  be of same size
;		* if array sizes don't match, calculations will be performed
;		  for all possible combinations of {LAT x PP x QQ}
;
;keywords
;	gethor	[INPUT; default=1] if set, converts from (HA,Dec) to (AZ,Alt),
;		i.e., equatorial to horizon
;	geteq	[INPUT; default=0] if set, converts from (AZ,Alt) to (HA,Dec),
;		i.e., horizon to equatorial
;		* GETEQ overrides GETHOR
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;
;subroutines
;	PDS_CALDAY()
;	PDS_MINSEC()
;	PDS_JULDAY()
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1500
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params()
nlat=n_elements(lat) & npp=n_elements(pp) & nqq=n_elements(qq)
pname='HA' & if keyword_set(geteq) then pname='AZ'
qname='DEC' & if keyword_set(geteq) then pname='ALT'
if np lt 3 then ok='Insufficient parameters' else $
 if nlat eq 0 then ok='LAT is undefined' else $
  if npp eq 0 then ok=pname+' is undefined' else $
   if nqq eq 0 then ok=qname+' is undefined'
if ok ne 'ok' then begin
  print,'Usage: azalt=pds_eqhor(lat,HA,DEC,/gethor)'
  print,'       hadec=pds_eqhor(lat,AZ,ALT,/geteq)'
  print,'  converts horizon coords to equatorial and vice versa'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	initialize
phi=[lat] & xpp=[pp] & xqq=[qq] & nout=nlat
if nlat ne npp or nlat ne nqq then begin
  phi=dblarr(nlat,npp,nqq) & for i=0,nlat-1 do phi[i,*,*]=lat[i]
  xpp=dblarr(nlat,npp,nqq) & for j=0,npp-1 do xpp[*,j,*]=pp[j]
  xqq=dblarr(nlat,npp,nqq) & for k=0,nqq-1 do xqq[*,*,k]=qq[k]
endif

cphi=cos(phi*!dpi/180.) & sphi=sin(phi*!dpi/180.)

sy=sin(xqq*!dpi/180.) & cy=cos(xqq*!dpi/180.)
sx=sin(xpp*!dpi/180.) & cx=cos(xpp*!dpi/180.)

sq=(sy*sphi)+(cy*cphi*cx)
q=asin(sq)
cq=cos(q)
aa=cphi*cq
o0=where(aa lt 1d-20,mo0) & if mo0 gt 0 then aa[o0]=1d-20
cp=(sy-(sphi*sq))/aa
p=acos(cp)
oz=where(sx gt 0,moz) & if moz gt 0 then p[oz]=2.D * !dpi - p[oz]

;	reform output if necessary
if nout eq 1 then begin
  p=p[0] & q=q[0]
endif
p=p*180./!dpi & q=q*180./!dpi

if keyword_set(geteq) then return,create_struct('HA',p,'DEC',q) else $
	return,create_struct('AZ',p,'ALT',q)

end

;	handling program for PDS_EQHOR
jnk=pds_eqhor()
print,'' & print,''
ans='equatorial/horizon coordinate conversion? [N/Y] ' & read,prompt=ans,ans & c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

newlat=1
while go_on do begin
  if keyword_set(newlat) then begin
    read,prompt='Geographical latitude [D,M,S] > ',latd,latm,lats
    lat_deg=pds_minsec(latd,latm,lats)
    newlat=0
  endif
  ans='Equatorial to Horizon? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 eq '' or strmid(strupcase(c1),0,1) eq 'Y' then e2h=1 else e2h=0

  if keyword_set(e2h) then begin
    read,prompt='HA [h,m,s] ',HA_h,HA_m,HA_s
    read,prompt='Dec [d,m,s] ',DEC_h,DEC_m,DEC_s
    ha_deg=15.*pds_minsec(HA_h,HA_m,HA_s) & dec_deg=pds_minsec(DEC_h,DEC_m,DEC_s)
    azalt=pds_eqhor(lat_deg,ha_deg,dec_deg,/gethor)
    astr=pds_minsec(azalt.AZ) & bstr=pds_minsec(azalt.ALT)
    print,'	Azimuth = '+strtrim(astr.D,2)+':'+strtrim(astr.M,2)+':'+strtrim(astr.S,2)
    print,'	Altitutde = '+strtrim(bstr.D,2)+':'+strtrim(bstr.M,2)+':'+strtrim(bstr.S,2)
  endif else begin
    read,prompt='Azimuth [d,m,s] ',AZ_h,AZ_m,AZ_s
    read,prompt='Altitude [d,m,s] ',Alt_h,Alt_m,Alt_s
    AZ_deg=pds_minsec(AZ_h,AZ_m,AZ_s) & Alt_deg=pds_minsec(Alt_h,Alt_m,Alt_s)
    hadec=pds_eqhor(lat_deg,AZ_deg,Alt_deg,/geteq)
    astr=pds_minsec(hadec.HA/15.) & bstr=pds_minsec(hadec.DEC)
    print,'	H.A. = '+strtrim(astr.D,2)+':'+strtrim(astr.M,2)+':'+strtrim(astr.S,2)
    print,'	Dec. = '+strtrim(bstr.D,2)+':'+strtrim(bstr.M,2)+':'+strtrim(bstr.S,2)
  endelse

  ans='Again? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0 else begin
    ans='New latitude? [N/Y] > ' & read,prompt=ans,ans & c1=strtrim(ans,2)
    if strmid(strupcase(c1),0,1) eq 'Y' then newlat=1
  endelse
endwhile

end
