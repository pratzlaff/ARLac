pro pc2asec,pc,dist,asec
;converts an arc of length pc (in parsecs) to angle (in arcsec) as seen
;at a distance dist (given in parsecs).

if n_params(0) lt 3 then begin
  print, 'Usage: pc2asec,pc,dist,asec
  print, 'converts an arc (pc) at a given distance (pc) to subtended angle (sec)'
  return
endif

pc = float(pc) & rad = pc/dist & rad2deg,rad,deg & deg2sec,deg,asec

return
end
