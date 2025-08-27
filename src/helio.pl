#! /usr/bin/perl

use strict;
use warnings;

use Astro::FITS::CFITSIO;
use Data::Dumper;

use Astrolib 'helio_jd';
use Chandra::Tools::Common 'read_bintbl_cols';

@ARGV == 1 or die "Usage: $0 evtfile\n";
my $evt = shift;

my $hdr = Astro::FITS::CFITSIO::fits_read_header($evt.'[events]');

my $ra = $hdr->{'RA_TARG'} + 0.;
my $dec = $hdr->{'DEC_TARG'} + 0.;

my ($time) = read_bintbl_cols($evt, 'time', { extname => 'events' });
my $mjd = $time/86400 + $hdr->{'MJDREF'};
my $mjd_helio = helio_jd($mjd+0.5, $ra, $dec) - 0.5;
print+($mjd_helio-$mjd)->slice('0:3'),"\n";


