#! /usr/bin/perl

use strict;

my $vcf = shift;

print join("\t", qw( id hp_distance1 hp_distance2 sr_distance1 sr_distance2 gap_distance1 gap_distance2 svlength mapq1 mapq2 pid1 pid2 cipos1 cipos2 plength1 plength2 ciend1 ciend2 rlength gap dr1 dr2 dv1 dv2) ) . "\n";

open VCF, $vcf;
while(<VCF>) {
  chomp;
  next if $_ =~ /^#/;
  my ( $chrom, $pos, $id, $ref, $alt, $qual, $filter, $info, $format, $sample ) = split/\t/, $_;
  my $type = $1 if $info =~ /SVTYPE=(\w+)/;
  my $chr2 = $chrom;
  my $pos2 = $1 if $info =~ /;END=(\d+)/;
  $pos2 = $1 if $info =~ /^END=(\d+);/;
  ( $chr2, $pos2 ) = ( $1, $2 ) if $alt =~ /(\w+):(\d+)/;
  my $validated = $1 if $info =~ /VALIDATED=(\w+);/;
  my $precise = $1 if $info =~ /(\w*PRECISE)/;
  my ( $mapq1, $mapq2 ) = ( $1, $2 ) if $info =~ /MAPQ=(\d+),(\d+)/;
  my $rlength = $1 if $info =~ /RLENGTH=(\d+)/;
  my ( $pid1, $pid2 ) = ( $1, $2 ) if $info =~ /PID=(\d*\.\d*),(\d*\.\d*)/;
  my ( $twod, $temp, $compl ) = ( $1, $2, $3 ) if $info =~ /RT=(\d+),(\d+),(\d+)/;
  my ( $cipos1, $cipos2 ) = ( $1, $2 ) if $info =~ /CIPOS=-*(\d+),(\d+)/;
  my $gap = $1 if $info =~ /GAP=(-*\d+)/;
  my ( $plength1, $plength2 ) = ( $1, $2 ) if $info =~ /PLENGTH=(\d*\.\d*),(\d*\.\d*)/;
  my ( $ciend1, $ciend2 ) = ( $1, $2 ) if $info =~ /CIEND=-*(\d+),(\d+)/;
  my @format = split/:/, $format;
  my @sample = split/:/, $sample;
  my ( $genotype, $dr1, $dr2, $dv1, $dv2, $hr1, $hr2 );
  my $svlength = "1000000";
  if ( $chr2 =~ /^$chrom$/ ) {
	$svlength = ( $pos2 - $pos );
  }
  if ( $type eq 'INS' ) {
	$svlength = $gap;
  }
  foreach my $i ( 0..$#format ) {
    $genotype = $sample[$i] if $format[$i] eq "GT";
    ( $dr1, $dr2 ) = ( $1, $2 ) if $sample[$i] =~ /(\d+),(\d+)/ and $format[$i] eq "DR";
    ( $dv1, $dv2 ) = ( $1, $2 ) if $sample[$i] =~ /(\d+),(\d+)/ and $format[$i] eq "DV";
    ( $hr1, $hr2 ) = ( $1, $2 ) if $sample[$i] =~ /(\d+),(\d+)/ and $format[$i] eq "HR";
  }
  my $homopolymer = 0;
  my $simplerepeat = 0;
  my $onekg = 0;
  my $gonl = 0;
  my $dna181 = 0;
  my $dna250 = 0;
  my $na12878 = 0;
  my $svcluster = 0;
  $homopolymer = 1  if $filter =~ /HomoPolymer/;
  $simplerepeat = 1 if $filter =~ /SimpleRepeat/;
  $onekg = 1 if $filter =~ /1kg/;
  $gonl = 1 if $filter =~ /gonl/;
  $dna181 = 1 if $filter =~ /dna181/;
  $dna250 = 1 if $filter =~ /dna250/;
  $na12878 = 1 if $filter =~ /na12878/;
  $svcluster = 1 if $filter =~ /svcluster/;
  
  my ($hp_distance1, $hp_distance2) = ($1, $2) if $info =~ /homopolymer_distance=(\d+),(\d+)/;
  my ($sr_distance1, $sr_distance2) = ($1, $2) if $info =~ /simpleRepeats_distance=(\d+),(\d+)/;
  my ($gap_distance1, $gap_distance2) = ($1, $2) if $info =~ /gap_distance=(\d+),(\d+)/;
  
#   print join("\t", $id, $chrom, $pos, $chr2, $pos2, $type, $filter, $validated, $precise, $mapq1, $mapq2, $rlength, $pid1, $pid2, $twod, $temp, $compl, $cipos1, $cipos2, $gap, $plength1, $plength2, $ciend1, $ciend2, $genotype, $dr1, $dr2, $dv1, $dv2, $hr1, $hr2, $svlength ) . "\n";
  print join("\t", $id, $hp_distance1, $hp_distance2, $sr_distance1, $sr_distance2, $gap_distance1, $gap_distance2, $svlength, $mapq1, $mapq2, $pid1, $pid2, $cipos1, $cipos2, $plength1, $plength2, $ciend1, $ciend2, $rlength, $gap, $dr1, $dr2, $dv1, $dv2 ) . "\n";
}
close VCF;