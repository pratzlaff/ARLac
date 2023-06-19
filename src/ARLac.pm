package ARLac;
use strict;

use PDL;
use Astrolib qw/ helio_jd /;
use Chandra::Tools::Common qw( check_status read_bintbl_cols );
use Astro::FITS::CFITSIO;
use Astro::WCS::LibWCS;
use Math::Trig 'pi';

use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK );

require Exporter;

$VERSION = '0.01';

@ISA = qw( Exporter );

@EXPORT = qw( );
@EXPORT_OK = qw(
		 bad
		 ephemeris
		 phase
		 ephemeris_lu
		 phase_lu
		 ephemeris_rodono
		 phase_rodono
		 ephemeris_cester
		 ephemeris_siviero
		 phase_siviero1
		 phase_siviero3
		 bad
		 is_bad
		 are_bad
		 flare
		 is_flare
		 are_flare
		 ra
		 dec
		 obsids
		 hrcs_obsids
		 hrci_obsids
		 split_array
		);

# look at 5090, 5091, 5092, 5114
sub bad {
  my @bad = qw/
            2382
	    2448
	    2636
	    2657
	    4343
	    4322
	    5100
	    5121
	    6040
	    6019
	    6496
	    6517
	    8339
	    9680
	    10620
	    11929
	    13087
	    14297
	    15449
	    16416
	    17349
	    18385
	    19813
	    20704
	    /;

  push @bad, 62507;
  return @bad;
}

sub flare {
  return

    1332..1336,
    1385,
#    2624,
    2345..2364,
    5979..5999,
    11899..11909,
    13182,
    13265, 13048..13067,
    18387..18407,
    19815..19835,

    2445..2451,
    2658..2666,
    6477..6480,
    11910..11930,
    16397..16417,
    19794..19814,
    21741,
    21742..21761,
    22772..22792,
    22751..22759,
    qw/

	   /;
}

{
  my $bad; # pdl with bad obsids
  sub is_bad {

    my $obsid = shift;

    if (! defined $bad) {
      $bad = long bad();
    }

    return which($bad == $obsid)->nelem;
  }

}

sub are_bad {
  my $o = shift;
  my $mask = ones(byte, $o->nelem);

  for my $oo ($o->qsort->uniq->list) {
    if (is_bad($oo)) {
      my $ind = which($o == $oo);
      (my $tmp = $mask->index($ind)) .= 0;
    }
  }

  return wantarray ? which_both($mask) : which($mask);
}

{
  my $flare; # pdl with bad obsids
  sub is_flare {

    my $obsid = shift;

    if (! defined $flare) {
      $flare = long flare();
    }

    return which($flare == $obsid)->nelem;
  }

}

sub are_flare {
  my $o = shift;
  my $mask = ones(byte, $o->nelem);

  for my $oo ($o->qsort->uniq->list) {
    if (is_flare($oo)) {
      my $ind = which($o == $oo);
      (my $tmp = $mask->index($ind)) .= 0;
    }
  }

  return wantarray ? which_both($mask) : which($mask);
}

#
#
#   62505-6 have no sources
#
my @hrci_obsids = (
		   1283..1289, 1294..1295, # Aug 1999
		   1319..1382, 62507, 1385, # Oct 1999
		   1484..1504,		    # Dec 1999
		   996, 2345..2364,	    # Dec 2000
		   2604..2624,		    # Jan 2002
		   4290..4310,		    # Feb 2003
		   5060..5062,		    # Sept 2004
		   5063..5080, 6133..6135,  # Nov 2004
		   5979..5989,		    # Sept 2005
		   5996, 5997,		    # Oct 2005
		   5990..5995, 5998..5999,  # Oct 2005
		   6519..6539,		    # Sept 2006
		   8298..8318,		    # Sept 2007
		   9684..9685,		    # July 2008
		   9640..9660,		    # Sept 2008
		   10578..10598,	    # Sept 2009
		   11889..11909,	    # Sept 2010
		   13182,		    # Dec 2010
		   13265, 13048..13067,	    # Sept 2011
		   14299..14319,	    # Sept 2012
		   15409..15429,	    # Sept 2013
		   16376..16396,	    # Sept 2014
		   17351..17371,	    # Sept 2015
		   18408,		    # March 2016
		   18387..18407,	    # Sept 2016
		   19836,		    # April 2017
		   19815..19835,	    # Sept 2017
		   20684,		    # 2018-04-09
		   20663..20683,	    # 2018-09-17
		   21783,		    # 2018-12-26
		   21762..21782,	    # 2019-04-08
		   21742..21761,	    # 2019-09-03
		   22854,		    # 2019-10-18
		   22772..22792,	    # 2020-03-23
		   24644,		    # 2020-09-29
		   22751..22771,	    # 2020-11-02
		   24525..24545,	    # 2021-04-04
		   24546..24566,	    # 2021-09-08 (AO-22)
		   #25571..25591,	    # ????-??-?? (AO-23)
		   #25593..25613,	    # ????-??-?? (AO-23)
		  );

