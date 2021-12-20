#!perl6

my Range $x-range = 119 .. 176;
my Range $y-range = -141 .. -84;

# part1 
say -$y-range.min * (-$y-range.min - 1) / 2;

# part 2
sub is-in-target(Int $x, Int $y) {
  $x ~~ $x-range and $y ~~ $y-range;
}

sub will-hit-target(Int $vx is copy, Int $vy is copy) {
  my $x = 0; 
  my $y = 0;
  
  while $y > $y-range.min {
    # increase x and y velocities
    $x += $vx;
    $y += $vy;
    
    $vx -= $vx > 0; # drag (if $vx is positive this will subtract 1, otherwise subtract 0)
    $vy -= 1;       # gravity

    return True 
      if is-in-target($x, $y);
  }

  return False;
}

my @velocities; 
for 1 .. $x-range.max -> $vx {
  for $y-range.min .. -$y-range.min -> $vy {
    next unless will-hit-target($vx, $vy);

    @velocities.push: ($vx, $vy);
  }
}

say @velocities.elems;
