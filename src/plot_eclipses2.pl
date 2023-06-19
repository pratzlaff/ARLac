#! /usr/bin/perl

use strict;
use warnings;

use ARLac;
use PDL;
use PDL::Graphics::PGPLOT;
use MyRDB 'rdb_cols';
use Astro 'ymd2jd';
use PGPLOT;
use Carp;

use Getopt::Long;
my %default_opts = (
		    pmodel => 1,
		    dev => '/xs',
		   );
my %opts = %default_opts;
GetOptions(\%opts,
           'help!', 'version!', 'debug!',
	   'dev=s', 'model=s', 'pmodel!', 'mfile=s',
           ) or die "Try --help for more information.\n";
if ($opts{debug}) {
  $SIG{__WARN__} = \&Carp::cluck;
  $SIG{__DIE__} = \&Carp::confess;
}


my $ifile = './collected/hrci_400_ph_nobad.rdb';
my $sfile = './collected/hrcs_400_ph_nobad.rdb';

my ($rjdi, $fluxi, $erri, $oi) = rdb_cols( $ifile, qw/ rjd flux fluxerr obsid / );
my ($rjds, $fluxs, $errs, $os) = rdb_cols( $sfile, qw/ rjd flux fluxerr obsid / );

my $obsid = [ @$oi, @$os ];
my $rjd = [ @$rjdi, @$rjds ];
my $flux = [ @$fluxi, @$fluxs ];
my $err = [ @$erri, @$errs ];

$_ = pdl( $_ ) for $rjd, $flux, $err, $obsid;

my $sorti = $rjd->qsorti;

$_ = $_->index($sorti) for $rjd, $flux, $err, $obsid;

my $jd = $rjd + 2400000;
my $year = 1999 + ($jd - ymd2jd(1999,1,1)) / 365.2424;

my $phase = ARLac::phase( $rjd + 2400000 );

my $phasenorm = phasenorm( $phase );

my $mini = which(
	      ( $phasenorm->slice('1:-1') < .1) &
	      ( $phasenorm->slice('0:-2') > .9) &
	      1
	      );

# force the first set of HRC-I observations to be included
#$mini = pdl(0, $mini->list, which($obsid==17351)->at(0))->qsort; # force obsid 17351
$mini = pdl(0, $mini->list);

pgopen($opts{dev}) or die;
my ($subx, $suby) = (1, 9);

pgsubp($subx, $suby);

my $nplots = 0;

for my $i ($mini->list) {

  my $obsid = $obsid->at($i);

  next if
    which(
	  ( $obsid - pdl(5993, 9682, 13182) ) == 0
	 )->nelem;

  print $obsid,"\n";

  ++$nplots;

  my $index = which( abs($rjd-$rjd->at($i)) < .3 );

  my ($phase_e, $flux_e, $err_e) = (
			$phasenorm->index($index)->copy,
			$flux->index($index)->copy,
			$err->index($index)->copy,
			);
  (my $tmp = $phase_e->index(which($phase_e > .5))) -= 1;

  pgpage();
  pgsch(5);
  pgscf(1);
  pgslw(3);

  pgsvp(.2, .8, 0, 1);
  pgswin(-.14, .14, 0, .1);

  my ($xopt, $yopt) = ('BCST') x 2;

  my ($xlabel, $ylabel) = ('') x 2;

  if (($nplots % ($subx * $suby)) == int($suby / 2)) {
    $yopt = 'BCNST';
    $ylabel = 'photons / sec / cm\u2\d';
    $xopt = 'BCNST';
    $xlabel = '\gf';
  }

  if (($nplots % ($subx * $suby)) == int($suby / 2)+1) {
  }

  # FIXME - doesn't account for skipped obsids
  if (($nplots % ($subx * $suby)) == 0 or $i == $mini->at(-1)) {
  }

  pgbox($xopt, 0, 0, $yopt, 0, 0);
  pgpt($phase_e->nelem, $phase_e->float->get_dataref, $flux_e->float->get_dataref, 17);
  pgerrb(6, $err_e->nelem, $phase_e->float->get_dataref, $flux_e->float->get_dataref, $err_e->float->get_dataref, 0);

  pgptxt(-.13, 0.02, 0, 0, sprintf("%.2f", $year->at($i)));

  if ($ylabel) {
    pglab('', $ylabel, '');
  }

  if ($xlabel) {
    pgptxt(0, .02, 0, .5, $xlabel);
  }

  # points $phase_e, $flux_e,
  #   {
  #    xrange => [-.15, .15 ],
  #    yrange => [.03, .15 ],
  #    border => 1,
  #    title => sprintf("ObsID: %d (%.1f)",
  # 		      $obsid->at($i),
  # 		      $year->at($i),
  # 		      ),
  #   };

  plot_model($phasenorm, $flux) if $opts{pmodel};
}

pgclos();


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
