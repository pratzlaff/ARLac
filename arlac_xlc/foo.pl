#! /usr/bin/perl -w
use strict;

use PDL;
use PDL::Graphics::PGPLOT;

use MyRDB qw( rdb_cols );

my $f = '/data/legs/rpete/flight/ARLac/final/flux_lc_bin=400.rdb';
my ($p, $r) = rdb_cols($f, qw/ phase rate /);

$_ = pdl $_ for $p, $r;

my ($ravg, $rsd) = stats($r);
my $i = which(abs($r - $ravg) < 3*$rsd);

points $p->index($i), $r->index($i), { border => 1 };