my @hrcs_obsids = (
		   998, 2366..2385,  # Dec 2000
		   997, 2432..2451,  # May 2001
		   2625..2645,	     # Jan 2002
		   2646..2666,	     # Aug 2002
		   4332..4352,	     # Feb 2003
		   4311..4331,	     # Sept 2003
		   5081..5101,	     # Feb 2004
		   5102..5122,	     # Nov 2004
		   6021..6041,	     # Feb 2005
		   6000..6020,	     # Sept 2005
		   6477..6497,	     # Mar 2006
		   6498..6518,	     # Sept 2006
		   8320..8340,	     # Sept 2007
		   9682..9683,	     # July 2008
		   9661..9681,	     # Sept 2008
		   10601..10621,     # Sept 2009
		   11910..11930,     # Sept 2010
		   13068..13088,     # Sept 2011
		   14278..14298,     # Sept 2012
		   15430..15450,     # Sept 2013
		   16397..16417,     # Sept 2014
		   17330..17350,     # Oct 2015
		   18366..18386,     # Sept 2016
		   19794..19814,     # Sept 2017
		   20686..20704,     # 2018-09-04
		   20685, 20705,     # 2018-09-10
		   21741,            # 2019-09-03
		   22793..22799,     # 2020-03-04
		   25592,            # 2021-09-24
		  );

my @_ra = (22, 8, 40.8180);
my @_dec = (45, 44, 32.116);

sub phase     { return phase_rodono(@_); }
sub ephemeris { return ephemeris_rodono(@_); }

# input JD, output phase
sub phase_lu {
  my $jd = shift;
  my $hjd = helio_jd($jd-2400000, ra(), dec())+2400000;

  my ($minimum, $period) = ephemeris_lu();

  # from Ye Lu, et al 2012
  my $phase = ($hjd - $minimum) / $period;
  $phase +=
    (
      + 0.119
      - 8.68e-6 * $phase
      - 2.11e-9 * $phase * $phase
      + 0.0362 * sin( pi / 180 * ( .0384 * $phase - 0.71 ) )
    ) / $period;

  return ($phase, $hjd) if wantarray;
  return $phase;
}

sub ephemeris_lu {

  # from Ye Lu, et al 2012

  my $minima = 2451745.58650;
  my $period = 1.98318608;

  return ($minima, $period);
}

sub phase_rodono {
  my $jd = shift;
  my $hjd = helio_jd($jd-2400000, ra(), dec())+2400000;

  my ($minimum, $period) = ephemeris_rodono();

  return ( ($hjd-$minimum)/$period, $hjd ) if wantarray;
  return 1/$period * ($hjd-$minimum);
}

sub ephemeris_rodono {
  # old
  # HJD = 2445611.6290 + 1.98316E
  #

  #
  # new ephemeris from Rodono paper (1999)
  # HJD = 2450692.5174 + 1.983188E
  #

  my $minima = 2450692.5174;
  my $period = 1.983188;

  return ($minima, $period);
}

sub phase_siviero1 {
  my $jd = shift;
  my $hjd = helio_jd($jd-2400000, ra(), dec())+2400000;

  my ($minimum, $period) = ephemeris_siviero();

  return ( ($hjd-$minimum)/$period, $hjd ) if wantarray;
  return 1/$period * ($hjd-$minimum);
}

# input JD, output phase
sub phase_siviero3 {
  my $jd = shift;
  my $hjd = helio_jd($jd-2400000, ra(), dec())+2400000;

  my ($minimum, $period) = ephemeris_cester();

  my $phase = ($hjd - $minimum) / $period;
  $phase +=
    (
      -0.000022 * $hjd +
      + 0.015 * sin( 4 * pi * ( $hjd - 2418293) / 14610 ) + 53.682
    ) / $period;

  return ($phase, $hjd) if wantarray;
  return $phase;
}

sub ephemeris_siviero {

  #
  # from Siviero, et al 2006
  # HJD = 2451745.58650 + 1.98318608E
  #

  my $minima = 2451745.58650;
  my $period = 1.98318608;

  return ($minima, $period);
}

sub ephemeris_cester {

  #
  # from Cester 1967
  # HJD = 2426624.3687 + 1.983223E
  #

  my $minima = 2426624.3687;
  my $period = 1.983223;

  return ($minima, $period);
}

