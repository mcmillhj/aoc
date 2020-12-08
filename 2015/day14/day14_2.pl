#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(say);

my @reindeer;
while ( my $line = <DATA> ) {
   chomp($line);

   my ( $reindeer,
        $speed_kms,
        $duration,
        $rest,
   ) = $line =~ m|(\w+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds|;


   push @reindeer, {
      name       => $reindeer,
      speed      => $speed_kms,
      points     => 0,
      steps      => 0,
      distance   => 0,
      duration   => $duration,
      rest       => $rest,
      status     => 'flying',
   };    
}    


step($_, @reindeer) foreach 0 .. 2502;

my ($highest_points) =
   map  { $_->[1]->{points}    }
   sort { $b->[0] <=> $a->[0]  }
   map  { [ $_->{points}, $_ ] } @reindeer;

say $highest_points;

sub step {
   my ($second, @reindeer) = @_;

   my $max_distance = 0;
   foreach my $r ( @reindeer ) {
      $r->{steps}++;
      $r->{distance} += $r->{speed} if $r->{status} eq 'flying';

      if ( $r->{status} eq 'flying' && $r->{steps} == $r->{duration} ) {
         $r->{status} = 'resting';
         $r->{steps} = 0;
      }
      elsif ( $r->{status} eq 'resting' && $r->{steps} == $r->{rest} ) {
         $r->{status} = 'flying';
         $r->{steps} = 0;
      }

      $max_distance = $r->{distance}
          if $r->{distance} > $max_distance;
   }

   foreach my $r ( @reindeer ) {
      next unless $r->{distance} == $max_distance;

      $r->{points}++;
   }

   return;
}

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
