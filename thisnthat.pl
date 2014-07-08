#!/usr/bin/env perl

use autodie;
use strict;
use warnings;

use Data::Dumper;

my %ACTION = (
  1 => sub {    # create
    for my $fn (@_) {
      open my $fh, '>', $fn;    # touch
    }
  },
  2 => sub {                    # delete
    unlink @_;
  },
  3 => sub {                    # nop
  },
);

die unless @ARGV == 2;

my ( $this, $that ) = @ARGV;

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
  my $action = $ACTION{$act};
  next unless defined $action;
  $action->( @{ $bucket{$act} } );
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

