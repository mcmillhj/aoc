#!perl6

my @directions = (
  [ -1, -1 ], # up + left
  [ -1, +0 ], # up
  [ -1, +1 ], # up + right
  [ +0, +1 ], # right
  [ +1, +1 ], # down + right
  [ +1, +0 ], # down
  [ +1, -1 ], # down + left
  [ +0, -1 ], # left
);

my @data;
for 'input'.IO.lines -> $line {
  my @row = $line.comb>>.Int;
  @data.push: @row; 
}

my $rows = @data.end;
my $columns = @data[0].end;

sub increment(@state) {
  for 0 .. $rows -> $x {
    for 0 .. $columns -> $y {
      @state[$x][$y] += 1;
    }
  }

  @state;
}

my SetHash $flashed;
my $flash-count = 0;
my $step-count = 0;

multi sub flash(@state) {
  for 0 .. $rows -> $x {
    for 0 .. $columns -> $y {
      next unless @state[$x][$y] > 9;

      flash(@state, $x, $y);
    }
  }
}

multi sub flash(@state, Int $x, Int $y) {
  # only consider octopi that have not already flashed this step
  return if $flashed{"$x, $y"};

  # reset energy level to 0 after flash
  @state[$x][$y] = 0;

  # mark that this octopus flashed
  $flashed.set: "$x,$y";

  # count flash 
  $flash-count++;

  # increment neighbors
  for @directions -> [$dx, $dy] {
    my $nx = $x + $dx;
    my $ny = $y + $dy;
    
    # only consider valid points
    next unless 0 <= $nx <= $rows && 0 <= $ny <= $columns;

    # only consider octopi that have not flashed this step
    next if $flashed{"$nx,$ny"};

    @state[$nx][$ny] += 1;

    if @state[$nx][$ny] > 9 {
      flash(@state, $nx, $ny);
    }
  }
}

sub all-flashing(@state) {
  ([+] @state.flatmap({ .flat })) == 0;
}

sub step(@state) {
  # count this step 
  $step-count++; 

  @state ==> increment()
         ==> flash();
}

# step
loop {
  $flashed = SetHash.new;
  step(@data);
 
  last if all-flashing(@data);
}

say "FLASH COUNT = $flash-count";
say "STEP COUNT = $step-count";