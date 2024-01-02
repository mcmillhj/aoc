#!raku

use lib '..';
use AOCUtils;

class Point {
    has Int $.x is rw;
    has Int $.y is rw;

    method Str {
        self.x ~ "," ~ self.y;
    }

    method WHICH {
        self.Str
    }
}

my $WIDTH = -1;
my $HEIGHT = -1;
my $starting-position = (-1, -1);
my %rocks;
for $*IN.lines>>.comb.kv -> $y, @map-row {
    $HEIGHT max= $y + 1;
    for @map-row.kv -> $x, $map-tile {
        $WIDTH max= $x + 1;
        if $map-tile eq '#' {
            %rocks{Point.new(x => $x, y => $y)} = '#';
        }

        if $map-tile eq 'S' {
            $starting-position = Point.new(x => $x, y => $y);
        }
    }
}
my $HALF-WIDTH = $WIDTH div 2;

dd [%rocks.elems, $starting-position, $WIDTH, $HEIGHT];

my @directions = (
  [ -1, +0 ], # NORTH
  [ +0, +1 ], # EAST
  [ +1, +0 ], # SOUTH
  [ +0, -1 ], # WEST
);

sub is-rock(Point $p) {
    %rocks{$p}:exists;
}

sub next-steps(Point @positions) {
    @positions.flatmap(-> Point $position {
        @directions
            .map(-> [$dy, $dx] {
                Point.new(
                    x => ($position.x + $dx),
                    y => ($position.y + $dy)
                )
            })
            # bound points from the infinite grid onto the input
            # ignore rocks
            .grep(-> Point $p {
                not is-rock(
                    Point.new(x => $p.x % $WIDTH, y => $p.y % $HEIGHT)
                );
            });
    });
}

sub step(Int $max-steps) {
    my SetHash[Point] $todo = SetHash[Point].new: $starting-position;
    my Int %visited{Point};
    my @output;
    for ^($max-steps+1) -> $current-step {
        say "Starting step $current-step...";
        %visited{$_} = $current-step for $todo.keys;

        if $current-step % $WIDTH == $HALF-WIDTH {
            @output.push: $todo.elems;
        }

        my Point @to-eval = $todo.keys;
        $todo = SetHash[Point].new;
        $todo.set: next-steps(@to-eval);

    }

    @output;
}

# https://en.wikipedia.org/wiki/Newton_polynomial#Polynomial_interpolation
sub interpolate(
    Int $n,
    @xs where { @xs.elems == 3 },
    @ys where { @ys.elems == 3 },
) {
      @ys[0]
    + @ys[1] *            $n / (@xs[1] - @xs[0])
    + @ys[2] * $n * ($n - 1) / (@xs[2] - @xs[0]);
}

say interpolate(
    26501365 div 131, 
    [0, 1, 2], 
    successive-differences(
        # collect 4 points for interpolation
        step($HALF-WIDTH + 3 * $WIDTH)
    ).head(3).map(*.head)
);