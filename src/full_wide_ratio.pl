#! /usr/bin/perl

use strict;
use warnings;

use PDL;
use MyRDB 'rdb_cols';

my @wide = qw/ hrci_full_wide_erg.rdb hrcs_full_wide_erg.rdb /;
my @full = qw/ hrci_full_erg.rdb hrcs_full_erg.rdb /;

for my $j (0..$#wide) {

  my $fwide = $wide[$j];
  my $ffull = $full[$j];

  my ($ow, $fw) = rdb_cols($fwide, qw/ obsid flux/);
  my ($of, $ff) = rdb_cols($ffull, qw/ obsid flux/);

  $_ = pdl $_ for $ow, $fw, $of, $ff;

  for my $i (0..$ow->nelem-1) {
    my $ind = which( $of == $ow->at($i) );
    my $ratio = $fw->at($i) / $ff->index($ind)->at(0);
    printf("%d\t%f\n",
           $ow->at($i),
           $ratio,
          );
  }
}
