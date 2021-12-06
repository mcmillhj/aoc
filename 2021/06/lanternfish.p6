#!perl6

use experimental :cached;

sub lanternfish(Int $age, Int $day) is cached {
  # each remaining fish on day 0 counts as 1
  if $day == 0 {
    return 1;
  }

  # when a fish reaches age 0
  # it creates a new fish with age 8 and resets to age 6 (for the next day)
  if $age == 0 {
    return lanternfish(6, $day - 1) + lanternfish(8, $day - 1);
  }

  # each day the age and day counters decrement
  return lanternfish($age - 1, $day - 1);
}


sub evolve(Int @fish, Int $days) {
  my $population = 0;
  for @fish -> $fish {
    $population += lanternfish($fish, $days);
  }

  return $population;
}

my Int @fish = 'input'.IO.lines.split(',')>>.Int;
say evolve(@fish, 80);
say evolve(@fish, 256);
