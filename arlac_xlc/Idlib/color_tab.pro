pro color_tab
;+
;procedure:	color_tab
;
;usage:		color_tab
;
;procedure to change color tables interactively
;version 1 : 5/7/92 : vlk
;-

c='type hex number of color table'
ctab = 'z'
while ctab ne 'q' do begin
  print,form="($,a77,' ',a)",c,string("15b)
  ctab = get_kbrd(1)
  case ctab of
    '0': loadct,0,/silent
    '1': loadct,1,/silent
    '2': loadct,2,/silent
    '3': loadct,3,/silent
    '4': loadct,4,/silent
    '5': loadct,5,/silent
    '6': loadct,6,/silent
    '7': loadct,7,/silent
    '8': loadct,8,/silent
    '9': loadct,9,/silent
    'a': loadct,10,/silent
    'A': loadct,10,/silent
    'b': loadct,11,/silent
    'B': loadct,11,/silent
    'c': loadct,12,/silent
    'C': loadct,12,/silent
    'd': loadct,13,/silent
    'D': loadct,13,/silent
    'e': loadct,14,/silent
    'E': loadct,14,/silent
    'f': loadct,15,/silent
    'F': loadct,15,/silent
    'n': begin
       print, 'running palette may crash the system - beware!' & palette
     end
    '?': print, 'procedure to change color tables interactively'
    'h': print, '(0-f) to change, q to quit and n for palette'
    'H': print, '(0-f) to change, q to quit and n for palette'
    'q': begin
      print, form="($,a)",string("12b) & return
    end
    else: print, 'hexadecimal number system is 0-9,a,b,c,d,e,f'
  endcase
endwhile

return
end
