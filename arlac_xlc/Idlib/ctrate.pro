function ctrate,times,ticks,rterr=rterr,tgrid=tgrid,mint=mint,maxt=maxt,$
	bint=bint,nbin=nbin,tstart=tstart,tstop=tstop,verbose=verbose,$
	_extra=e
;+
;function	ctrate
;	compute and return the light curve for a given set of photon
;	arrival times, taking into account known gaps in the data
;	collection
;
;syntax
;	lc=ctrate(times,ticks,rterr=rterr,tgrid=tgrid,mint=mint,maxt=maxt,$
;	bint=bint,nbin=nbin,tstart=tstart,tstop=tstop,verbose=verbose)
;
;parameters
;	times	[INPUT; required] photon arrival times
;	ticks	[OUTPUT; required] the mid-bin values at which the
;		binned count rate is returned
;
;keywords
;	rterr	[OUTPUT] 
;	tgrid	[OUTPUT] the time bin boundaries of the output light curve
;-

-----------------

return,lc
end
