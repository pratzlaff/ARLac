datadir=/data/legs/rpete/data/ARLac

[[ `hostname` = @(milagro|legs) ]] &&
    perl=perl ||
    perl='/proj/axaf/bin/perl'

obsids()
{
    obsids=$(perl -I./src -MARLac -le 'print join(" ", ARLac::obsids())')
    obsids="28406 $(seq 28408 28426)"
    echo $obsids
}

hrci_obsids()
{
    $perl -I./src -MARLac -le 'print join(" ", ARLac::hrci_obsids())'
}

hrcs_obsids()
{
    $perl -I./src -MARLac -le 'print join(" ", ARLac::hrcs_obsids())'
}

instruments()
{
    local obsid="$1"
    local f=$(ls $datadir/"$obsid"/tg_reprocess/*_evt2.fits 2>/dev/null)
    echo $(detnam "$f")/$(grating "$f")
}

detnam()
{
    local evt2="$1"
    punlearn dmkeypar
    dmkeypar "$evt2" detnam echo+
}

grating()
{
    local evt2="$1"
    punlearn dmkeypar
    dmkeypar "$evt2" grating echo+
}

file_from_obsid()
{
    local obsid="$1"
    local subdir="$2"
    local ftype="$3"
    ls $datadir/"$obsid"/$subdir/*_"${ftype}".fits* 2>/dev/null | tail -1
}

dtf1_file()
{
    file_from_obsid "$1" primary dtf1
}

evt2_bin()
{
    local evt2="$1"
    local outdir="$2"
    local bin="$3"

    local dir=`dirname "$evt2"`
    local i=0
    local obsid=$(dmkeypar "$evt2" obs_id echo+)
    local dtf1=$(dtf1_file "$obsid")

    mkdir -p "$outdir"

    punlearn dmcopy

    : ${perl:='perl'}
    $perl /data/legs/rpete/flight/xcal/src/bintimes.pl "$evt2" "$bin" |
    while read start stop elapsed
    do
	echo $start $stop $elapsed
	local outevt2="$outdir/evt2_"$(printf "%02d" $i)'.fits'
	local outdtfstat="$outdir/dtfstat_"$(printf "%02d" $i)'.fits'
	dmcopy "$evt2""[time=$start:$stop]" "$outevt2" clobber=yes

	instruments $obsid | grep -qi hrc && {
	    punlearn hrc_dtfstats
	    hrc_dtfstats \
		infile="$dtf1" \
		outfile="$outdtfstat" \
		gtifile="$outevt2" \
		clobber+

	    local ontime=$(dmkeypar "$outevt2" ontime echo+)
	    local dtcor=$(dmlist "$outdtfstat"'[col dtcor]' data,clean | tail -1)
	    local exposure=$(perl -le "print $ontime*$dtcor")

	    dmhedit "$outevt2" filelist="" op=add key=livetime value=$exposure
	    dmhedit "$outevt2" filelist="" op=add key=exposure value=$exposure
	    dmhedit "$outevt2" filelist="" op=add key=dtcor value=$dtcor

	}

	((i++))
	[[ $i > 99 ]] && { echo "stopping with i=$i" 1>&2; return 1; }

    done
}