sub models {
  my $mdir = '/data/legs/rpete/flight/ARLac/models';

  # my @s = qw/
  # 	      0.15_1.70_0.38
  # 	      0.15_0.01_0.38
  # 	      0.15_3.00_0.38
  # 	      /;
  my @s = qw/
  	      1.30_1.30_0.44
  	      0.01_0.01_0.44
  	      2.50_2.50_0.44
  	      /;
  # my @s = qw/
  # 	      0.15_1.70_0.38
  # 	      0.000000_1.70_0.38
  # 	      0.30_1.70_0.38
  # 	      /;

  my ($phase, @m);

  for my $s (@s) {
    my $f = "$mdir/$s.rdb";

    my ($p, $i) = MyRDB::rdb_cols($f, qw/ phase intensity /);
    $_ = pdl $_ for $p, $i;

    $phase = $p unless defined $phase;
    which($p != $phase)->nelem and die $f;

    push @m, $i;
  }

  return $phase, @m;
}

sub ra {
  return 15 * ($_ra[0] + $_ra[1]/60 + $_ra[2]/3600);
}

sub dec {
  return $_dec[0] + $_dec[1]/60 + $_dec[2]/3600;
}

sub hrcs_obsids {
  return @hrcs_obsids;
}

sub hrci_obsids {
  return @hrci_obsids;
}

sub obsids {
  my @obsids = ( hrcs_obsids(), hrci_obsids() );
  return( @obsids ) unless @_;

  my ($s1, $s2) = @_;
  die if $s1 < 1 or $s2 < $s1;

  my @split = split_array($s2, @obsids);
  my @out = @split >= $s1 ? @{ $split[$s1-1] } : ();
#  use Data::Dumper;
#  print Dumper \@out;
  return @out;
}

sub split_array_old {
  my ($n, @a) = @_;

  my $length = int(@a / $n);
  $length += 1 if @a % $n;

  my @out;
  while (my @seg = splice @a, 0, $length) { push @out, \@seg }
  return @out;
}

sub split_array {
  my ($n, @a) = @_;

  my $n_each = int(@a / $n);
  my $mod = +(@a % $n);

  my @out;

  # the first $mod subarrays get an extra item
  for my $i (1..$mod) {
    push @out, [ splice @a, 0, $n_each+1 ];
  }

  for my $i ($mod+1..$n) {
    push @out, [ splice @a, 0, $n_each ];
  }

  return @out;
}

# return AR Lac source X, Y coordinates in a event list
sub src_xy {
  my $evtfile = shift;

  my $ra = ra();
  my $dec = dec();

  my $status = 0;
  my $fptr = Astro::FITS::CFITSIO::open_file($evtfile.'[events]',Astro::FITS::CFITSIO::READONLY(),$status);

  my ($xcolnum, $ycolnum, $hdr);
  $fptr->get_colnum(0,'x',$xcolnum,$status);
  $fptr->get_colnum(0,'y',$ycolnum,$status);
  $fptr->get_table_wcs_keys($xcolnum,$ycolnum,$hdr,$status);
  $fptr->close_file($status);
  check_status($status) or die $evtfile;

  my ($xpix, $ypix, $offscale);
  my $wcs = Astro::WCS::LibWCS::wcsinit($hdr);
  $wcs->wcs2pix($ra,$dec,$xpix,$ypix,$offscale);
  $wcs->free;

  return $xpix, $ypix, $offscale;
}

# returns row in celldetect output file is closest to the expected position
# of AR Lac in an event list
sub which_cellrow {

  my ($evtfile, $cellfile) = @_;

  my ($x, $y) = read_bintbl_cols($cellfile, 'x', 'y', { extname => 'srclist'})
    or die $cellfile;

  my ($srcx, $srcy) = src_xy($evtfile);

  my $min_index = (($x - $srcx)**2 + ($y - $srcy)**2)->minimum_ind;

  return $min_index + 1;
}

1; # return true

=head1 NAME

ARLac - routines for AR Lac data analysis

=head1 SYNOPSIS

	use ARLac;

=head1 DESCRIPTION

blah blah

=head1 ROUTINES

=over 4

=item ra( ), dec( )

Return right ascension and declination, in degrees.

=item obsids( )

Return Chandra obsids of AR Lac observations.

=item phase( )

	$phase = phase( $jd );
	( $phase, $hjd ) = phase( $jd );

=item ephemeris( )

	( $minimum, $period ) = ephemeris();

C<$minimum> is JD.

=head1 AUTHOR

Pete Ratzlaff <pratzlaff@cfa.harvard.edu>

=head1 SEE ALSO

perl(1).

=cut
