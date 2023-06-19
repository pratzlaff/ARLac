pro behr_tblprior,drawfil,outroot,xgrid,$
	nbin=nbin,xmin=xmin,xmax=xmax,xbin=xbin,$
	verbose=verbose, _extra=e
;+
;procedure	behr_tblprior
;	convert MCMC draws output from BEHR into
;	tabulated posterior density functions that
;	also can be used as table priors going forward.
;
;parameters
;	drawfil	[INPUT; required] name of file containing the MCMC draws
;		* contains NSIM rows of {lam_S,lam_H} drawn from the
;		  posterior
;	outroot	[INPUT; required] root name to place the output
;		probability density in
;		* two files will be created, OUTROOT_[sh].txt
;		* format:
;		  line 1: number of elements in the arrays
;		  line 2: column labels, usually ignored,
;		  	  of the form "lamS pr_lamS"
;		  lines 3-EOF: two columns of {x,Pr(x)}
;	xgrid	[I/O] the mid-bin values of the grid on which the
;		probability density is calculated
;		* if ill defined or is scalar on input, will be
;		  overwritten based on array calculated using
;		  keywords NBIN,XMIN,XMAX,XBIN on output
;		* if well-defined on input (array with at least 2
;		  elements, min>0, in ascending order), uses that
;		  as the grid
;
;keywords
;	nbin	[INPUT; default=200] if set, makes an output array
;		with NBIN bins
;		* overridden by [XMIN,XMAX,XBIN]
;	xmin	[INPUT] minimum value of grid
;		* if not given, 
;-

return
end
