#!/usr/bin/env perl

use autodie;
use strict;
use warnings;

my %ACTION = (
  1 => sub {    # create
    open my $fh, '>', $_ for @_;    # touch
  },
  2 => sub {                        # delete
    unlink @_;
  },
  3 => sub {                        # nop
  },
);

my %seen = ();
my $bit  = 1;
for my $src (@ARGV) {
  $seen{$_} |= $bit for filter( load($src) );
  $bit <<= 1;
}
my %bucket = ();
while ( my ( $fn, $st ) = each %seen ) {
  push @{ $bucket{$st} }, $fn;
}
for my $act ( sort { $a <=> $b } keys %bucket ) {
  ( $ACTION{$act} || sub { } )->( @{ $bucket{$act} } );
}

sub filter {
  grep { m{^./} } grep { !m{\.wiki\.git$} } @_;
}

sub load {
  my $fn = shift;
  open my $fh, '<', $fn;
  chomp( my @l = <$fh> );
  return @l;
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

