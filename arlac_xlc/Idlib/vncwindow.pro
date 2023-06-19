pro vncwindow,verbose=verbose
;+
;procedure	vncwindow
;	set up the display device for during virtual network connections
;
;syntax
;	vncwindow
;
;parameters 	NONE
;keywords
;	verbose	[INPUT] controls chatter
;
;history
;	vinay kashyap (May04)
;-

device,true_color=24,decomposed=0
loadct,3 & peasecolr,verbose=verbose

return
end
