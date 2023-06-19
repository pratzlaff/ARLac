function morse,line,dot=dot
;+
;function	morse
;		converts an alphabet string to Morse code and vice versa
;
;parameters:	line	input line, either in morse or english
;keywords:	dot	if set, forces english -> morse conversion
;			(if first character is . or -, input would be assumed
;			to be in morse, otherwise)
;-

n1 = n_params(0)
if n1 eq 0 then begin
  print, 'Usage: str = morse(line,/dot)'
  print, '  converts english to morse and vice versa'
  print, '' & print, 'type input for conversion' & line = '' & read,line
endif

;first decide if the input is english or morse by looking at the first character
str = ' ' & m2e = 1 & c1 = strmid(strtrim(line,2),0,1)
if c1 ne '.' and c1 ne '-' then m2e = 0
if keyword_set(dot) then begin
  m2e = 0 & print, 'assuming input is english'
endif

c1 = strlowcase(strtrim(line,2)) & l1 = strlen(c1) & il = 0 & iw = 0

if m2e then begin
  parser,c1,' ',wrds & iw = n_elements(wrds)
  for i=0,iw-1 do begin
    c2 = wrds(i)
    case c2 of
      '.-': c3 = 'A'
      '-...': c3 = 'B'
      '-.-.': c3 = 'C'
      '-..': c3 = 'D'
      '.': c3 = 'E'
      '..-.': c3 = 'F'
      '--.': c3 = 'G'
      '....': c3 = 'H'
      '..': c3 = 'I'
      '.---': c3 = 'J'
      '-.-': c3 = 'K'
      '.-..': c3 = 'L'
      '--': c3 = 'M'
      '-.': c3 = 'N'
      '---': c3 = 'O'
      '.--.': c3 = 'P'
      '--.-': c3 = 'Q'
      '.-.': c3 = 'R'
      '...': c3 = 'S'
      '-': c3 = 'T'
      '..-': c3 = 'U'
      '...-': c3 = 'V'
      '.--': c3 = 'W'
      '-..-': c3 = 'X'
      '-.--': c3 = 'Y'
      '--..': c3 = 'Z'
      '.--.-': c3 = "\'A"
      '.-.-': c3 = '\"A'
      '..-..': c3 = "\'E"
      '--.--': c3 = '\~N'
      '---.': c3 = '\"O'
      '..--': c3 = '\"U'
      '.----': c3 = '1'
      '..---': c3 = '2'
      '...--': c3 = '3'
      '....-': c3 = '4'
      '.....': c3 = '5'
      '-....': c3 = '6'
      '--...': c3 = '7'
      '---..': c3 = '8'
      '----.': c3 = '9'
      '-----': c3 = '0'
      '--..--': c3 = ','
      '.-.-.-': c3 = '.'
      '..--..': c3 = '?'
      '-.-.-.': c3 = ';'
      '---...': c3 = ':'
      '.----.': c3 = "'"
      '-....-': c3 = '-'
      '-..-.': c3 = '/'
      '-.--.-': c3 = '()'
      '..--.-': c3 = '_'
      else: c3 = c2
    endcase
    str = str + c3 + ' '
  endfor
endif

if not m2e then begin
  while il lt l1 do begin
    c2 = strmid(c1,il,1)
    if c2 eq '\' then begin
      il = il + 1 & c2 = strmid(c1,il,2) & il = il + 1
    endif
    case c2 of
      'a': c3 = '.-'
      'b': c3 = '-...'
      'c': c3 = '-.-.'
      'd': c3 = '-..'
      'e': c3 = '.'
      'f': c3 = '..-.'
      'g': c3 = '--.'
      'h': c3 = '....'
      'i': c3 = '..'
      'j': c3 = '.---'
      'k': c3 = '-.-'
      'l': c3 = '.-..'
      'm': c3 = '--'
      'n': c3 = '-.'
      'o': c3 = '---'
      'p': c3 = '.--.'
      'q': c3 = '--.-'
      'r': c3 = '.-.'
      's': c3 = '...'
      't': c3 = '-'
      'u': c3 = '..-'
      'v': c3 = '...-'
      'w': c3 = '.--'
      'x': c3 = '-..-'
      'y': c3 = '-.--'
      'z': c3 = '--..'
      "a'": c3 = '.--.-'
      "'a": c3 = '.--.-'
      'a"': c3 = '.-.-'
      '"a': c3 = '.-.-'
      "e'": c3 = '..-..'
      "'e": c3 = '..-..'
      'n~': c3 = '--.--'
      '~n': c3 = '--.--'
      'o"': c3 = '---.'
      '"o': c3 = '---.'
      'u"': c3 = '..--'
      '"u': c3 = '..--'
      '1': c3 = '.----'
      '2': c3 = '..---'
      '3': c3 = '...--'
      '4': c3 = '....-'
      '5': c3 = '.....'
      '6': c3 = '-....'
      '7': c3 = '--...'
      '8': c3 = '---..'
      '9': c3 = '----.'
      '0': c3 = '-----'
      ',': c3 = '--..--'
      '.': c3 = '.-.-.-'
      '?': c3 = '..--..'
      ';': c3 = '-.-.-.'
      ':': c3 = '---...'
      "'": c3 = '.----.'
      '-': c3 = '-....-'
      '/': c3 = '-..-.'
      '(': c3 = '-.--.-'
      ')': c3 = '-.--.-'
      '_': c3 = '..--.-'
      else: c3 = c2
    endcase
    str = str + c3 + ' '
    il = il + 1
  endwhile
endif

if n1 eq 0 then print, str

return,str
end
