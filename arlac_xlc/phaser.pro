function phaser,times,tform,period=period,mjd0=mjd0, _extra=e
;+
;function	phaser
;	return phases corresponding to input times for given ephemeris
;
;parameters
;	times	[INPUT; required] string scalar/array containing the
;		input times in format TFORM
;	tform	[INPUT] string representing the format in which TIMES
;		are given
;		* default: YYYY:DDD:HH:MM
;		* Y => Year, D => Day, H => Hour, M => Minute, S => Second,
;		  J => JD
;		* if Y is not specified, assumed to current year, etc.
;		* if "YY", assumed to be "19YY"
;
;keywords
;	period	[INPUT] period in [days]
;		* default=1.
;	mjd0	[INPUT] zero-point for phase calculation
;		* default is TODAY
;
;history
;	vinay kashyap (1999:12)
;-

return,phase
end
