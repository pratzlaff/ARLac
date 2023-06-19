#! /bin/bash

source /usr/local/ciao/bin/ciao.sh

obsids=$(perl -le 'print join " ", qw/
22772
22773
22774
22775
22776
22777
22778
22779
22781
22782
22783
22784
22786
22787
22788
22790
/')
#obsids=$(perl -le 'print join " ", 22793..22799')
obsids='21742 22772 22790'

for o in $obsids
do
    evt2=$(ls /data/legs/rpete/data/ARLac/$o/tg_reprocess/hrcf${o}N???_evt2_dtffilt.fits)
    outfile=/data/legs/rpete/data/ARLac/$o/cell_output.fits

    echo celldetect infile="$evt2" outfile="$outfile" fixedcell=6 maxlogicalwindow=2048 cl+
    echo $outfile
    dmlist /data/legs/rpete/data/ARLac/$o/cell_output.fits'[col ra, dec]' data,raw
done

