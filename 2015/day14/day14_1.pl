#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(say);

my $max_distance = 0;
while ( my $line = <DATA> ) {
   chomp($line);

   my ( $reindeer,
        $speed_kms,
        $duration,
        $rest
   ) = $line =~ m|(\w+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds|;

   my $distance = 0;
   my $seconds = 2503;
   while ( $seconds > 0 ) {
      $distance += $speed_kms * $duration;
      $seconds -= $duration + $rest;
   }
   $max_distance = $distance
      if $max_distance < $distance;
}

say $max_distance;

__DATA__
Vixen can fly 19 km/s for 7 seconds, but then must rest for 124 seconds.
Rudolph can fly 3 km/s for 15 seconds, but then must rest for 28 seconds.
Donner can fly 19 km/s for 9 seconds, but then must rest for 164 seconds.
Blitzen can fly 19 km/s for 9 seconds, but then must rest for 158 seconds.
Comet can fly 13 km/s for 7 seconds, but then must rest for 82 seconds.
Cupid can fly 25 km/s for 6 seconds, but then must rest for 145 seconds.
Dasher can fly 14 km/s for 3 seconds, but then must rest for 38 seconds.
Dancer can fly 3 km/s for 16 seconds, but then must rest for 37 seconds.
Prancer can fly 25 km/s for 6 seconds, but then must rest for 143 seconds.
