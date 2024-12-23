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

    method neighbors {
        @directions.map: -> ($dx, $dy) { Point.new(x => self.x + $dx, y => self.y + $dy) };
    }

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

my $HEIGHT = -1;
my $WIDTH = -1;

my @corrupted-coordinates = $*IN.lines>>.comb(/\d+/)>>.Int.map(-> ($x, $y) {
    $HEIGHT max= $y + 1;
    $WIDTH max= $x + 1;

    Point.new(x => $x, y => $y);
});


sub djikstra(%memory-space, $start-point, $goal) {
    my @visited = ($start-point,);
    my Int %costs{Point} is default(0);

    while @visited {
        my $source = @visited.shift();

        # stopping searching once we have found our goal node
        return %costs if $source eq $goal;

        for $source.neighbors -> $target {
            my $new-cost = %costs{$source} + 1;

            # ignore possible moves that would enter a corrupted coordinate
            next if %memory-space{$target}:exists and %memory-space{$target} eq '#';

            # ignore moves that would leave the memory space
            next unless (0 <= $target.x <= $WIDTH - 1) and (0 <= $target.y <= $HEIGHT - 1);

            # if the target node has not been visited or has been visited but this path has a lower cost
            # update the cost for the target and add the target to the visited set
            if not %costs{$target}:exists or $new-cost < %costs{$target} {
                %costs{$target} = $new-cost;

                @visited.push: $target;
            }
        }
    }

    %costs;
}


sub simulate(Int $n) {
    my $START = 'S';
    my $GOAL = 'E';
    my $START-POINT = Point.new(x => 0, y => 0);
    my $END-POINT = Point.new(x => $WIDTH - 1, y => $HEIGHT - 1);
    my %memory-space{Point};
    
    # apply corruption to the first N coordinates
    for @corrupted-coordinates[0 ..^ $n] -> $corrupted-coordinate {
        %memory-space{$corrupted-coordinate} = '#'
    }

    %memory-space{$START-POINT} = 'S';
    %memory-space{$END-POINT} = 'E';

    my %costs = djikstra(%memory-space, $START-POINT, $GOAL);
    return %costs{$END-POINT};
}

sub sliding-search(@corrupted-coordinates) {
    my $low = 0;
    my $high = @corrupted-coordinates.elems - 1;

    while $low <= $high {
        my $mid = floor($low + (($high - $low) / 2));
        my $escape-path = simulate($mid);

        # if there is a path to the exit, we have not found the coordinate that blocks all paths
        # continue searching
        if $escape-path {
            $low = $mid + 1;
        }
        # if the current coordinate does NOT allow an escape path but the previous coordinate does
        # the previous coordinate is LAST coordinate that can be corrupted and still allow an escape
        elsif simulate($mid - 1) {
            return @corrupted-coordinates[$mid - 1];
        }
        # continue searching
        else {
            $high = $mid - 1;
        }
    }

    return -1;
}


say simulate(min(1024, @corrupted-coordinates.elems));
say ~sliding-search(@corrupted-coordinates);


