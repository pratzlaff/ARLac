#! /usr/bin/perl -w

use ARLac;

use PDL;
use PDL::Graphics::PGPLOT;
use Astro::FITS::CFITSIO;
use Math::Trig 'pi';

my @o = ARLac::obsids();
my $ra_src = ARLac::ra();
my $dec_src = ARLac::dec();

my (@off, @srcr, @bgr);

my $maxoff = 0;

for my $o ( @o ) {

  my ($evt) = glob("/data/legs/rpete/data/ARLac/$o/tg_reprocess/*evt2*");

  $evt or
    die "nothing found for /data/legs/rpete/data/ARLac/$o/tg_reprocess/*evt2*";

  my $hdr = Astro::FITS::CFITSIO::fits_read_header($evt.'[events]') or die;
  my $ra_pnt = $hdr->{RA_PNT};
  my $dec_pnt = $hdr->{DEC_PNT};
  my $off = sqrt((($dec_pnt-$dec_src)**2 + cos(2*pi*$dec_src/360)*($ra_pnt-$ra_src)**2));

  $off *= 60;
  $maxoff = $off if $maxoff < $off;

  my $bgreg = "/data/legs/rpete/data/ARLac/$o/flux_full/bg.reg";
  my ($srcr, $bgr) = (reg_desc($bgreg))[3,4];


  push @off, $off;
  push @srcr, $srcr;
  push @bgr, $bgr;

}

printf "maximum off-axis angle is %.1f arcmin\n", $maxoff;

my $bgr = pdl \@bgr;
my $srcr = pdl \@srcr;
my $ratio = $bgr / $srcr;
printf "bg_r/src_r ratio min=%.2f, max=%.2f\n", $ratio->minmax;

my $off = pdl \@off;

dev '/xs';
points $off, $srcr,
  {
   border => 1,
   xtitle => 'off-axis angle (arcmin)',
   ytitle => 'source radius (pix)',
  };
hold;


my ($x1, $x2) = (0, 18);
my ($y1, $y2) = (100, 700);
my $m = ($y2-$y1) / ($x2 - $x1);
my $b = $y1 - $m * $x1;

printf "m=%.1f, b=%.1f\n", $m, $b;

my $linex = sequence(100) / 100 * $off->max;
my $liney = $m * $linex + $b;

line $linex, $liney;
release;

exit;

sub reg_desc {
  my $f = shift;

  open(REG, '< '.$f) or die "$f: $!";
  my @reg = <REG>;
  close REG or die $!;

  @reg == 2 or die;

  my ($type, $params) = $reg[1] =~ /^(\w+)\(([^)]+)\)/ or die;
  my @p = split ',', $params;

  return $type, @p;
}
