#!/usr/bin/env perl

use strict;
use Getopt::Long;

# Creating Variable
my $alignmentsGff;

# Creating Arguments
&GetOptions("gffFile=s" => \$alignmentsGff,
           );

open(FILE, "$alignmentsGff") or die "Cannot open file $alignmentsGff for reading";
open(OUT, ">fixed.gff") or die "Cannot open file fixed.gff for writing";
my ($proteinId);
my $cdsCount = 0;
while(my $line = <FILE>) {
  chomp $line;
  my @a = split(/\\t/, $line);
  my $type = $a[2];
  if($type eq 'gene') {
      $proteinId = $a[8] =~ /sequence (\\S+)/;
      $cdsCount = 0;
  }
  if($type eq 'cds') {
      $cdsCount++;
      $a[8] = "ID=${proteinId}_cds_${cdsCount};Parent=${proteinId}";
  }
  elsif($type eq 'similarity') {
      $a[8] = "ID=${proteinId}";
  }
  else {
      next;
  }
  print OUT join("\\t", @a) . "\\n";
}
close FILE;
close OUT;
