#!raku

class Point {
    has Int $.x;
    has Int $.y;

    our @directions = (
        [ -1, +0 ], # up
        [ +0, +1 ], # right
        [ +1, +0 ], # down
        [ +0, -1 ], # left
    );

    method manhattan-distance(Point $other --> Int) {
        abs(self.x - $other.x) + abs(self.y - $other.y);
    }

    method neighbors {
        @directions.map: -> ($dx, $dy) { Point.new(x => self.x + $dx, y => self.y + $dy) };
    }

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

my $HEIGHT = -1;
my $WIDTH = -1;
my $START = 'S';
my $GOAL = 'E';
my $START-POINT;
my $END-POINT;

my Str %track{Point};
for $*IN.lines.kv -> $y, $line {
    $HEIGHT max= $y;
    for $line.comb.kv -> $x, $c {
        $WIDTH max= $x;

        if $c eq $START {
            $START-POINT = Point.new(x => $x, y => $y);
        } 

        if $c eq $GOAL {
            $END-POINT = Point.new(x => $x, y => $y);
        }

        %track{Point.new(x => $x, y => $y)} = $c;
    }
}

sub race(%track, Point $start-point, Str $goal) {
    my @to-visit = ([$start-point, $start-point],);
    my Int %costs{Point} is default(0);
    %costs{$START-POINT} = 0;

    while @to-visit {
        my ($source, @path) = @to-visit.shift();

        # stop searching once we have found our goal node
        return %costs, @path if %track{$source} eq $goal;

        for $source.neighbors -> $target {
            my $new-cost = %costs{$source} + 1;

            # ignore moves that would leave the track or collide with a wall
            next unless %track{$target}:exists;
            next if %track{$target} eq '#';

            # if the target node has not been visited or has been visited but this path has a lower cost
            # update the cost for the target and add the target to the visited set
            if not %costs{$target}:exists or $new-cost < %costs{$target} {
                %costs{$target} = $new-cost;

                @to-visit.push: [$target, |(@path, $target).flat];
            }
        }
    }

    return {}, [];
}


my (%costs, @path) := race(%track, $START-POINT, $GOAL);
my $lowest-non-cheating-score = %costs{$END-POINT};

sub count-cheats__bridges(@path, Int $picoseconds-to-save) {
    # follow the shortest path without cheating and collect all walls along the path
    # that could potentially be used for shortcuts
    sub map-walls(%track, @path) {
        my $s = SetHash[Point].new: @path
            .flatmap(-> $p { $p.neighbors })
            .grep(-> $p { %track{$p} eq '#' and 0 < $p.x < $WIDTH and 0 < $p.y < $HEIGHT });
        
        $s.keys
    }
    
    # given a wall determine if it bridges two points on the valid path
    sub find-bridge(@path, $wall) {
        my @possible-bridge = $wall.neighbors.grep(-> $n { %track{$n} ne '#' });
        
        return []
            if @possible-bridge.elems < 2;

        # if there are 3 neighboring points on the path, this wall must be a corner
        # e.g. .#.
        #      X.X
        # the two points that are connected will share either the same X or Y coordinate
        if @possible-bridge.elems > 2 {
            @possible-bridge.classify({ $_.x }, :into( my %by-x{Int} ));
            @possible-bridge.classify({ $_.y }, :into( my %by-y{Int} ));
            my @horizontal-bridge := %by-x.values.first(*.elems == 2) // [];
            my @vertical-bridge := %by-y.values.first(*.elems == 2) // [];

            if @horizontal-bridge {
                @possible-bridge := @horizontal-bridge
            }
            if @vertical-bridge {
                @possible-bridge := @vertical-bridge;
            }
        }

        my @bridge = @path.grep({ $_ eq @possible-bridge[0] or $_ eq @possible-bridge[1] });
        return @bridge;
    }

    my @walls-along-path = map-walls(%track, @path);
    my Array[Point] %costs-without-wall{Int};
    for @walls-along-path -> $wall {
        my @bridge = find-bridge(@path, $wall);
        next unless @bridge.elems == 2;

        # check if racing without this wall results in a shorter number of picoseconds
        my $cost-without-wall = $lowest-non-cheating-score - (%costs{@bridge[1]} - %costs{@bridge[0]} - 2);
        if $cost-without-wall < $lowest-non-cheating-score {
            %costs-without-wall{$cost-without-wall}.push: $wall;
        }        
    }

    my $cheats = 0;
    for %costs-without-wall.kv -> $cost, @walls {
        next unless $lowest-non-cheating-score - $cost >= $picoseconds-to-save;

        $cheats += @walls.elems;
    }

    $cheats;
}


sub count-cheats__distance(@path, Int $picoseconds-to-save, Int $max-cheat-length) {
    my $cheats = 0;

    # only the first (length - $picoseconds-to-save) elements can possibly start a cheat
    # additionally, the only place for those cheats to end it at least $picoseconds-to-save
    # elements _AFTER_ the current index
    for @path[0 .. * - $picoseconds-to-save].kv -> $i, $p1 {
        for @path[$i + $picoseconds-to-save .. * - 1].kv -> $j, $p2 {
            # calculate the distance between p1 + p2
            my $distance = $p2.manhattan-distance($p1);

            # ignore cheats that exceed the maximum cheat length
            next unless $distance <= $max-cheat-length;

            # distance must be <= $j to ensure that at least $picoseconds-to-save picoseconds are saved
            # e.g. If the goal is to save 10 picoseconds and $i = 14, $j = 24 but the distance between $p1 and $p2 is 2 then only
            # 8 picoseconds would be saved 24 - 14 - 2 = 8 
            next unless $distance <= $j;

            $cheats++;
        }
    }

    $cheats;
}

say count-cheats__bridges(@path, 100);
say count-cheats__distance(@path, 100, 20);
