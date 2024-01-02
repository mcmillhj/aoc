#!raku

use lib '..';
use AOCUtils;

class Brick {
    has Point3D $.start;
    has Point3D $.end;

    method WHICH {
        self.Str
    }

    method Str {
        self.start ~ "~" ~ self.end
    }

    method clone {
        Brick.new(
            start => Point3D.new(
                x => self.start.x, 
                y => self.start.y, 
                z => self.start.z
            ),
            end => Point3D.new(
                x => self.end.x, 
                y => self.end.y, 
                z => self.end.z
            ),
        );
    }
}

sub infix:<zsort>(Brick $a, Brick $b) {
    $a.start.z <=> $b.start.z
}

# collect all of the bricks from the input and order them by their Z coordinate
my Brick @bricks = $*IN.lines>>.comb(/\d+/)>>.Int.map(-> ($x1, $y1, $z1, $x2, $y2, $z2) {
    Brick.new(
        start => Point3D.new(x => $x1, y => $y1, z => $z1),
        end   => Point3D.new(x => $x2, y => $y2, z => $z2),
    );
}).sort(&[zsort]);

sub fall(Brick @bricks --> Int) {
    my Int %tallest-points{Point};
    my Int $fall-count = 0;

    for @bricks.kv -> $brick-index, $brick {
        # the height of the brick in the z dimension
        my $delta-z = $brick.end.z - $brick.start.z;

        # find the highest Z for all points along the cube
        my @points = (
            ($brick.start.x..$brick.end.x) X ($brick.start.y..$brick.end.y)
        ).map(-> ($x, $y) { Point.new(x => $x, y => $y) });
        my $tallest-point = 1 + max (%tallest-points{$_} // 0 for @points);

        # update the Z mapping to map all of the points on this cube to the new highest point
        for @points -> $p { 
            %tallest-points{$p} = $tallest-point + $delta-z;
        }

        # update the brick using the new Z values (start Z = tallest point found, end Z = height of the brick)
        @bricks[$brick-index] = Brick.new(
            start => Point3D.new(x => $brick.start.x, y => $brick.start.y, z => $tallest-point),
            end   => Point3D.new(x => $brick.end.x, y => $brick.end.y, z => $tallest-point + $delta-z),
        );

        # if the tallest Z for this brick is lower than the starting Z this brick has shifted
        $fall-count += $tallest-point < $brick.start.z;
    }

    $fall-count;
}


# settle all of the bricks
fall(@bricks);

# simulate removing a brick to test if any bricks would fall as a result of Brick $i not being present
# if no bricks fall, then this brick can be disentegrated safely 
my Int @fallen-bricks = @bricks.keys.map(-> $i { 
    my Brick @bricks-without-i = (@bricks[0 .. $i - 1], @bricks[$i + 1 .. * - 1]).flat.map(-> Brick $b { $b.clone });

    fall(@bricks-without-i);
});

say "Part 1: " ~ @fallen-bricks.grep(* == 0).elems;
say "Part 2: " ~ [+] @fallen-bricks;
