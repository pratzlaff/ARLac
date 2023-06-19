#! /usr/bin/perl

use strict;
use warnings;

use ARLac;
use PDL;
use PDL::Graphics::PGPLOT;
use MyRDB 'rdb_cols';
use Astro 'ymd2jd';
use PGPLOT;

my %opts = (
	    pmodel => 1,
#	    dev => 'eclipses.ps/ps',
	    dev => '/xs',
	   );


my $ifile = './collected/hrci_400_ph_nobad.rdb';
my $sfile = './collected/hrcs_400_ph_nobad.rdb';

my ($rjdi, $fluxi, $oi) = rdb_cols( $ifile, qw/ rjd flux obsid / );
my ($rjds, $fluxs, $os) = rdb_cols( $sfile, qw/ rjd flux obsid / );

my $obsid = [ @$oi, @$os ];
my $rjd = [ @$rjdi, @$rjds ];
my $flux = [ @$fluxi, @$fluxs ];
my $det = 

$_ = pdl( $_ ) for $rjd, $flux, $obsid;

my $sorti = $rjd->qsorti;

$_ = $_->index($sorti) for $rjd, $flux, $obsid;

my $jd = $rjd + 2400000;
my $year = 1999 + ($jd - ymd2jd(1999,1,1)) / 365.2424;

my $phase = ARLac::phase( $rjd + 2400000 );

my $phasenorm = phasenorm( $phase );

my $mini = which(
	      ( $phasenorm->slice('1:-1') < .1) &
	      ( $phasenorm->slice('0:-2') > .9)
	      );

dev $opts{dev}, 2, 3, { hardlw => 2, hardch => 2 };

for my $i ($mini->list) {

  my $index = which( abs($rjd-$rjd->at($i)) < .3 );

  my ($phase_e, $flux_e) = (
			$phasenorm->index($index)->copy,
			$flux->index($index)->copy,
			);
  (my $tmp = $phase_e->index(which($phase_e > .5))) -= 1;
  points $phase_e, $flux_e,
    {
     xrange => [-.15, .15 ],
     yrange => [.03, .15 ],
     border => 1,
     title => sprintf("ObsID: %d (%.1f)",
		      $obsid->at($i),
		      $year->at($i),
		      ),
    };

  plot_model($phasenorm, $flux) if $opts{pmodel};
}


sub phasenorm {
  my $phasenorm = $phase - $phase->long;

  my $negind = which($phasenorm < 0);
  (my $tmp = $phasenorm->index($negind)) += 1;

  return $phasenorm;
}

sub plot_model {

  my ($phase, $flux) = @_;

  my $i = which(($phase > 0.1) &  ($phase < 0.9));
  $_ = $_->index($i) for $flux, $phase;

#  my ($ph, $best, @others) = model_bands();
  my ($ph, $best, @others) = ARLac::models();

  my ($fluxavg, $fluxsd) = ($flux->stats)[0,1];
#  my $i = which(abs($flux-$fluxavg) < 3*$fluxsd);
  my $norm = $flux->median;

  $norm = $opts{norm} if exists $opts{norm};

  print "model normalization = $norm\n";

  $_ *= $norm for $best, @others;

  $i = which($ph < 0.5);
  if ($i->nelem) {
    $ph = $ph->append($ph->index($i)+1.0);
    $_ = $_->append($_->index($i)) for $best, @others;
  }

  $i = which(($ph > 0.5) &  ($ph < 1.0));
  if ($i->nelem) {
    $ph = $ph->append($ph->index($i)-1.0);
    $_ = $_->append($_->index($i)) for $best, @others;
  }

  $i = $ph->qsorti;
  $_ = $_->index($i) for $ph, $best, @others;

  pgline($ph->nelem,
	 $ph->float->get_dataref,
	 $best->float->get_dataref
	);

  pgsave();
  pgsls(2);
  pgline($ph->nelem,
	 $ph->float->get_dataref,
	 $_->float->get_dataref
	) for @others;
  pgunsa();
}

sub read_models {
  my $f = shift;
  my $n = 102;

  open FH, '< '.$f or die "could not open $f: $!";
  # phases first
  my $phase = zeroes(float, $n);
  sysread(FH, ${ $phase->get_dataref }, $n * 4) == $n * 4 or die;
  $phase->upd_data;
  $phase->bswap4 if isbigendian();

  # they are off by 0.5
  $phase += 0.5;
  $phase->where($phase>1) -= 1.0;
  my $si = $phase->qsorti;

  # models are lc_{01,02,05,10,15,20,40}
  my @p = qw( 01 02 05 10 15 20 40 );

  my %lc;
  for my $p (@p) {
    $lc{$p} = zeroes(float, $n);
    sysread(FH, ${ $lc{$p}->get_dataref }, $n * 4) == $n * 4 or die;
    $lc{$p}->upd_data;
    $lc{$p}->bswap4 if isbigendian();
  }

  $_ = $_->index($si) for $phase, values %lc;

  return $phase, %lc;

}
