#!raku

use experimental :cached;

enum Direction <LEFT UP RIGHT DOWN>;
enum Turn <CLOCKWISE COUNTER-CLOCKWISE>;

class Point {
  has Int $.x is rw;
  has Int $.y is rw;

  method Str { self.x ~ ',' ~ self.y }
  method WHICH { self.Str }
}

my Str %board{Point};
my $direction = RIGHT;
my ($board-string, $command-string) = 'input.sample'.IO.slurp.split("\n\n");

for $board-string.split("\n").kv -> $row, $line {
  for $line.comb.kv -> $column, $v {
    next if $v eq " ";

    %board{Point.new(x => $row + 1, y => $column + 1)} = $v;
  }
}

my Point $position;
for 1 ..^ 1000 -> $y {
  my $p = Point.new(x => 1, y => $y);
  next unless %board{$p};

  $position = $p;
  last;
}

sub is-wall (Str $s) {
  $s eq '#'
}

sub max-y-for-row(Int $row) is cached {
  [max] %board.keys
          .grep(-> (:$x, :$y) { $x eq $row })
          .map(-> (:$x, :$y) { $y });
}

sub min-y-for-row(Int $row) is cached {
  [min] %board.keys
          .grep(-> (:$x, :$y) { $x eq $row })
          .map(-> (:$x, :$y) { $y });
}

sub max-x-for-column(Int $column) is cached {
  [max] %board.keys
          .grep(-> (:$x, :$y) { $y eq $column })
          .map(-> (:$x, :$y) { $x });
}

sub min-x-for-column(Int $column) is cached {
  [min] %board.keys
          .grep(-> (:$x, :$y) { $y eq $column })
          .map(-> (:$x, :$y) { $x });
}


sub move(Direction $current-direction, Int $amount) {
  return do given $current-direction {
    when LEFT {
      my $min-y-for-row = min-y-for-row($position.x);
      my $y-range-for-row =
        max-y-for-row($position.x) - $min-y-for-row + 1;

      for ^$amount {
        my $next-position = Point.new(
          x => $position.x,
          y => ($position.y - 1 - $min-y-for-row) mod $y-range-for-row + $min-y-for-row
        );

        # do not move if the next position is a wall
        last if is-wall(%board{$next-position});

        $position = $next-position;
      }

      return $position;
    }
    when UP {
      my $min-x-for-column = min-x-for-column($position.y);
      my $x-range-for-column =
        max-x-for-column($position.y) - $min-x-for-column + 1;

      for ^$amount {
        my $next-position = Point.new(
          x => ($position.x - 1 - $min-x-for-column) mod $x-range-for-column + $min-x-for-column,
          y => $position.y,
        );

        # do not move if the next position is a wall
        last if is-wall(%board{$next-position});

        $position = $next-position;
      }

      return $position;
    }
    when RIGHT {
      my $min-y-for-row = min-y-for-row($position.x);
      my $y-range-for-row =
        max-y-for-row($position.x) - $min-y-for-row + 1;

      for ^$amount {
        my $next-position = Point.new(
          x => $position.x,
          y => ($position.y + 1 - $min-y-for-row) mod $y-range-for-row + $min-y-for-row
        );

        # do not move if the next position is a wall
        last if is-wall(%board{$next-position});

        $position = $next-position;
      }

      return $position;
    }
    when DOWN {
      my $min-x-for-column = min-x-for-column($position.y);
      my $x-range-for-column =
        max-x-for-column($position.y) - $min-x-for-column + 1;

      for ^$amount {
        my $next-position = Point.new(
          x => ($position.x + 1 - $min-x-for-column) mod $x-range-for-column + $min-x-for-column,
          y => $position.y,
        );

        # do not move if the next position is a wall
        last if is-wall(%board{$next-position});

        $position = $next-position;
      }

      return $position;
    }
  }
}

sub change-direction(Direction $current-direction, Turn $turn --> Direction) {
  do given $current-direction, $turn {
    when LEFT,  CLOCKWISE         { UP    }
    when LEFT,  COUNTER-CLOCKWISE { DOWN  }
    when UP,    CLOCKWISE         { RIGHT }
    when UP,    COUNTER-CLOCKWISE { LEFT  }
    when RIGHT, CLOCKWISE         { DOWN  }
    when RIGHT, COUNTER-CLOCKWISE { UP    }
    when DOWN,  CLOCKWISE         { LEFT  }
    when DOWN,  COUNTER-CLOCKWISE { RIGHT }
  }
}

sub direction-value(Direction $d) {
  do given $d {
    when RIGHT { 0 }
    when DOWN  { 1 }
    when LEFT  { 2 }
    when UP    { 3 }
  }
}

my @commands = $command-string.split(/<[LR]>/, :v)>>.&infix:<~>;
repeat {
  my $command = @commands.shift;

  if $command eq 'L' or $command eq 'R' {
    $direction = change-direction(
      $direction,
      $command eq 'L' ?? COUNTER-CLOCKWISE !! CLOCKWISE
    );
  }
  else {
    $position = move($direction, $command.Int);
  }
} while @commands;

say 1000 * $position.x + 4 * $position.y + direction-value($direction);