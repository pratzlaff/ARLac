#! /usr/bin/perl

use strict;
use warnings;

use MyRDB;
use PDL;

use FindBin qw/ $RealBin /;
use lib $RealBin;

use ARLac;

my $f = shift;

open FH, '< '.$f;
while (<FH>) {
  if (/^#/) { print; }
  else {
    print $_, scalar(<FH>);
    last;
  }
}
close FH;

my @cols = MyRDB::rdb_col_names( $f );

my ( $obsid ) = MyRDB::rdb_cols( $f, 'obsid' );

my @data = MyRDB::rdb_cols( $f, @cols );

$obsid = pdl $obsid;

my ($goodi, $badi) = ARLac::are_bad($obsid);

my @goodi = $goodi->list;

@{$_} = @{$_}[ @goodi ] for @data;

for my $i (0..$#{$data[0]}) {
  print join("\t", map($_->[$i], @data)), "\n";
}

