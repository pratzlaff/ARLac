;+
;   Name: file_exist
; 
;   Purpose: returns true(1) if any files match pattern=file
;	     false(0) if no files found
;
;   Input Parameters:
;      file - file, pathname or file filter to check
;
;   Optional Keyword Parameters
;      direct - set if want full check (slower) - use if might be an
;		empty directory you are looking for
;
;   History: written by slf, 11/30/91
;	4-Sep-92 (MDM) - Modified to handle an array of input files
;      23-sep-93 (slf) - make sure null file returns false
;			 (findfile count=1! when null requested)
;      17-Mar-94 (SLF) - use file_stat(/exist) for non wild card cases
;      April Fools'94 (DMZ) -- added check for :: in file name
;                              (file_stat doesn't work across DECNET)
;      31-May-94 (DMZ)      -- added check for VMS directory name input
;                              (file_stat doesn't seem to work on VMS
;                               dir names like '[ys.atest.soft]')
;      16-Aug-94 (DMZ)      -- added another VMS patch to handle
;                              case when user enters  a VMS subdirectory name
;                              without a file name.
;      6-Aug-97 (Zarro/GSFC) -- added check for nonstring input
;-
;

function file_exist, file, direct=direct

if datatype(file) ne 'STR' then return,0

file_sav=file            ;-- protect input

n = n_elements(file)
out = bytarr(n)

;-- check for VMS directory name only

if !version.os eq 'vms' then begin
 break_file,file,dsk,dir,name,ext  ;-- is this a directory name only?
 dcp=where( (strtrim(name,2) eq '') and (strtrim(dir,2) ne ''),dcount)
 if (dcount gt 0) then file(dcp)=file(dcp)+'*.*'  ;-- need to add wild chars
endif

wc=  where( (strpos(file,'*') ne -1) or (strpos(file,'::') ne -1),wccnt)
nowc=where((strpos(file,'*') eq -1) and (strpos(file,'::') eq -1),nowccnt)

if nowccnt gt 0 then out(nowc)=file_stat(file(nowc),/exist)
;
; now do wild card (file filter) logic
for i=0, wccnt-1 do begin
    case keyword_set(direct) of
	0:test=findfile(file(wc(i)),count=count)
	;
	;  if direct keyword set, can detect empty directories 
	;  
	1:begin
           filedelim=str_lastpos(file(i),'/')
           name=strmid(file(wc(i)),filedelim+1,strlen(file(wc(i)))-filedelim) 
           path=strmid(file(wc(i)),0,filedelim)
           files=findfile(path)
           found=where(name eq files)
           count = found(0) ge 0
	end
    endcase
    out(wc(i)) = count ne 0
end
;
out = out and (file ne '')
if (n eq 1) then out = out(0)	;turn it into a scalar

file=file_sav
return, out
end

