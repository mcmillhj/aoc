#!raku 

class Point {
  has Int $.x;
  has Int $.y;

  method add(Point $other --> Point) {
    Point.new(x => $.x + $other.x, y => $.y + $other.y);
  }

  method multiply(Int $factor --> Point) {
    Point.new(x => $.x * $factor, y => $.y * $factor);
  }

  method WHICH {
    $.x ~ ',' ~ $.y;
  }
}

# load all points into a Hash to make checking bounds easier
my %grid{Point};
for 'input'.IO.lines.kv -> $i, $line {
  for $line.comb.kv -> $j, $c {
    %grid{Point.new(x => $i, y => $j)} = $c;
  }
}

my $visible-count = 0;
my $max-scenic-score = 0;
for %grid.kv -> $tree, $height {
  my $visible = False;
  my $scenic-score = 1;

  for [
    Point.new(x => +0, y => -1), # up
    Point.new(x => +1, y => +0), # right
    Point.new(x => +0, y => +1), # down
    Point.new(x => -1, y => +0), # left
  ] -> $direction {
    # search from a single point in all directions until we meet an edge or a larger tree
    for 1 .. * -> $i {
      my $delta = $tree.add($direction.multiply($i));

      # grab the neighboring tree in the current direction
      my $neighboring-tree-height = %grid{$delta};

      # if there is no tree then we must be at an edge 
      # which means this tree is visible!!
      if not defined $neighboring-tree-height {
        $visible = True;

        # increase the scenic score by the # of trees that are visible
        $scenic-score *= $i - 1;

        last;
      }

      # if the neighboring tree is larger than the current tree it is _not_ visible
      if $neighboring-tree-height >= $height {
        # increase the scenic score by the # of trees that are visible
        $scenic-score *= $i;

        last;
      }
    }
  }

  $visible-count += 1 if $visible;
  $max-scenic-score = max $max-scenic-score, $scenic-score;
}

say $visible-count;
say $max-scenic-score;