pro view_img,image,scale=scale,alter=alter,oldwin=oldwin
;+
;procedure	view_img
;		allow readout of intensity values v/s pixels
;
;parameters	image	2D array to be explored in detail
;			(if not given, reads from whatever is on an
;			open X-window display)
;		
;keywords	scale	type of display
;			0: tvscl,image
;			1: tv,image
;			2: tvscl,alog10(image-min(image)+1)
;			3: tvscl,abs(image)
;			4: tvscl,sqrt(image-min(image))
;		alter	displays ALTER, but browses IMAGE
;		oldwin	if set, does NOT create extra window
;
;history
;	vinay kashyap (June 1996)
;-

;check input
np=n_params(0) & wn=!d.name & ww=!d.window
if np eq 0 and wn eq 'X' and ww gt 0 then image=tvrd()
if keyword_set(image) then begin
  np=1 & sz=size(image)
  if sz(0) lt 2 then np=0
  if sz(0) eq 2 then img=image
  if sz(0) gt 2 then begin
    img=fltarr(sz(1),sz(2)) & img(*)=image(0:sz(1)*sz(2)-1)
  endif
endif
if np eq 0 then begin
  print,'Usage: view_img,image,scale=scale,alter=alter,/oldwin'
  print,'  browse through image values' & return
endif

;check keywords
if not keyword_set(scale) then scale=0

;open new window for display
if ww lt 0 then oldwin=0
if not keyword_set(oldwin) then window,/free,xsize=sz(1),ysize=sz(2)

;display image
if keyword_set(alter) then img=alter & sz=size(img)
if sz(3) eq 6 then img=abs(img)
if sz(3) eq 7 then img=double(img)
case scale of
  1: tv,img
  2: tvscl,alog10(img-min(img)+1)
  3: tvscl,abs(img)
  4: tvscl,sqrt(img-min(img))
  else: tvscl,img
endcase

;figure out display format
aa=strlen(strtrim(image(0),2)) > strlen(strtrim(max(img),2))
form="($,'x:',i4,' y:',i4,' z:',a"+strtrim(aa+2,2)+",a)" & cret=string("15b)
device,cursor_standard=24

ix=sz(1)/2 & iy=sz(2)/2 & hjkl=0
print,'move cursor to (0,0) OR click right button to exit'
print,'click left button to "save", middle button for <hjkl>'
while ix ne 0 or iy ne 0 do begin
  if hjkl eq 0 then cursor,ix,iy,/change,/dev
  if !err eq 1 then begin
    print,'' & hjkl=0
  endif
  if !err eq 2 or hjkl ne 0 then begin
    hjkl=1 & c1='' & c1=get_kbrd(1)
    case c1 of
      'h': ix=(ix-1)>0
      'j': iy=(iy-1)>0
      'k': iy=(iy+1)<(sz(2)-1)
      'l': ix=(ix+1)<(sz(1)-1)
      'g': begin
	c1='position -- '+strtrim(ix,2)+','+strtrim(iy,2)+' ; move to?'
	print,form="($,'"+c1+"')" & read,ix,iy
      end
      'q': hjkl=0
      else: print,'use keys <h,j,k,l> (& g) to navigate vi style; q to quit'
    endcase
  endif
  if hjkl ne 0 then tvcrs,ix,iy,/dev
  if (ix ge 0 and ix le sz(1)-1) and (iy ge 0 and iy le sz(2)-1) then print,form=form,ix,iy,strtrim(image(ix,iy),2),cret
  if !err eq 4 then begin & ix=0 & iy=0 & endif
endwhile

device,cursor_standard=34
print,''

return
end
