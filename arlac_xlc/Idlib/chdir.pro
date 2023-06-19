pro chdir,direc,len,nopro=nopro,notrail=notrail
;+
;procedure:	chdir
;		changes directory within the IDL environment and resets
;		the prompt to reflect the new directory path name
;		(use the procedure PROMPT to reset to IDL default)
;
;calling sequence:
;		chdir,dir[,len[,/nopro[,/notrail]]]
;
;parameters:	direc	new directory name (exactly as in UNIX)
;		len	maximum length of prompt
;
;keywords:	nopro	do not change present prompt
;		notrail	echo the entire path (default is to echo only the
;			trailing component)
;-

n1 = n_params(0)

if n1 eq 0 then begin
  print, 'Usage: chdir,destination,length,/nopro,/notrail'
  print, '  echo current directory path in IDL prompt'
  prompt & return
endif

cd,direc & spawn,'echo $cwd:t',c1 & c2 = c1(0)
if keyword_set(notrail) then begin
  spawn,'pwd',c1 & c2 = c1(0)
endif

l1 = strlen(c2) & if n1 eq 2 then sz = len else sz = l1 & l2 = l1-sz

c2 = strmid(c2,l2,sz) & c2 = '(' + c2 + ')IDL> '

if not keyword_set(nopro) then !prompt = c2

return
end
