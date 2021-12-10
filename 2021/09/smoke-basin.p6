#!perl6

my @directions = (
  [ +0, +1 ], # right
  [ +0, -1 ], # left
  [ +1, +0 ], # down
  [ -1, +0 ], # up
);

class Cell {
  has Int $.x;
  has Int $.y;
  has Int $.elevation;
  has Bool $.is-sink;
  has Cell @.neighbors;

  method is-sink(--> Bool) {
    my $lowest-neighbor = [min] self.neighbors.map({ .elevation });
    
    $lowest-neighbor > self.elevation;
  }

  method find-basin(SetHash[Cell] $basin) {
      $basin.set: self;

      for self.neighbors -> $neighbor {
        next unless $neighbor.elevation < 9 and !$basin{$neighbor};

        $neighbor.find-basin($basin);
      }
  }
}

my @data = 'input'.IO.lines>>.comb>>.Int;
sub neighbors(Int $x, Int $y) {
  @directions.grep: -> [$dx, $dy] { is-valid-neighbor($x + $dx, $y + $dy) };
}

my $rows = @data.end;
my $columns = @data[0].end;

say { rows => $rows, columns => $columns };

sub is-valid-neighbor(Int $x, Int $y) {
  0 <= $x <= $rows && 0 <= $y <= $columns;
}


my Array[Cell] @basin;
for 0 .. $rows -> $x {
  my Cell @row;
  for 0 .. $columns -> $y {
    @row.push: Cell.new(elevation => @data[$x][$y], x => $x, y => $y);
  }

  @basin.push: @row;
}

# build out neighbors
for 0 .. $rows -> $x {
  for 0 .. $columns -> $y {
    my Cell @neighbors;
    for @directions -> [$dx, $dy] {
      next unless is-valid-neighbor($x + $dx, $y + $dy);

      @neighbors.push: @basin[$x + $dx][$y + $dy];
    }

    @basin[$x][$y].neighbors = @neighbors;
  }
}

# collect lowest points
my Cell @sinks; 
for 0 .. $rows -> $x {
  for 0 .. $columns -> $y {
    my $cell = @basin[$x][$y];

    next unless $cell.is-sink;

    @sinks.push: $cell;
  }
}

# part 1 
say [+] @sinks.map: { 1 + .elevation };

# part 2
say [*] @sinks.map(-> $cell { # recursively find the entire basin for a given cell
  my $basin = SetHash[Cell].new;
  $cell.find-basin($basin);

  $basin.elems
})
.sort({ $^b cmp $^a }) # sort descending 
.head(3);              # take the largest 3