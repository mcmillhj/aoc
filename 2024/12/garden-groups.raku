#!raku

enum Direction<TOP RIGHT BOTTOM LEFT>;
class Point {
    has Int $.x is rw;
    has Int $.y is rw;

    our @.directions = (
        [ -1, +0 ], # up
        [ +0, +1 ], # right
        [ +1, +0 ], # down
        [ +0, -1 ], # left
    );

    method neighbors {
        self.directions.map: -> ($dx, $dy) { 
            Point.new(x => self.x + $dx, y => self.y + $dy) 
        };
    }

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

multi sub infix:<cmp>(Point $a, Point $b) {
    $a.x <=> $b.x and $a.y <=> $b.y;
}

my $HEIGHT = -1;
my $WIDTH = -1;
my %garden{Point};
for $*IN.lines.kv -> $y, $line {
    $HEIGHT max= $y;
    for $line.comb.kv -> $x, $plant-type {
        $WIDTH max= $x;

        %garden{Point.new(x => $x, y => $y)} = $plant-type;
    }
}

# the perimeter of the region is the sum of its sides (before collapsing)
sub calculate-perimeter(Array[Point] %boundaries) {
    [+] %boundaries.keys.map: -> $d { %boundaries{$d}.elems };
}

sub calculate-sides(Array[Point] %boundaries) {
    my $sides = 0;

    for %boundaries.keys -> $direction {
        my $main-axis = ($direction eq Direction::LEFT or $direction eq Direction::RIGHT) ?? 'x' !! 'y';
        my $secondary-axis = ($direction eq Direction::LEFT or $direction eq Direction::RIGHT) ?? 'y' !! 'x';

        my @points = %boundaries{$direction}.sort({ 
            $^a."$main-axis"() <=> $^b."$main-axis"() 
                or $^a."$secondary-axis"() <=> $b."$secondary-axis"()
        });

        while @points.elems > 0 {
            # collapse garden plots along the main axis as long as consecutive plots only differ by 1 along the secondary axis
            # ex: a right boundary between 1,1 and 2,1 would collapse into a single side (main-axis=X, secondary-axis=Y)
            # ex: a bottom boundary between 1,1 and 1,2 would collapse into a single side (main-axis=Y, secondary-axis=X)
            while @points.elems > 1 
                and @points[0]."$main-axis"() == @points[1]."$main-axis"() 
                and @points[0]."$secondary-axis"() + 1 == @points[1]."$secondary-axis"() {
                shift @points;
            }

            # individual plot or collapsed sides count as a single side
            $sides++;

            # remove the remaining plot in the collapsed side or the individual plot
            shift @points;
        }
    }

    $sides;
}

sub find-regions {
    my $seen = SetHash[Point].new;
    my @regions;
    for %garden.kv -> $plot, $plant-type {
        # skip plots that we have already processed
        next if $seen{$plot}:exists;

        # mark that we have seen the current plot to avoid backtracking
        $seen.set: $plot;

        my $region = SetHash[Point].new;
        my @to-visit = $plot;
        my Array[Point] %boundaries;
        while @to-visit {
            my $current-plot = shift @to-visit;

            # add the current plot to the region
            $region.set: $current-plot;

            # check all neighboring plots for plots that have the same plant type
            for $current-plot.neighbors -> $n {                
                # calculate all boundaries in order to determine permiter + # of sides
                # allow the search to go outside of the garden by 1 in each direction to ensure that all
                # boundaries are captured
                if not %garden{$n}:exists or %garden{$current-plot} ne %garden{$n} {
                    if $n.x > $current-plot.x {
                        %boundaries{Direction::RIGHT}.push: $current-plot;
                    }
                    elsif $n.x < $current-plot.x {
                        %boundaries{Direction::LEFT}.push: $current-plot;
                    }
                    elsif $n.y > $current-plot.y {
                        %boundaries{Direction::BOTTOM}.push: $current-plot;
                    }
                    elsif $n.y < $current-plot.y {
                        %boundaries{Direction::TOP}.push: $current-plot;
                    }
                }

                # ignore neighboring plots that are not in the garden boundaries
                next unless %garden{$n}:exists;

                # ignore neighboring plots that have different plant types
                next unless %garden{$current-plot} eq %garden{$n};

                # ignore neighboring plots that have already been visited
                next if $seen{$n}:exists;

                # mark that we have visited the neighboring plot
                $seen.set: $n;

                # add the neighboring plot to the vist list to ensure its neighbors are visited
                @to-visit.append: $n;
            }
        }

        @regions.push: { 
            plant-type => $plant-type, 
            area       => $region.keys.elems, 
            perimeter  => calculate-perimeter(%boundaries), 
            sides      => calculate-sides(%boundaries) 
        };
    }

    return @regions;
}

my @regions = find-regions;
say [+] @regions.map: -> $r { $r<area> * $r<perimeter> };
say [+] @regions.map: -> $r { $r<area> * $r<sides> };