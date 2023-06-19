function timestamp,time,tform
;function       timestamp
;       return a structure with all the time components after deciphering 
;       the input string
;
;	I know about STR_TO_DT.  I just think it's too limiting.
;
;parameters
;       time    [INPUT; required] character string to decipher
;       tform   [INPUT; required] free-form format of input
;               * Y/YY/YYYY: year, M/MM/MMM/Mon: month, D/DD: day,
;		  DDD: day of year, H/HH: hour, MM/MM.M/MN/min: minute,
;		  S/SS/SS.S: second, W/WWW: week, J/JD: Julian day,
;		  mjd: modified JD, Z/ZZZ/ZST: time zone
;               * the ambiguity between MM=month and MM=minute is resolved 
;                 by checking for HH -- minutes are expected to follow
;                 immediately after hours.
;		* HH must always be in 24-hour format
;
;examples
;       TFORM for the output of /usr/bin/date is
;	"W M D H:M:S Z Y" or "WWW MMM DD HH:MM:SS ZZZ YYYY"
;
;keywords       NONE
;
;history
;       vinay kashyap (1999:12)
;-

;       usage
ok='ok'
nt=n_elements(time) & szt=size(time) & nszt=n_elements(szt)
nf=n_elements(tform) & szf=size(tform) & nszf=n_elements(szf)
if nt eq 0 then ok='undefined input time' else $
 if nf eq 0 then ok='undefined format' else $
  if szt(nszt-2) ne 7 then ok='input time must be character string' else $
   if szf(nszf-2) ne 7 then ok='input format must be character string' else $
    if nt gt 1 then ok='input time cannot be array' else $
     if nf gt 1 then ok='format cannot be array' else $
      if n_params() eq 0 then ok='missing input'
if ok ne 'ok' then begin
  print,'Usage: t=timestamp(time,tform)'
  print,' return components of time'
  if n_params() gt 0 then message,ok,/info
  return,today()
endif
tt=time(0) & tf=tform(0)

;	figure out TFORM

;	Y/YY/YYYY
iy=grep(tf,'y',ny,/nocase)

return,stamp
end
