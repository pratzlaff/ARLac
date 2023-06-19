function deltang,lng,lat,lng0,lat0,deg=deg,rad=rad,dec=dec,$
	_extra=e
;+
;function	deltang
;	returns the angular separation in degrees of [LNG0,LAT0] from [LNG,LAT]
;	using the cosine formula for spherical triangles
;
;syntax
;	sep=deltang(LNG,LAT,LNG0,LAT0,/deg,fsep=fsep,sep=sep,/squish)
;
;parameters
;	lng	[INPUT; required] array of "longitudinal" coordinates, such
;		as RA or l_II [deg]
;	lat	[INPUT; required] array of "latitudinal" coordinates, such
;		as Dec or b_II [deg]
;	lng0	[INPUT] coordinate of "longitude" from which separations
;		must be computed [deg]
;	lat0	[INPUT] coordinate of "latitude" corresponsing to LNG0 [deg]
;
;		NOTES:-
;		* array size of LAT must match that of LNG
;		* if any of the inputs are strings,
;		  - assumed to be in sexagesimal notation (calls HRS2DEG)
;		  - longitude coordinate assumed to be in H:M:S notation
;		    unless DEG is set
;		  - in all other cases, assumed to be in [deg]
;		* if LNG0 and LAT0 are not given, they are taken
;		  to be the first elements of LNG and LAT respectively
;		* if LNG0 and LAT0 match the sizes of LNG and LAT, the
;		  separation between each pair is calculated
;
;keywords
;	deg	[INPUT] if set, input is assumed to be given in [degree]
;		* has an effect only if the longitudinal coordinate is
;		  input as a string
;	dec	[INPUT] here only to catch and discard -- it is used
;		within HRS2DEG, but this program knows how to call it
;		and therefore it shouldn't be set in the sequence
;	_extra	[INPUT ONLY] use this to pass defined keywords to
;		HRS2DEG: FSEP
;		STR2ARR: SEP, SQUISH
;
;restrictions
;	requires subroutines HRS2DEG and STR2ARR
;	do not set keyword DEC (it will confuse HRS2DEG)
;	no checks are carried out to verify whether the inputs are in
;	  the proper range (0<LNG<360, -90<LAT<90)
;
;history
;	vinay kashyap (99Apr; based on ANGSEP)
;	modified to allow LNG0 and LAT0 to be equal in size to
;	  LNG and LAT, so that separation between independent
;	  pairs can also be calculated; also cleaned up a bit
;	  (VK; 08Mar)
;-

;	usage
ok='ok' & np=n_params() 
mg=n_elements(lng) & ma=n_elements(lat)
mg0=n_elements(lng0) & ma0=n_elements(lat0)
if np lt 2 then ok='insufficient parameters' else $
 if mg eq 0 then ok='missing coordinate: LNG' else $
  if ma eq 0 then ok='missing coordinate: LAT' else $
   if mg ne ma then ok='coordinate size mismatch: LNG v/s LAT'
if ok ne 'ok' then begin
  print,'Usage: sep=deltang(LNG,LAT,LNG0,LAT0,/deg,fsep=fsep,sep=sep,/squish)'
  print,'  returns angular separation [deg] between (LNG0,LAT0) and (LNG,LAT)'
  if np gt 0 then message,ok,/informational
  return,-1L
endif

;	check inputs
sg=size(lng,/type) & sa=size(lat,/type) & sg0=size(lng0,/type) & sa0=size(lat0,/type)
;sg=size(lng) & sa=size(lat) & sg0=size(lng0) & sa0=size(lat0)
;ng=n_elements(sg) & na=n_elements(sa)
;ng0=n_elements(sg0) & na0=n_elements(sa0)
;
lg=lng & la=lat
if sg[0] eq 7 then lg=hrs2deg(lng,dec=deg, _extra=e) else lg=float(lng)
if sa[0] eq 7 then la=hrs2deg(lat,/dec, _extra=e) else la=float(lat)

;if sg0[0] eq 7 then lg0=hrs2deg(lng0(0),dec=deg, _extra=e) else $
; if n_elements(lng0) ge 1 then begin
;   lg0=float(lng0(0))
; endif else lg0=lg(0)
;if sa0[na0-2] eq 7 then la0=hrs2deg(lat0(0),dec=1, _extra=e) else $
; if n_elements(lat0) ge 1 then la0=float(lat0(0)) else la0=la(0)

if mg0 gt 0 then begin		;(LNG0 is given
  if mg0 eq mg then lg0=lng0 else lg0=lng0[0]
  if sg0[0] eq 7 then lg0=hrs2deg(lg0,deg=deg, _extra=e) else lg0=float(lg0)
endif else lg0=lg[0]		;LNG0)
if ma0 gt 0 then begin		;(LAT0 is given
  if ma0 eq ma then la0=lat0 else la0=lat0[0]
  if sa0[0] eq 7 then la0=hrs2deg(la0,/dec, _extra=e) else la0=float(la0)
endif else la0=la[0]		;LAT0)

;if n_elements(lng0) eq 0 then lg0=lg(0)
;if n_elements(lat0) eq 0 then la0=la(0)
;if sg0(ng0-1) ge 1 then lg0=lng0(0)
;if sa0(na0-1) ge 1 then la0=lat0(0)
;if sg0(ng0-2) eq 7 then lg0=hrs2deg(lg0,dec=deg, _extra=e)
;if sa0(na0-2) eq 7 then la0=hrs2deg(la0,/dec, _extra=e)

;	the cosine formula (even for spherical triangles) is:
;		cos(c) = cos(b)*cos(a) + sin(b)*sin(a)*cos(C)
;	where b=distance of LAT from north pole, a=distance of LAT0 from
;	north pole, C=delta(LNG)

;	convert LATs so that 0 is at north pole and 180 at south pole
la=90.-la & la0=90.-la0 & dlg=lg-lg0

;	convert to radians
la=la*!dpi/180. & la0=la0*!dpi/180. & dlg=dlg*!dpi/180.

cosang=cos(la)*cos(la0)+sin(la)*sin(la0)*cos(dlg)
angsep=acos(cosang)*180./!pi

return,angsep
end
