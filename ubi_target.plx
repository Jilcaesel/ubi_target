#!/usr/bin/perl

#
# Targeted programs and UBI's effects as darts target
#
# Public domain
#

use strict;
use warnings;
use utf8;
use Getopt::Long ":config" => "require_order", "bundling";
use Cairo;

use constant PI => 4 * atan2(1, 1);

my $lang = "en";
my $output = "x:";

GetOptions (
  "l|lang=s" => \$lang,
  "o|output=s" => \$output,
) and @ARGV == 0 or die;

my $tw = 1280;
my $th = 720;

my $surface = Cairo::ImageSurface->create("rgb24", $tw, $th);
my $cr = Cairo::Context->create($surface);

sub Cairo::Context::show_text_at($$$$$) {
  my ($self, $x, $y, $xa, $ya, $text) = @_;
  my (@text) = split "\n", $text;
  my $e = $self->text_extents("|");
  my $lh = $e->{height} * 1.075;
  $y -= $lh * scalar(@text) * $ya + $e->{y_bearing};
  for my $t (@text) {
    my $e = $self->text_extents($t);
    $self->move_to($x - $e->{width} * $xa, $y);
    $self->show_text($t);
    $y += $lh;
  }
}

sub clip_rounded($$$) {
  my ($w, $h, $b) = @_;
  my $r = 4 * $b;
  my $c = $r + $b;
  my $d = $c - 0.55 * $r;
  $cr->move_to (0  + $c, 0  + $b);
  $cr->line_to ($w - $c, 0  + $b);
  $cr->curve_to($w - $d, 0  + $b, $w - $b, 0  + $d, $w - $b, 0  + $c);
  $cr->line_to ($w - $b, $h - $c);
  $cr->curve_to($w - $b, $h - $d, $w - $d, $h - $b, $w - $c, $h - $b);
  $cr->line_to (0  + $c, $h - $b);
  $cr->curve_to(0  + $d, $h - $b, 0  + $b, $h - $d, 0  + $b, $h - $c);
  $cr->line_to (0  + $b, 0  + $c);
  $cr->curve_to(0  + $b, 0  + $d, 0  + $d, 0  + $b, 0  + $c, 0  + $b);
  $cr->clip;
}

sub draw_target() {
  my $n = 20;
  my @r = (100, 450, 550, 900, 1000);
  my $stfill = sub {
    my ($c) = @_;
    my @col = ([0, 0, 0], [1, 1, 1], [1, 0, 0], [0, 0.7, 0]);
    $cr->set_source_rgb(@{$col[$c]});
    my $path = $cr->copy_path;
    $cr->fill;
    $cr->append_path($path);
    $cr->set_source_rgb(0.7, 0.7, 0.7);
    $cr->stroke;
  };
  $cr->new_path;
  $cr->set_source_rgb(0, 0, 0);
  $cr->arc(0, 0, 1120, 0, 2 * PI);
  $cr->fill;
  my @score = (20, 1, 18, 4, 13, 6, 10, 15, 2, 17,
    3, 19, 7, 16, 8, 11, 14, 9, 12, 5);
  for my $i (0 .. $n - 1) {
    my $a1 = (15 + $i - 0.5) * 2 * PI / $n;
    my $a2 = (15 + $i + 0.5) * 2 * PI / $n;
    my $dx1 = cos($a1);
    my $dx2 = cos($a2);
    my $dy1 = sin($a1);
    my $dy2 = sin($a2);
    $cr->set_line_join("round");
    $cr->set_line_width(10);
    for my $j (0 .. $#r - 1) {
      my $r1 = $r[$j];
      my $r2 = $r[$j + 1];
      $cr->move_to($r1 * $dx1, $r1 * $dy1);
      #$cr->line_to($r1 * $dx2, $r1 * $dy2);
      $cr->arc(0, 0, $r1, $a1, $a2);
      $cr->line_to($r2 * $dx2, $r2 * $dy2);
      #$cr->line_to($r2 * $dx1, $r2 * $dy1);
      $cr->arc_negative(0, 0, $r2, $a2, $a1);
      $cr->close_path;
      $stfill->(($j % 2) * 2 + ($i % 2));
    }
    $cr->save;
    $cr->select_font_face("Linux Biolinum O", "normal", "normal");
    $cr->set_font_size(120);
    $cr->rotate($i * 2 * PI / $n);
    $cr->set_source_rgb(1, 1, 1);
    $cr->show_text_at(0, -1000, 0.5, 0.85, $score[$i]);
    $cr->restore;
  }
  $cr->new_path;
  $cr->arc(0, 0, $r[0], 0, 2 * PI);
  $stfill->(3);
  $cr->arc(0, 0, $r[0] / 2, 0, 2 * PI);
  $stfill->(2);
}

