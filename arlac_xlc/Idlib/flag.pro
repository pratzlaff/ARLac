pro flag,country,psroot=psroot
;+
;procedure	flag
;	make a flag
;
;parameters
;	country	[INPUT; required] name of country to make flag for
;		* set COUNTRY to 'help' to get a list of options
;
;keywords
;	psroot	[INPUT] root name of postscript file to dump image to
;		* if not set, no postscript file is made
;
;subroutines
;	CHAKRA
;	SETKOLOR
;
;history
;	vinay kashyap (2005)
;-

;	usage
ok='ok' & np=n_params() & nc=n_elements(country)
if np eq 0 then ok='Insufficient parameters' else $
 if nc eq 0 then ok='COUNTRY is undefined' else $
  if strpos(strlowcase(country),'help',0) ge 0 then ok='OPTIONS:'
if ok ne 'ok' then begin
  print,'Usage: flag,country,psroot=psroot'
  print,'  make image of a flag'
  if np ne 0 then message,ok,/informational
  if ok eq 'OPTIONS:' then begin
    opts=['afghanistan','algeria','argentina','australia','austria',$
	'bangladesh','bulgaria',$
	'chile',$
	'france',$
	'germany',$
	'hungary',$
	'india','mysore/karnataka','ireland/eire','italy',$
	'jamaica','japan',$
	'netherlands/holland/dutch',$
	'russia',$
	'scotland',$
	'switzerland',$
	'uk/britain','usa']
    print,opts
  endif
  return
endif

;	which country?
co=strlowcase(country)
if strpos(co,'ind') ge 0 then cf='india' else $
 if strpos(co,'afg') ge 0 then cf='afghanistan' else $
 if strpos(co,'alg') ge 0 then cf='algeria' else $
 if strpos(co,'argen') ge 0 then cf='argentina' else $
 if strpos(co,'austra') ge 0 or strpos(co,'oz') ge 0 then cf='australia' else $
 if strpos(co,'austri') ge 0 then cf='austria' else $
 if strpos(co,'ban') ge 0 then cf='bangladesh' else $
 if strpos(co,'bul') ge 0 then cf='bulgaria' else $
 if strpos(co,'chi') ge 0 then cf='chile' else $
 if strpos(co,'ire') ge 0 then cf='eire' else $
 if strpos(co,'fra') ge 0 then cf='france' else $
 if strpos(co,'germ') ge 0 then cf='germany' else $
 if strpos(co,'hun') ge 0 then cf='hungary' else $
 if strpos(co,'ital') ge 0 then cf='italy' else $
 if strpos(co,'jam') ge 0 then cf='jamaica' else $
 if strpos(co,'jap') ge 0 then cf='japan' else $
 if strpos(co,'kar') ge 0 or strpos(co,'mys') ge 0 then cf='karnataka' else $
 if strpos(co,'nethe') ge 0 or strpos(co,'holland') ge 0 or strpos(co,'dutch') ge 0 $
	then cf='netherlands' else $
 if strpos(co,'rus') ge 0 then cf='russia' else $
 if strpos(co,'sco') ge 0 then cf='scotland' else $
 if strpos(co,'swi') ge 0 then cf='switzerland' else $
 if strpos(co,'uk') ge 0 or strpos(co,'britain') ge 0 or strpos(co,'jack') ge 0 then cf='uk' else $
 if strpos(co,'usa') ge 0 then cf='usa' else $
 cf=co

;	set up plotting window
peasecolr
xmargin=!X.MARGIN & ymargin=!Y.MARGIN & pbackground=!P.BACKGROUND
!X.MARGIN=[0,0] & !Y.MARGIN=[0,0]
if keyword_set(psroot) then begin
  cc=strtrim(psroot[0],2) & if cc eq '' then cc='flag'
  outfile=cc+'_'+cf+'.ps' & ncopy=2
  DNAME=!D.NAME
  set_plot,'ps' & device,file=outfile,/landscape,/color
