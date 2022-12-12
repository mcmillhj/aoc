#!raku 

class Point {
  has Int $.x;
  has Int $.y;

  has @!directions = (
    [ +0, -1 ], # up
    [ +1, +0 ], # right
    [ +0, +1 ], # down
    [ -1, +0 ], # left
  );

  method adjacents() {
    @!directions.map: -> ($dx, $dy) { Point.new(x => $.x + $dx, y => $.y + $dy) }
  }

  method WHICH() {
    return $.x ~ ',' ~ $.y;
  }
}

sub elevation(Str $s where *.chars == 1) {
  return ord(do given $s {
    when 'S' { 'a' }
    when 'E' { 'z' }
    default  { $s  }
  });
}

my $START = 'S';
my $GOAL = 'E';
my @START-POINTS;
my $END-POINT;

my %grid{Point};
for 'input'.IO.lines.kv -> $i, $line {
  for $line.comb.kv -> $j, $c {
    if $c eq $START or $c eq 'a' {
      @START-POINTS.push: Point.new(x => $i, y => $j);
    } 

    if $c eq $GOAL {
      $END-POINT = Point.new(x => $i, y => $j);
    }

    %grid{Point.new(x => $i, y => $j)} = elevation($c);
  }
}

sub adjacents(Point $p) {
  my $current = %grid{$p};

  my @adjacent-nodes = $p.adjacents
    # filter out adjacents that are not in the grid
    .grep({ %grid{$_}:exists })
    # only move to adjacents that are 1 higher or are <= to the current value
    .grep({ %grid{$_} - $current <= 1 });

  @adjacent-nodes;
}

sub djikstra(@start-points) {
  my @visited = @start-points;
  my Int %paths{Point} = @start-points.map({ $_ => 0 });

  while @visited {
    my $source = @visited.shift();

    # stopping searching once we have found our goal node
    return %paths if $source eq $GOAL;

    for adjacents($source) -> $target {
      my $new-cost = %paths{$source} + 1;

      # if the target node has not been visited or has been visited but this path has a lower cost
      # update the cost for the target and add the target to the visited set
      if not %paths{$target}:exists or $new-cost + 1 < %paths{$target} {
        %paths{$target} = $new-cost;

        @visited.push: $target;
      }
    }
  }

  %paths;
}

say djikstra(@START-POINTS){$END-POINT};