sub langsel(@) {
  my (%t) = @_;
  my $r = $t{$lang};
  if (!defined $r) {
    $r = $t{en};
    warn "$r not translated in $lang\n";
  }
  return $r;
}

sub draw_label($$$@) {
  my ($a, $r, $c, @t) = @_;
  $cr->save;
  $cr->set_source_rgb(@$c);
  $cr->rotate($a * 2 * PI / 20);
  $cr->show_text_at(0, -$r, 0.5, 0.5, langsel(@t));
  $cr->restore;
}

$cr->set_source_rgb(0.4, 0.2, 0.2);
$cr->paint;

my $yellow = [ 1, 1, 0 ];
my $dablue = [ 0, 0, 0.8 ];

$cr->save;
$cr->select_font_face("Linux Biolinum O", "normal", "bold");
$cr->set_font_size(50);
$cr->set_source_rgb(1, 0, 1);
$cr->show_text_at($tw / 4, $th / 128, 0.5, 0,
  langsel(en => "Targeted social programs", fr => "Programmes soxiaux ciblés"));
clip_rounded $tw / 2, $th, $tw / 128;
$cr->translate($tw / 4, $th / 2);
$cr->scale($tw / (4 * 1200), $tw / (4 * 1200));
$cr->translate(0, 2500);
$cr->scale(3.2, 3.2);
draw_target;
$cr->select_font_face("Linux Biolinum O", "normal", "bold");
$cr->set_font_size(25);
draw_label  0, 950, $yellow, en => "helping\nthe poor", fr => "aider les\npauvres";
draw_label -1, 950, $dablue, en => "enriching\ncharities", fr => "enrichir les\norganisations caritatives";
draw_label +1, 950, $dablue, en => "clientelism", fr => "clientélisme";
draw_label  0, 725, $yellow, en => "poverty\ntrap", fr => "piège à\npauvreté";
draw_label -1, 725, $dablue, en => "bureaucracy", fr => "bureaucratie";
draw_label +1, 725, $dablue, en => "social\nstigma", fr => "stigmate\nsocial";
draw_label  0, 500, $yellow, en => "injustice", fr => "injustice";
draw_label -1, 500, $dablue, en => "forgetting\npeople", fr => "oublier\ndes gens";
draw_label +1, 500, $dablue, en => "misused\nfunds", fr => "fonds\ndétournés";
draw_label -2, 500, $yellow, en => "uncertainty", fr => "incertitude";
draw_label +2, 500, $yellow, en => "inadequate\nhelp", fr => "aide\ninadaptée";
$cr->restore;

$cr->save;
$cr->translate($tw / 2, 0);
$cr->select_font_face("Linux Biolinum O", "normal", "bold");
$cr->set_font_size(50);
$cr->set_source_rgb(0, 1, 1);
$cr->show_text_at($tw / 4, $th / 128, 0.5, 0,
  langsel(en => "Universal basic income", fr => "Revenu universel"));
clip_rounded $tw / 2, $th, $tw / 128;
$cr->translate($tw / 4, $th / 2);
$cr->scale($tw / (4 * 1200), $tw / (4 * 1200));
$cr->translate(0, 2500);
$cr->scale(3.2, 3.2);
draw_target;
$cr->select_font_face("Linux Biolinum O", "normal", "bold");
$cr->set_font_size(25);
draw_label  0, 950, $yellow, en => "eradicating\npoverty", fr => "éliminer\nla pauvreté";
draw_label -1, 950, $dablue, en => "escape from abusive\nsituations", fr => "sortie des\nsituations abusives";
draw_label +1, 950, $dablue, en => "boosting local\nbusinesses", fr => "stimuler les\nentreprises locales";
draw_label  0, 725, $yellow, en => "increased\nmotivation", fr => "meilleure\nmotivation";
draw_label -1, 725, $dablue, en => "recognizing\nunpaid labor", fr => "reconnaître\nle travail bénévole";
draw_label +1, 725, $dablue, en => "bargaining\npower\nfor workers", fr => "pouvoir de\nnégociation pour\nles travailleurs";
draw_label  0, 500, $yellow, en => "new\nmodels", fr => "nouveaux\nmodèles";
draw_label -1, 500, $dablue, en => "better\nmental\nhealth", fr => "meilleure\nsanté\nmentale";
draw_label +1, 500, $dablue, en => "enabling\nartists", fr => "favoriser\nles artistes";
draw_label -2, 500, $yellow, en => "social\nfabric", fr => "tissu\nsocial";
draw_label +2, 500, $yellow, en => "ethical", fr => "éthique";
$cr->restore;

# < enriching charities
# helping the poor
# > ???

# < bureaucracy
# poverty trap
# > social stigma

open my $out, "|-", "convert", "png:-", $output or die "convert: $!\n";
$surface->write_to_png_stream(sub { print $out $_[1] });
