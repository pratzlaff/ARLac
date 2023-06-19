	PRO OCONTOUR,ARRAY,X,Y,LEVELS=LEVELS,COLOR=COLOR,MAX_VALUE=MAX_VALUE, $
		C_LINESTYLE=C_LINESTYLE
;+
; NAME:
;	OCONTOUR
; PURPOSE:
;	This procedure draws contour plots over existing plots.
; CATEGORY:
; CALLING SEQUENCE:
;	OCONTOUR, ARRAY
;	OCONTOUR, ARRAY, X, Y
; INPUT PARAMETERS:
;	ARRAY	= Two dimensional array to make contour plot of.
; OPTIONAL INPUT PARAMETERS:
;	X, Y	= Vectors along X and Y axes.
; OPTIONAL KEYWORD PARAMETERS:
;	COLOR	  = Color to use for drawing the contours.
;	LEVELS	  = Levels to use for drawing the contours.
;	MAX_VALUE = Maximum value to use for drawing the contours.  Pixels with
;		    values above MAX_VALUE will be ignored in drawing the
;		    contours.
;	C_LINESTYLE = Line style to use for drawing the contours.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	Array must be two-dimensional.  Dimensions of X and Y must match. 
; PROCEDURE:
;	The contour is done with XSTYLE=5, YSTYLE=5, XRANGE=!X.CRANGE,
;	YRANGE=!Y.CRANGE, and /NOERASE.
; MODIFICATION HISTORY:
;	William Thompson	Applied Research Corporation
;	May, 1988		8201 Corporate Drive
;				Landover, MD  20785
;
;	W.T.T., Mar 1991, modified for version 2.
;	W.T.T., Apr 1992, added LINESTYLE keyword.
;	W.T.T., Jun 1992, changed LINESTYLE to C_LINESTYLE.
;	William Thompson, December 1992, fixed problem with clipping region.
;-
;
	ON_ERROR,2
;
;  Check the number of parameters.
;
	IF (N_PARAMS() NE 1) AND (N_PARAMS() NE 3) THEN BEGIN
		PRINT,'*** OCONTOUR must be called with 1 or 3 parameters:'
		PRINT,'                    ARRAY, X, Y'
		RETURN
	ENDIF
;
;  Select the linestyle.
;
	IF N_ELEMENTS(C_LINESTYLE) NE 1 THEN C_LINESTYLE = !P.LINESTYLE
;
;  Get the current clip region.
;
	XCLIP = [!P.CLIP(0),!P.CLIP(2)]
	YCLIP = [!P.CLIP(1),!P.CLIP(3)]
	CLIP = CONVERT_COORD(XCLIP,YCLIP,/DEVICE,/TO_DATA)
	CLIP = CLIP(0:1,*)
	CLIP = CLIP(*)
;
;  Format the command needed to overplot the contour on the existing plot.
;
	COMMAND = "CONTOUR,ARRAY,XSTYLE=5,YSTYLE=5,XRANGE=!X.CRANGE,"	+ $
		"YRANGE=!Y.CRANGE,/NOERASE,TITLE='',CLIP=CLIP,"		+ $
		"C_LINESTYLE=C_LINESTYLE"
;
;  Add any optional parameters or keywords.
;
	IF N_PARAMS() EQ 3 THEN COMMAND = COMMAND + ",X,Y"
	IF N_ELEMENTS(COLOR)  NE 0 THEN COMMAND = COMMAND + ",COLOR=COLOR"
	IF N_ELEMENTS(LEVELS) NE 0 THEN COMMAND = COMMAND + ",LEVELS=LEVELS"
	IF N_ELEMENTS(MAX_VALUE) NE 0 THEN	$
		COMMAND = COMMAND + ",MAX_VALUE=MAX_VALUE"
;
;  Execute the command.
;
	TEST = EXECUTE(COMMAND)
;
	RETURN
	END