endif else begin
  ncopy=1
  !P.BACKGROUND=255
endelse

;	make the flag
for icopy=0,ncopy-1 do begin	;{for postscript, write twice, for duplex

 case cf of			;{for each country
   'afghanistan': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,3],yr=[0,1]
     polyfill,0+[0,1,1,0,0],[0,0,1,1,0],color=0
     setkolor,'#cc1100',91 & polyfill,1+[0,1,1,0,0],[0,0,1,1,0],color=91
     setkolor,'#007740',92 & polyfill,2+[0,1,1,0,0],[0,0,1,1,0],color=92
   end
   'algeria': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,2],yr=[0,1]
     setkolor,'#007740',91 & polyfill,[0,1,1,0,0],[0,0,1,1,0],color=91
     poaintsym,'moon',psize=20,/pfill,adent=0.1,phase=1.15,color=23 & plots,1,0.5,psym=8
     poaintsym,'starfish',psize=10,/pfill,angle=30,color=23 & plots,1.08,0.5,psym=8
   end
   'argentina': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,3]
     setkolor,'#66ccff',91
     polyfill,[0,1,1,0,0],[0,0,1,1,0],color=91
     polyfill,[0,1,1,0,0],2+[0,0,1,1,0],color=91
     poaintsym,'circle',/pfill
     plots,0.5,1.5,psym=8,color=43,symsize=14
   end
   'australia': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,40],yr=[-10,10]
     ;(union jack
     setkolor,'#220070',91 & setkolor,'#dd0011',92
     polyfill,[0,40,40,0,0],[-10,-10,10,10,-10],color=91
     polyfill,[0,0,20-2.4,20,20,2.4,0],[0,1.1,10,10,10-1.1,0,0],color=254
     polyfill,20-[0,0,20-2.4,20,20,2.4,0],[0,1.1,10,10,10-1.1,0,0],color=254
     polyfill,[0,1.6,8.4,8.4-1.6,0],[0,0,3.3,3.3,0],color=92
     polyfill,20-[0,1.6,8.4,8.4-1.6,0],[0,0,3.3,3.3,0],color=92
     polyfill,[0,1.6,8.4,8.4-1.6,0],10-[0,0,3.3,3.3,0],color=92
     polyfill,20-[0,1.6,8.4,8.4-1.6,0],10-[0,0,3.3,3.3,0],color=92
     polyfill,10+(3.4/2)*[-1,1,1,-1,-1],[0,0,10,10,0],color=254
     polyfill,[0,20,20,0,0],5+(3.4/2)*[-1,-1,1,1,-1],color=254
     polyfill,10+(2./2)*[-1,1,1,-1,-1],[0,0,10,10,0],color=92
     polyfill,[0,20,20,0,0],5+(2./2)*[-1,-1,1,1,-1],color=92
     ;)(southern cross
     poaintsym,'asterisk',npoint=14,/pfill,color=254,psize=10
     plots,[25,30,35,30],[1.5,6.5,2.7,-6.5],psym=8,symsize=1.3
     plots,10,-5.5,psym=8,symsize=2
     poaintsym,'starfish',/pfill,color=254,psize=5
     plots,32,-1,psym=8,symsize=1.4
     ;)
   end
   'austria': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,3]
     polyfill,[0,1,1,0,0],0+[0,0,1,1,0],color=22
     polyfill,[0,1,1,0,0],2+[0,0,1,1,0],color=22
   end
   'bangladesh': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,1]
     polyfill,[0,1,1,0,0],[0,0,1,1,0],color=31
     poaintsym,'circle',/pfill,color=22,psize=10
     plots,0.4,0.5,psym=8,symsize=3
   end
   'bulgaria': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,3]
     polyfill,[0,1,1,0,0],0+[0,0,1,1,0],color=22
     polyfill,[0,1,1,0,0],1+[0,0,1,1,0],color=34
   end
   'chile': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,3],yr=[0,2]
     setkolor,'#003388',91 & polyfill,[0,1,1,0,0],1+[0,0,1,1,0],color=91
     setkolor,'#cc2222',92 & polyfill,[0,3,3,0,0],0+[0,0,1,1,0],color=92
     poaintsym,'starfish',/pfill,color=254,psize=10
     plots,0.5,1.5,psym=8,symsize=3
   end
   'eire': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,3],yr=[0,1]
     polyfill,0+[0,1,1,0,0],[0,0,1,1,0],color=33
     polyfill,2+[0,1,1,0,0],[0,0,1,1,0],color=41
   end
   'france': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,3],yr=[0,1]
     setkolor,'#0055aa',91 & polyfill,0+[0,1,1,0,0],[0,0,1,1,0],color=91
     polyfill,2+[0,1,1,0,0],[0,0,1,1,0],color=25
   end
   'germany': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,3]
     setkolor,'#000000',91 & polyfill,[0,1,1,0,0],2+[0,0,1,1,0],color=91
     polyfill,[0,1,1,0,0],1+[0,0,1,1,0],color=23
     polyfill,[0,1,1,0,0],0+[0,0,1,1,0],color=43
   end
   'hungary': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,3]
     polyfill,[0,1,1,0,0],2+[0,0,1,1,0],color=22
     polyfill,[0,1,1,0,0],0+[0,0,1,1,0],color=33
   end
   'italy': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,3],yr=[0,1]
     setkolor,'#116644',91 & polyfill,0+[0,1,1,0,0],[0,0,1,1,0],color=91
     setkolor,'#bb1122',92 & polyfill,2+[0,1,1,0,0],[0,0,1,1,0],color=92
   end
   'jamaica': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,20],yr=[0,10]
     setkolor,'#000000',91 & polyfill,[0,20,20,0,0],[0,0,10,10,0],color=91
     setkolor,'#00aa11',92 & polyfill,[0,10,0,20,10,20,0],[10,5,0,0,5,10,10],color=92
     polyfill,[0,0,20-2.0,20,20,2.0,0],[0,1.0,10,10,10-1.0,0,0],color=4
     polyfill,20-[0,0,20-2.0,20,20,2.0,0],[0,1.0,10,10,10-1.0,0,0],color=4
   end
   'japan': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,1]
     poaintsym,'circle',/pfill,color=23,psize=10
     plots,0.5,0.5,psym=8,symsize=3
   end
   'switzerland': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,2],yr=[0,2]
     polyfill,[0,2,2,0,0],[0,0,2,2,0],color=2
     polyfill,1+(0.4/2)*[-1,1,1,-1,-1],1+(0.4/2)*3*[-1,-1,1,1,-1],color=254
     polyfill,1+(0.4/2)*3*[-1,1,1,-1,-1],1+(0.4/2)*[-1,-1,1,1,-1],color=254
   end
   'karnataka': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,2],yr=[0,2]
     polyfill,[0,2,2,0,0],0+[0,0,1,1,0],color=2
     polyfill,[0,2,2,0,0],1+[0,0,1,1,0],color=4
   end
   'netherlands': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,3]
     setkolor,'#305599',91 & polyfill,[0,1,1,0,0],0+[0,0,1,1,0],color=91
     setkolor,'#cc2233',92 & polyfill,[0,1,1,0,0],2+[0,0,1,1,0],color=92
   end
   'russia': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,3]
     polyfill,[0,1,1,0,0],0+[0,0,1,1,0],color=2
     polyfill,[0,1,1,0,0],1+[0,0,1,1,0],color=1
   end
   'scotland': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,20],yr=[0,10]
     setkolor,'#000088',91
     polyfill,[0,20,20,0,0],[0,0,10,10,0],color=91
     polyfill,[0,0,20-2.4,20,20,2.4,0],[0,1.1,10,10,10-1.1,0,0],color=254
     polyfill,20-[0,0,20-2.4,20,20,2.4,0],[0,1.1,10,10,10-1.1,0,0],color=254
   end
   'uk': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,20],yr=[0,10]
	;each quadrant is of size x:y::8.4:3.3
	;the red x is of horizontal width 1.6
	;the red + is of width 2
	;the white + is of width 3.4
     setkolor,'#220070',91 & setkolor,'#dd0011',92
     ;(blue ground
     polyfill,[0,20,20,0,0],[0,0,10,10,0],color=91
     ;)(white X
     polyfill,[0,0,20-2.4,20,20,2.4,0],[0,1.1,10,10,10-1.1,0,0],color=254
     polyfill,20-[0,0,20-2.4,20,20,2.4,0],[0,1.1,10,10,10-1.1,0,0],color=254
     ;)(red slants
     polyfill,[0,1.6,8.4,8.4-1.6,0],[0,0,3.3,3.3,0],color=92
     polyfill,20-[0,1.6,8.4,8.4-1.6,0],[0,0,3.3,3.3,0],color=92
     polyfill,[0,1.6,8.4,8.4-1.6,0],10-[0,0,3.3,3.3,0],color=92
     polyfill,20-[0,1.6,8.4,8.4-1.6,0],10-[0,0,3.3,3.3,0],color=92
     ;)(white +
     polyfill,10+(3.4/2)*[-1,1,1,-1,-1],[0,0,10,10,0],color=254
     polyfill,[0,20,20,0,0],5+(3.4/2)*[-1,-1,1,1,-1],color=254
     ;)(red +
     polyfill,10+(2./2)*[-1,1,1,-1,-1],[0,0,10,10,0],color=92
     polyfill,[0,20,20,0,0],5+(2./2)*[-1,-1,1,1,-1],color=92
     ;)
   end
   'usa': begin
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,1],yr=[0,13]
     polyfill,[0,1,1,0,0],13-[1,1,0,0,1],color=2
     polyfill,[0,1,1,0,0],11-[1,1,0,0,1],color=2
     polyfill,[0,1,1,0,0],09-[1,1,0,0,1],color=2
     polyfill,[0,1,1,0,0],07-[1,1,0,0,1],color=2
     polyfill,[0,1,1,0,0],05-[1,1,0,0,1],color=2
     polyfill,[0,1,1,0,0],03-[1,1,0,0,1],color=2
     polyfill,[0,1,1,0,0],01-[1,1,0,0,1],color=2
     polyfill,[0,0.4,0.4,0,0],[6,6,13,13,6],color=1
     poaintsym,'starfish',/pfill,color=250
     x6=findgen(6)*0.4/6 & x5=0.5*(x6[1]-x6[0])+x6[0:4]
     y6=findgen(5)*0.4/5 & y5=0.5*(y6[1]-y6[0])+y6[0:4]
     for i=0,4 do oplot,x6+0.03,(y6[i]+0.04)*7/0.4+6+fltarr(6),psym=8,symsize=5
     for i=0,3 do oplot,x5+0.03,(y5[i]+0.04)*7/0.4+6+fltarr(5),psym=8,symsize=5
   end
   else: begin				;(India
     if cf ne 'india' then $
	message,cf+': not understood',/informational
     psz=6 & if keyword_set(psroot) then psz=6
     pth=3 & if keyword_set(psroot) then pth=9
     plot,[0],/nodata,xstyle=5,ystyle=5,xr=[0,2.1],yr=[0,2.1]
     polyfill,[0,2.1,2.1,0,0],[1.4,1.4,2.1,2.1,1.4],col=81
     polyfill,[0,2.1,2.1,0,0],[0,0,0.7,0.7,0],col=31
     chakra,1,1.05,psize=psz,pthick=pth
   end					;India)
 endcase			;CF}

endfor				;I=0,NCOPY-1}

;	close plotting window
if keyword_set(psroot) then begin
  !P.BACKGROUND=pbackground
  device,/close & set_plot,DNAME
endif
!X.MARGIN=xmargin & !Y.MARGIN=ymargin

return
end
