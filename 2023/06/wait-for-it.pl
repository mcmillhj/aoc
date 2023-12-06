#!perl 

use strict;
use warnings;

use feature    qw/say/;
use List::Util qw/zip product/;
use POSIX      qw/floor ceil/;

my @races = do {
  zip([ map { 0 + $_ } <> =~ /(\d+)/g ], [ map { 0 + $_ } <> =~ /(\d+)/g ]);
};

sub race {
  my ($total_race_time, $distance_record) = @_;

# T = total race time
# S = speed (time charging button)
# t = T - S (1) (the amount of time spent traveling is the total race time - how long the button was charged)
# d = t * S (2) (the distance traveled is the time spent traveling * the speed of travel)
#
# substitute (1) into (2) and set to 0
#-----------------------------------------------------------
# d = (T - S) * S
# d = ST - S^2
# S^2 + d = ST
# S^2 - ST + d = 0
#
# apply the quadratic formula to find both roots
# ----------------------------------------------
# a=1, b=-S, c=d
# root1 = (-b + sqrt(b^2 - 4ac)) / 2
#       = (S + sqrt(-S^2 - 4*d)) / 2
# root2 = (-b - sqrt(b^2 - 4ac)) / 2
#       = (S - sqrt(-S^2 - 4*d)) / 2

  my $root1 =
    ($total_race_time +
      sqrt(-$total_race_time * -$total_race_time - 4 * $distance_record)) / 2;
  my $root2 =
    ($total_race_time -
      sqrt(-$total_race_time * -$total_race_time - 4 * $distance_record)) / 2;

  return floor($root1) - ceil($root2) + 1;
}

# part 1
say product map { race(@$_) } @races;

# part 2
say race(int(join '', map { @$_[0] } @races),
  int(join '', map { @$_[1] } @races));

