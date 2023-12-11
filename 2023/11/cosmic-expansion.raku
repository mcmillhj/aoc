#!raku

class Point {
    has Int $.x;
    has Int $.y;

    method distance(Point $other) {
        abs(self.y - $other.y) + abs(self.x - $other.x);
    }

    method Str {
        "(" ~ self.x ~ ", " ~ self.y ~ ")";
    }
}

subset Pixel where * ~~ "#" | ".";

sub is-galaxy(Pixel $p) { $p eq '#' }

# assume that all rows and columns are empty space by default 
# (999 was an arbitrary number)
my SetHash[Int] $empty-space-x = SetHash[Int].new: 0..999;
my SetHash[Int] $empty-space-y = SetHash[Int].new: 0..999;
my Pixel %galaxies{Point};
for $*IN.lines.kv -> $y, $line {
    for $line.comb.kv -> $x, Pixel $pixel {
        if is-galaxy($pixel) {
            %galaxies{Point.new(x => $x, y => $y)} = $pixel;

            # when we uncounter a galaxy unmark this row + column for expansion
            $empty-space-y.unset: $y;
            $empty-space-x.unset: $x;
        }
    }
}

sub expand(Hash[Pixel,Point] $galaxies is copy, Int:D $expansion-factor) {
    my Pixel %expanded-galaxies{Point};
    for $galaxies.keys -> Point $point {
        # expand the space between galaxies by determining how
        # many expansions occurred below the current galaxy's x,y coordinates
        my $expansions-below-y = ($empty-space-y.keys.grep: * < $point.y).elems;
        my $expansions-below-x = ($empty-space-x.keys.grep: * < $point.x).elems;
        if $expansions-below-y > 0 or $expansions-below-x > 0 {
            # in the event of expansion, delete the existing galaxy entry and make a new one
            # using the expanded coordinates
            %expanded-galaxies{
                Point.new(
                    y => $point.y + $expansions-below-y * ($expansion-factor - 1),
                    x => $point.x + $expansions-below-x * ($expansion-factor - 1)
                )
            } = $galaxies{$point}
        }
        else {
            %expanded-galaxies{$point} = %galaxies{$point};
        }
    }

    %expanded-galaxies;
}

for [2, 1_000_000].kv -> $part, $expansion-factor {
    say "Part " ~ $part + 1 ~ ": " ~ [+] expand(%galaxies, $expansion-factor).keys.combinations(2).map(-> ($p1, $p2) {
        $p1.distance($p2);
    })
}