#!raku 

class Point {
  has Int $.x;
  has Int $.y;

  has @!directions = (
    [ +0, +1 ], # down
    [ -1, +1 ], # down + left
    [ +1, +1 ], # down + right
  );

  method adjacents() {
    @!directions.map: -> ($dx, $dy) { Point.new(x => $.x + $dx, y => $.y + $dy) }
  }

  method Str {
    return $.x ~ ',' ~ $.y; 
  }

  method WHICH() {
    return $.x ~ ',' ~ $.y;
  }
}

my $MAX-X = 0;
my $MAX-Y = 0;
my @paths = 'input'.IO.lines.map(-> $line { 
  $line.split(' -> ').map(-> $point { 
    my ($x, $y) = $point.split(',')>>.Int; 
    
    $MAX-X = max($MAX-X, $x);
    $MAX-Y = max($MAX-Y, $y);

    ($x, $y) 
  }).Array 
});

my %scan;
for @paths -> @path {
  my ($x1, $y1) = @path.shift; 
  for @path -> ($x2, $y2) {
    for min($x1, $x2) .. max($x1, $x2) -> $x {
      for min($y1, $y2) .. max($y1, $y2) -> $y {
        %scan{Point.new(x => $x, y => $y)} = '#'
      }
    }

    $x1 = $x2; 
    $y1 = $y2;
  }
}

sub part1(%scan is copy) {
  loop {
    my $sand = Point.new(x => 500, y => 0);

    # keep looping while we are in the bounds of the scan
    while $sand.y < $MAX-Y and $sand.x < $MAX-X {

      # find the first element down, down + left, or down + right that is not blocked
      my $next-sand = $sand.adjacents.first(-> $a { not %scan{$a}:exists });

      # if all neighboring elements are blocked stop looping
      last unless $next-sand;

      # move the sand the next free position
      $sand = $next-sand;
    }

    if $sand.y >= $MAX-Y or $sand.x >= $MAX-X {
      last;
    }

    # mark the sand on the scan
    %scan{$sand} = 'o';
  }

  %scan;
}

sub part2(%scan is copy) {
  while not %scan{"500,0"}:exists {
    my $sand = Point.new(x => 500, y => 0);

    loop {
      # stop looping if we have found the floor
      last if $sand.y == $MAX-Y + 1;

      # find the first element down, down + left, or down + right that is not blocked
      my $next-sand = $sand.adjacents.first(-> $a { not %scan{$a}:exists });

      # if all neighboring elements are blocked stop looping
      last unless $next-sand;

      # move the sand the next free position
      $sand = $next-sand;
    }

    # mark the sand on the scan
    %scan{$sand} = 'o';
  }

  %scan;
}

dd part1(%scan).values.grep(-> $v { $v eq 'o' }).elems;
dd part2(%scan).values.grep(-> $v { $v eq 'o' }).elems;