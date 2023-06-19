pro length,filename,nlines
;+
;pro length,filename,nlines
;obtains the number of lines in the file 'filename'
;-

nlines = 0 & openr,u,filename,/get_lun & c1 = ''
while (not eof(u)) do begin
  readf,u,c1 & nlines = nlines + 1
endwhile
close,u & free_lun,u

return
end
