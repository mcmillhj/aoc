#!raku

use Algorithm::MinMaxHeap;

class Direction {
    has Int $.x;
    has Int $.y;
    has Str $.name;

    method Str {
        self.name
    }

    method WHICH {
        self.Str
    }
}

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

my $UP = Direction.new(x =>  0, y => -1, name => "UP");
my $DOWN = Direction.new(x =>  0, y => +1, name => "DOWN");
my $RIGHT = Direction.new(x => +1, y =>  0, name => "RIGHT");
my $LEFT = Direction.new(x => -1, y =>  0, name => "LEFT");

my %map{Point};
my $WIDTH = -1;
my $HEIGHT = -1;
for $*IN.lines>>.comb.kv -> $y, @block {
    $HEIGHT max= $y;
    for @block.kv -> $x, $heat-loss-from-block {
        $WIDTH max= $x;
        %map{Point.new(x => $x, y => $y)} = $heat-loss-from-block.Int;
    }
}

sub turn-right(Direction $d) {
    given $d {
        when $UP    { return $RIGHT }
        when $DOWN  { return $LEFT  }
        when $LEFT  { return $UP    }
        when $RIGHT { return $DOWN  }
    }
}

sub turn-left(Direction $d) {
    given $d {
        when $UP    { return $LEFT  }
        when $DOWN  { return $RIGHT }
        when $LEFT  { return $DOWN  }
        when $RIGHT { return $UP    }
    }
}

sub min-heat-loss(Point $start, Point $stop, Int $min, Int $max) {
    my SetHash[Str] $seen = SetHash[Str].new;
    my $heap = Algorithm::MinMaxHeap[Any].new;
    $heap.insert: (0, $start, $DOWN);
    $heap.insert: (0, $start, $RIGHT);

    my $iterations = 0;
    while not $heap.is-empty {
        # get the next possible move with the lowest heat loss
        my ($current-heat-loss, $position, $direction) = $heap.pop-min;
        say "Evaluating position $position..." if $iterations++ % 500 == 0;

        # stop once we have found the goal position
        if ~$position eq ~$stop {
            return $current-heat-loss;
        }

        # if we have already entered this block from this direction, ignore
        # it shouldn't be possible to have a minimal path with a loop
        if $seen{~$position ~ ":" ~ ~$direction} {
            next;
        }

        # mark that we have seen this combination of position + direction
        $seen.set: ~$position ~ ":" ~ ~$direction;

        # turn left or right based on the currrent direction
        for turn-left($direction), turn-right($direction) -> Direction $next-direction {
            # model walking a minimum of $min and maximum of $max steps from the current position
            for $min..$max -> $step {
                my $next-position = Point.new(
                    x => $position.x + $next-direction.x * $step,
                    y => $position.y + $next-direction.y * $step
                );

                # filter out invalid blocks
                if %map{$next-position}:exists {
                    # collect the total heat loss when moving from the current position
                    # to current position + $step
                    my $heat-loss-from-move = [+] (1..$step).map(-> $substep {
                            %map{
                                Point.new(
                                    x => $position.x + $next-direction.x * $substep,
                                    y => $position.y + $next-direction.y * $substep
                                )
                            }
                        });

                    # add new paths with the aggregated heat loss
                    $heap.insert: (
                        $current-heat-loss + $heat-loss-from-move,
                        $next-position,
                        $next-direction
                    );
                }
            }
        }
    }
}

my $starting-point = Point.new(x => 0, y => 0);
my $stopping-point = Point.new(x => $WIDTH, y => $HEIGHT);
dd $starting-point;
dd $stopping-point;

# say "Part 1: "
#     ~ min-heat-loss($starting-point, $stopping-point, 1, 3);
say "Part 2: "
    ~ min-heat-loss($starting-point, $stopping-point, 4, 10);

