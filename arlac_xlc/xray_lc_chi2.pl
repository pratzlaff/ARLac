#! /usr/bin/perl -w
use strict;

=head1 NAME

template - A template for Perl programs.

=head1 SYNOPSIS

cp template newprog

=head1 DESCRIPTION

blah blah blah

=head1 OPTIONS

=over 4

=item --help

Show help and exit.

=item --version

Show version and exit.

=back

=head1 AUTHOR

Pete Ratzlaff E<lt>pratzlaff@cfa.harvard.eduE<gt> July 2005

=head1 SEE ALSO

perl(1).

=cut

my $version = '0.1';

use PDL;
use PDL::Graphics::PGPLOT;
use MyRDB;

use FindBin;
use Config;
use Carp;
require '../ARLac.pm';

use Getopt::Long;
my %default_opts = (
                    dev => '/xs',
		    lcbin => 'xray_lc.bin',
		    lcrdb => '/data/legs/rpete/flight/ARLac/revamp/hrci_400.rdb',
		    );
my %opts = %default_opts;
GetOptions(\%opts,
	   'help!', 'version!', 'debug!',
	   'lcbin=s', 'lcrdb=s',
           'bad!', 'flare!', 'dev=s',
	   ) or die "Try --help for more information.\n";
if ($opts{debug}) {
  $SIG{__WARN__} = \&Carp::cluck;
  $SIG{__DIE__} = \&Carp::confess;
}
$opts{help} and _help();
$opts{version} and _version();

my ($o, $phase, $flux, $fluxerr) = readrdb($opts{lcrdb});
my ($h1, $b1, $tgrid, $lc) = readbin($opts{lcbin});

#my ($fluxavg, $fluxsd) = $flux->stats;
#my $i = which(abs($flux-$fluxavg) < 3*$fluxsd);
#my $norm = $flux->index($i)->avg;

#$_ = $_->index($i)->sever for $ph, $flux, $flux_err;
#$norm = $flux->avg;

my $i = which(($phase > 0.2) & ($phase < 0.8));
my $norm = $flux->index($i)->median;

$_ *= $norm for @$lc;

my @chi2;

for my $i (0..$#{$h1}) {
  my $h1 = $h1->[$i];
  my $b1 = $b1->[$i];
  my $tgrid = $tgrid->[$i];
  my $lc = $lc->[$i];

  my $si = $tgrid->qsorti;
  $_ = $_->index($si)->sever for $tgrid, $lc;

  my $lci = interpol $phase, $tgrid, $lc;

  my $chi2 = sum(($flux - $lci)**2 / $fluxerr**2);
  push @chi2, $chi2;

=begin comment

#  print $h1,' ', $b1, "\n";
  if (abs($h1 - 1.01) < 1e-3) { # && abs($b1-0.95) < 1e-3) {
    points $phase, $flux;#, { border => 1 };
    hold;
    line $tgrid, $lc;
    release;
    <STDIN>;
  }

=cut

}

$h1 = pdl $h1;
$b1 = pdl $b1;
printf "h1=[%.1f,%.1f], b1=[%.1f, %.1f]\n", $h1->minmax, $b1->minmax;
my $chi2 = pdl \@chi2;

dev $opts{dev};#, 1, 2;
points $h1, $chi2->log10,
  {
   xtitle => '\fih\fn\d1\u',
   ytitle => '\filog\fn(\gx\u2\d)',
   border => 1,
  };
hold;

my @b1s = $b1->qsort->uniq->list;
my @ci = (2, 8, 7, 3, 11, 12);

for my $i (0..$#ci) {

  # early abort if there aren't enough uniq b1 values
  last if $i > $#b1s;

  my $index = which($b1 == $b1s[$i]);

  # just go to the largest uniq b1 value if there aren't enough colors
  $index = which($b1 == $b1s[-1]) if $i==$#ci;

  # FIXME: draw a legend

  points $h1->index($index), $chi2->index($index)->log10,
  {
   colour => $ci[$i],
  };
}

release;


exit 0;

sub _help {
  exec("$Config{installbin}/perldoc", '-F', $FindBin::Bin . '/' . $FindBin::RealScript);
}

sub _version {
  print $version,"\n";
  exit 0;
}

sub readbin {
  my $f = shift;

  open FH, '< ' . $f or die "could not open '$f' for reading: $!";

  my (@h1, @b1, @tgrid, @lc);

  while (my ($h1, $b1, $tgrid, $lc) = readlc(*FH{IO})) {
#  next unless abs($b1-1) < 1e-3;
    push @h1, $h1;
    push @b1, $b1;
    push @tgrid, $tgrid;
    push @lc, $lc;
  }

  close FH;

  return \(@h1, @b1, @tgrid, @lc);
}

sub readlc {

  my $fh = shift;

  my $hdr;

  my $nread = read($fh, $hdr, 12);
  if ($nread == 0) {
    return;
  }
  elsif ($nread != 12) {
    die "unexpected end of file while reading header";
  }

  my ($n, $h1, $b1) = unpack 'Vff', $hdr;

  my $tgrid = zeroes(float, $n);
  my $lc = $tgrid->copy;

  read($fh, ${$tgrid->get_dataref}, 4*$n) == 4*$n
    or warn("unexpected end of file while reading phases"), return;

  read($fh, ${$lc->get_dataref}, 4*$n) == 4*$n
    or warn("unexpected end of file while reading light curve"), return;

  $_->upd_data for $tgrid, $lc;

  return $h1, $b1, $tgrid, $lc;
}

sub readrdb {
  my $f = shift;
  my ($o, $phase, $flux, $fluxerr) = MyRDB::rdb_cols($f, 'obsid', 'phase', 'netflux', 'netflux_err');
  $_ = pdl $_ for $o, $phase, $flux, $fluxerr;

  if (!$opts{bad}) {
    my ($goodi, $badi) = ARLac::are_bad($o);
    warn sprintf("removing %d / %d \"bad\" data points\n", $badi->nelem, $o->nelem);
    $_ = $_->index($goodi) for $o, $phase, $flux, $fluxerr;
  }

  if (!$opts{flare}) {
    my ($goodi, $badi) = ARLac::are_flare($o);
    warn sprintf("removing %d / %d \"flare\" data points\n", $badi->nelem, $o->nelem);
    $_ = $_->index($goodi) for $o, $phase, $flux, $fluxerr;
  }

  return $o, $phase, $flux, $fluxerr;
}
