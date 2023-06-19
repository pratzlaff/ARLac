pro getradec,line,ra,dec
;+
;pro getradec,line,ra,dec
;given a character string line, extracts the RA and Dec as arrays of 3 real
;numbers.  eg: consider the line
;  3:42:31.9           23:28:30.7
;this procedure returns ra = [ 3., 42.,31.9 ], dec = [23., 28., 30.7 ]
;-

ra = fltarr(3) & dec = ra & j = 0 & nchar = strlen(line)

ir = -indgen(6) - 1 & id = ir + ir(5) & i = -1

nextra: i = i + 1
c1 = strmid(line,i,1)
if ir(0) gt 0 then begin
  if ir(4) gt 0 and c1 eq ' ' then ir(5) = i-1
  if ir(3) gt 0 and ir(4) lt 0 then ir(4) = i
  if ir(2) gt 0 and ir(3) lt 0 and c1 eq ':' then ir(3) = i-1
  if ir(1) gt 0 and ir(2) lt 0 then ir(2) = i
  if c1 eq ':' and ir(1) lt 0 then ir(1) = i-1
endif
if ir(0) lt 0 and c1 ne ' ' then ir(0) = i
if ir(5) gt 0 then goto, nextdec
if i lt nchar then goto, nextra

nextdec: i = i + 1
c1 = strmid(line,i,1)
if id(0) gt 0 then begin
  if id(4) gt 0 and c1 eq ' ' then id(5) = i-1
  if id(3) gt 0 and id(4) lt 0 then id(4) = i
  if id(2) gt 0 and id(3) lt 0 and c1 eq ':' then id(3) = i-1
  if id(1) gt 0 and id(2) lt 0 then id(2) = i
  if c1 eq ':' and id(1) lt 0 then id(1) = i-1
endif
if id(0) lt 0 and c1 ne ' ' then id(0) = i
if id(5) gt 0 then goto, done
if i lt nchar then goto, nextdec

done:
ra(0)  = float(strmid(line,ir(0),ir(1)-ir(0)+1))
ra(1)  = float(strmid(line,ir(2),ir(3)-ir(2)+1))
ra(2)  = float(strmid(line,ir(4),ir(5)-ir(4)+1))
dec(0) = float(strmid(line,id(0),id(1)-id(0)+1))
dec(1) = float(strmid(line,id(2),id(3)-id(2)+1))
dec(2) = float(strmid(line,id(4),id(5)-id(4)+1))

return
end
