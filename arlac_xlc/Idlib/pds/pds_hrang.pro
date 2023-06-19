function pds_hrang,lng,gst,xx,GetHA=GetHA,GetRA=GetRA,$
	_extra=e
;+
;procedure	pds_hrang
;	converts Right Ascension into Hour Angle and vice versa
;	for the specified Greenwich Sidereal Time and geographic
;	longitude
;
;syntax
;	.run pds_hrang
;	ha=pds_hrang(lng,gst,ra,/GetHA)
;	ra=pds_hrang(lng,gst,ha,/GetRA)
;
;parameters
;	lng	[INPUT; required] geographical longitude of observation
;		in [degrees]
;		* E positive, W negative
;	gst	[INPUT; required] Greenwich Sidereal Time in [decimal hours]
;	xx	[INPUT; required] RA xor HA [hours]
;		* if the array sizes of LNG,GST,XX match, output will
;		  be of same size
;		* if array sizes don't match, calculations will be performed
;		  for all possible combinations of {LNG x GST x XX}
;
;keywords
;	GetHA	[INPUT; default=1] if set, converts from RA to HA
;	GetRA	[INPUT; default=0] if set, converts from HA to RA
;		* GETRA overrides GETHA
;	_extra	[JUNK; here only to prevent crashing the program]
;
;description
;	Hour Angle = Local Sidereal Time - Right Ascension
;	where
;	Local Sidereal Time = Greenwich Mean Sidereal Time + (longitude/15)
;
;subroutines
;	PDS_CALDAY()
;	PDS_MINSEC()
;	PDS_JULDAY()
;
;history
;	from Peter Duffett-Smith's "Astronomy with your Personal Computer",
;	  1985, Cambridge University Press, reprinted 1988, GOSUB 1600
;	translated to IDL by Vinay Kashyap (Jul2007)
;-

;	usage
ok='ok' & np=n_params()
nlng=n_elements(lng) & ngst=n_elements(gst) & nxx=n_elements(xx)
mgst=n_tags(gst)
pname='RA' & if keyword_set(getra) then pname='HA'
if np lt 3 then ok='Insufficient parameters' else $
 if nlng eq 0 then ok='LNG is undefined' else $
  if ngst eq 0 then ok='GST is undefined' else $
   if nxx eq 0 then ok=pname+' is undefined' else $
    if mgst gt 0 then ok='GST is structure? try pds_minsec(gst.D,gst.M,gst.S) instead'
if ok ne 'ok' then begin
  print,'Usage: ha=pds_hrang(lng,gst,ra,/getha)'
  print,'       ra=pds_hrang(lng,gst,ha,/getha)'
  print,'  converts Hour Angle to Right Ascension and vice versa'
  if np ne 0 then message,ok,/informational
  return,-1L
endif

;	initialize
xlng=[lng] & xgst=[gst] & xxx=[xx] & nout=nlng
if nlng ne ngst or nlng ne nxx then begin
  xlng=dblarr(nlng,ngst,nxx) & for i=0,nlng-1 do xlng[i,*,*]=lng[i]
  xgst=dblarr(nlng,ngst,nxx) & for j=0,ngst-1 do xgst[*,j,*]=gst[j]
  xxx=dblarr(nlng,ngst,nxx) & for k=0,nxx-1 do xxx[*,*,k]=xx[k]
endif

lst = gst+lng/15.
lst = (lst+24) mod 24
pp = lst - xxx
pp = (pp+24) mod 24

;	reform output if necessary
if nout eq 1 then pp=pp[0]

return,pp

end

;	handling program for PDS_HRANG
jnk=pds_hrang()
print,'' & print,''
ans='Right-ascension <-> hour-angles? [N/Y] ' & read,prompt=ans,ans & c1=strtrim(ans,2) & go_on=0
if strmid(strupcase(c1),0,1) eq 'Y' then go_on=1

newlng=1 & newtim=1
while go_on do begin
  if keyword_set(newlng) then begin
    read,prompt='Geographical longitude [D,M,S; west negative] > ',lngd,lngm,lngs
    lng_deg=pds_minsec(lngd,lngm,lngs)
    newlng=0
  endif
  if keyword_set(newtim) then begin
    read,prompt='Date [D,M,Y] > ',dy,mon,yr
    read,prompt='Time [H,M,S] > ',hr,mn,sec
    ;tim=pds_minsec(hr,mn,sec)
    hms=pds_gtime(hr,mn,sec,day=dy,mon=mon,year=yr,/getst)
    gst=pds_minsec(hms.D,hms.M,hms.S)
    newtim=0
  endif

  ans='RA to HA? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 eq '' or strmid(strupcase(c1),0,1) eq 'Y' then r2h=1 else r2h=0

  if keyword_set(r2h) then begin
    read,prompt='RA [h,m,s] ',RA_h,RA_m,RA_s
    ra_deg=pds_minsec(RA_h,RA_m,RA_s)
    haang=pds_hrang(lng_deg,gst,ra_deg,/GetHA)
    astr=pds_minsec(haang)
    print,'	H.A. = '+strtrim(astr.D,2)+':'+strtrim(astr.M,2)+':'+strtrim(astr.S,2)
  endif else begin
    read,prompt='HA [h,m,s] ',HA_h,HA_m,HA_s
    ha_deg=pds_minsec(HA_h,HA_m,HA_s)
    raang=pds_hrang(lng_deg,gst,ha_deg,/GetRA)
    astr=pds_minsec(raang)
    print,'	R.A. = '+strtrim(astr.D,2)+':'+strtrim(astr.M,2)+':'+strtrim(astr.S,2)
  endelse

  ans='Again? [Y/N] ' & read,prompt=ans,ans & c1=strtrim(ans,2)
  if c1 ne '' and strmid(strupcase(c1),0,1) ne 'Y' then go_on=0 else begin
    ans='New longitude? [N/Y] > ' & read,prompt=ans,ans & c1=strtrim(ans,2)
    if strmid(strupcase(c1),0,1) eq 'Y' then newlng=1
    ans='New time? [N/Y] > ' & read,prompt=ans,ans & c1=strtrim(ans,2)
    if strmid(strupcase(c1),0,1) eq 'Y' then newtim=1
  endelse
endwhile

end
