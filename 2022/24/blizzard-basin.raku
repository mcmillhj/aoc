#!raku

enum Direction <LEFT UP RIGHT DOWN>;

class Point {
  has Int $.x is rw;
  has Int $.y is rw;

  method move(Direction $d) {
    do given $d {
      when LEFT  { Point.new(x => self.x,     y => self.y - 1) }
      when UP    { Point.new(x => self.x - 1, y => self.y)     }
      when RIGHT { Point.new(x => self.x,     y => self.y + 1) }
      when DOWN  { Point.new(x => self.x + 1, y => self.y)     }
    }
  }

  method Str {  self.x ~ ',' ~ self.y }
  method WHICH { self.Str }
}

class Blizzard {
  has Direction $.direction;
  has Point $.location;

  method move(Int $width, Int $height) {
    my $next-move = self.location.move(self.direction);

    given self.direction {
      when LEFT {
        self.location.x = $next-move.x;
        self.location.y = $next-move.y == 0 ?? $width - 2 !! $next-move.y;
      }
      when UP {
        self.location.x = $next-move.x == 0 ?? $height - 2 !! $next-move.x;
        self.location.y = $next-move.y;
      }
      when RIGHT {
        self.location.x = $next-move.x;
        self.location.y = $next-move.y == $width - 1 ?? 1 !! $next-move.y;
      }
      when DOWN {
        self.location.x = $next-move.x == $height - 1 ?? 1 !! $next-move.x;
        self.location.y = $next-move.y;
      }
    }
  }
}

my Point $start;
my Point $end;
my SetHash[Blizzard] $blizzards = SetHash[Blizzard].new;
my SetHash[Point] $available = SetHash[Point].new;
for 'input'.IO.lines.kv -> $row, $line {
  for $line.comb.kv -> $column, $value {
    my Point $p = Point.new(x => $row, y => $column);

    if $value ne '#' {
      $available.set: $p;
    }

    if $value eq 'S' {
      $start = $p;
    }

    if $value eq 'E' {
      $end = $p;
    }

    if $value ~~ /(<[<^>v]>)/ {
      my Direction $direction = do given ~$0 {
        when "<" { LEFT  }
        when "^" { UP    }
        when ">" { RIGHT }
        when "v" { DOWN  }
      };

      $blizzards.set: Blizzard.new(
        location  => $p,
        direction => $direction
      );
    }
  }
}

multi sub next-state(Point $p) {
  gather {
    # you can choose not to move
    take $p;

    # you can move in any of the 4 directions
    for [LEFT, UP, RIGHT, DOWN] -> $direction {
      take $p.move($direction);
    }
  }
}

multi sub next-state(SetHash[Blizzard] $blizzards) {
  for $blizzards.keys -> $blizzard {
    $blizzard.move(122, 27);
  }
}

# initialize a Set of possible states from the starting position
my SetHash[Point] $possible = SetHash[Point].new: $start;
my Int $trip-number = 1;
for 1 .. 1_000_000 -> $minute {
  # calculate next blizzard state
  next-state($blizzards);
  # create a set (or map) of locations that you cannot navigate to due to the blizzards
  my SetHash[Point] $not-possible = SetHash[Point].new: $blizzards.keys.map(-> Blizzard $b { $b.location });
  # create an empty set to hold next possible moves
  my SetHash[Point] $next-possible = SetHash[Point].new;

  for $possible.keys -> $previous {
    for next-state($previous) -> Point $p {
      # if the prospective point is inside the bounds of the valley
      # and will not be blocked by a blizzard this minute
      if $available (cont) $p and (not $not-possible (cont) $p) {
        $next-possible.set: $p;
      }
    }
  }

  if $trip-number == 1 and $next-possible (cont) $end {
    say "Finished first trip from $start to $end: $minute";
    $trip-number = 2;
    $next-possible = SetHash[Point].new: $end;
  }

  if $trip-number == 2 and $next-possible (cont) $start {
    say "Finished second trip from $end to $start: $minute";
    $trip-number = 3;
    $next-possible = SetHash[Point].new: $start;
  }

  if $trip-number == 3 and $next-possible (cont) $end {
    say "Finished third trip from $start to $end: $minute";
    last;
  }

  # update the possible states for the next minute
  $possible = $next-possible;
}