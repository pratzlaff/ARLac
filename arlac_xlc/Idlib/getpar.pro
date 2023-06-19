function getpar,params,dbase=dbase,ask=ask
;+
;function	getpar
;		returns array of parameters that can be used in generic
;		parameter dependent programs (eg: spec.pro, imf.pro, etc)
;
;parameters	params	input parameter array or scalar
;			params(0): module to be called
;			params(1:*): parameters for module
;			NOTE: if PARAMS(0) is +ve, the defaults in DBASE
;			are used.  if PARAMS(0) is -ve, each unset parameter
;			value is explicitly prompted for.
;
;keywords	dbase	input array containing default values for each module
;			(must be defined in the calling program)
;			array is of the following format:
;			[...,module#,# of parameters required, parameters,...]
;		ask	input character array of prompts in case some values
;			must be asked for explicitly
;
;subroutines
;	RDVALUE
;
;history
;	vinay kashyap (mid 1993)
;-

np = n_params(0)
if np eq 0 then begin
  print, 'Usage: par = getpar(params,dbase=[...,mod#,#params,parameters,...],$
  print, '             ask=[...,"prompts for parameters",...])'
  print, '  use to initialize parameters for "multi-tasking" programs'
  return,0
endif

;catch errors
if n_elements(params) eq 0 then params=0
if not keyword_set(dbase) then begin
  print, 'values not initialized!  what, you think i am psychic?'
  return,params
endif
sz = size(dbase) & if sz(0) lt 1 then return,params

;decipher arrays DBASE and ASK
ndb = sz(1) & i = 0 & nmod = 0 & nskp = 0 & j = 0
while i lt ndb do begin
  nmod = nmod+1 & skip = dbase(i+1) & i = i + 1 + skip + 1
  if skip gt nskp then nskp = skip
endwhile
if nskp eq 0 then begin
  print, 'huh?  for this you call me?' & return,params
endif
val = fltarr(nmod,nskp) & prmpt = strarr(nmod,nskp) & npar = intarr(nmod)
i = 0
while j lt ndb do begin
  imod = dbase(j) & ipar = dbase(j+1) & npar(imod-1) = ipar
  if ipar gt 0 then begin
    val(imod-1,0:ipar-1) = dbase(j+2:j+2+ipar-1)
    if keyword_set(ask) then prmpt(imod-1,0:ipar-1) = ask(i:i+ipar-1)
  endif
  j = j + 1 + ipar + 1 & i = i + ipar
endwhile

;now set up the parameter array for the specific request
sz = size(params) & imod = fix(params(0)) & inp = 0
if sz(0) eq 0 then begin				;params is scalar
  if imod ge 1 and imod le nmod then begin
    ipar = npar(imod-1) & par = [imod, reform(val(imod-1,0:ipar-1))]
    return,par
  endif else begin
    c1 = 'type module number [1,'+strtrim(nmod,2)+']' & inp = 1
    rdvalue,c1,imod,abs(imod),/i & params = [float(imod)] & sz = size(params)
  endelse
endif

;if necessary, ask.
if imod lt 0 then begin
  imod = -imod & inp = 1
endif
if imod lt 1 or imod gt nmod then begin
  c1 = 'type module number [1,'+strtrim(nmod,2)+']' & inp = 1
  rdvalue,c1,imod,1,/i & if abs(imod) lt 1 or abs(imod) gt nmod then imod = 1
  if imod lt 0 then imod = -imod
  params = [float(imod)]
endif
par = float(params) & ipar = npar(imod-1)
for i=0,ipar-1 do begin
  x = val(imod-1,i) & c1 = prmpt(imod-1,i)
  if sz(1) lt i+2 then begin
    if inp eq 1 then rdvalue,c1,x,x & par = [par,x]
  endif else par(i+1) = params(i+1)
endfor

return,par
end
