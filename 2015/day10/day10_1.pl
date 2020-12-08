#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(say);

my $line = '1321131112';
foreach ( 0 .. 39 ) {
   $line = look_and_say($line);
}

say $line;
say length($line);

sub look_and_say {
   my ($line) = @_;
   return $line =~ s/((\d)\2*)/length($1) . $2/gre;
}

