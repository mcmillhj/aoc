#!raku

class Point {
    has Int $.x is rw;
    has Int $.y is rw;

    has @.directions = (
        [ -1, +0 ], # up
        [ +0, +1 ], # right
        [ +1, +0 ], # down
        [ +0, -1 ], # left
    );

    method neighbors {
        self.directions.map: -> ($dx, $dy) { Point.new(x => self.x + $dx, y => self.y + $dy) };
    }

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

multi sub infix:<==>(Point $a, Point $b) {
    return $a.x == $b.x and $a.y == $b.y;
}


my $HEIGHT = -1;
my $WIDTH = -1;
my Int %trail{Point};
my Point @trailheads;
for $*IN.lines.kv -> $y, $line {
    $HEIGHT max= $y;
    for $line.comb.kv -> $x, $c {
        $WIDTH max= $x;

        my $p = Point.new(x => $x, y => $y);
        %trail{$p} = $c.Int;
        if $c.Int == 0 {
            @trailheads.push: $p;
        }
    }
} 

my $distinct-hiking-trails = 0;
my @trail-scores;
for @trailheads -> $ps {
    my @to-visit = ($ps);
    my SetHash[Point] $visited = SetHash[Point].new;
    while (@to-visit) {
        my $p = pop @to-visit;

        # record paths that were able to reach the end of the trail
        if %trail{$p} == 9 {
            $distinct-hiking-trails++;
        }

        # mark this part of the trail as visited
        $visited.set: $p;

        for $p.neighbors -> $n {
            # ignore points that are not on the trail
            next unless %trail{$n}:exists;

            # ignore neighbors that do not have a gradual increase
            next unless %trail{$n} == %trail{$p} + 1;

            @to-visit.push: $n;
        }
    }

    @trail-scores.push: $visited.keys.grep(-> $p { %trail{$p} == 9 }).elems;
}

say [+] @trail-scores;
say $distinct-hiking-trails;