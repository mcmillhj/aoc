#!raku 

enum Direction <UP DOWN LEFT RIGHT>;

class Point {
  has Int $.x;
  has Int $.y;

  has @!directions = (
    [ -1, -1 ], # up + left
    [ +0, -1 ], # up
    [ +1, -1 ], # up + right
    [ +1, +0 ], # right
    [ +1, +1 ], # down + right
    [ +0, +1 ], # down
    [ -1, +1 ], # down + left
    [ -1, +0 ], # left
  );

  method move(Direction $d, Int $distance = 1) {
    given $d {
      when UP    { Point.new(x => $.x, y => $.y + $distance) }
      when DOWN  { Point.new(x => $.x, y => $.y - $distance) }
      when LEFT  { Point.new(x => $.x - $distance, y => $.y) }
      when RIGHT { Point.new(x => $.x + $distance, y => $.y) }
    }
  }

  method adjacents() {
    @!directions.map: -> ($dx, $dy) { Point.new(x => $.x + $dx, y => $.y + $dy) }
  }

  method WHICH() {
    return $.x ~ ',' ~ $.y;
  }
}

my $ORIGIN = Point.new(x => 0, y => 0);
my Point @knots = $ORIGIN xx 10;
my $visited = SetHash.new($ORIGIN);

for 'input'.IO.lines>>.split(" ") -> ($command, $distance) {
  my $direction = do given $command {
    when "U" { UP }
    when "D" { DOWN }
    when "L" { LEFT }
    when "R" { RIGHT }
  };

  for ^$distance {
    @knots[0] = @knots[0].move($direction);

    for 1 ..^ @knots -> $idx {
      my $head = @knots[$idx - 1];
      my $tail = @knots[$idx];

      my $dx = $head.x - $tail.x;
      my $dy = $head.y - $tail.y;

      # if the tail is already adjacent to the head then the tail does not need to move
      # 0 = tail is on top of head
      # 1 = tail is adjacent to head
      next if $dx.abs < 2 and $dy.abs < 2;

      # move the tail based on the relative direction of the head
      # (1 - 0).sign, (-1, 0).sign => (1, -1) 
      # tells you that the tail is 1 unit right and 1 unit up from the head
      $tail = Point.new(
        x => $tail.x + ($head.x - $tail.x).sign, 
        y => $tail.y + ($head.y - $tail.y).sign
      );
      $visited.set(@knots.tail);
      @knots[$idx] = $tail;
    }

  }
}

say $visited.elems;