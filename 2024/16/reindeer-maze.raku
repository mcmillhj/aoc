#!raku

enum Direction <NORTH EAST SOUTH WEST>;
constant %DIRECTION-MAP = (
    NORTH => [ +0, -1 ],
    EAST  => [ +1, +0 ], 
    SOUTH => [ +0, +1 ],
    WEST  => [ -1, +0 ],
);

sub clockwise(Direction $d --> Direction) {
    given $d {
        when NORTH { EAST  }
        when EAST  { SOUTH }
        when SOUTH { WEST  }
        when WEST  { NORTH }
    }
}

sub counter-clockwise(Direction $d --> Direction) {
    given $d {
        when NORTH { WEST  }
        when EAST  { NORTH }
        when SOUTH { EAST  }
        when WEST  { SOUTH }
    }
}


class Point {
    has Int $.x;
    has Int $.y;

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

my $START = 'S';
my $GOAL = 'E';
my $START-POINT;
my $END-POINT;

my Str %maze{Point};
for $*IN.lines.kv -> $y, $line {
  for $line.comb.kv -> $x, $c {
    next if $c eq '#'; # ignore walls

    if $c eq $START {
      $START-POINT = Point.new(x => $x, y => $y);
    } 

    if $c eq $GOAL {
      $END-POINT = Point.new(x => $x, y => $y);
    }

    %maze{Point.new(x => $x, y => $y)} = $c;
  }
}

class Vector {
    has Point $.position is rw;
    has Direction $.direction is rw;

    method Str   { self.position ~ ":" ~ self.direction }
    method WHICH { self.Str }
}

sub djikstra($start-point) {
    my @to-visit = ([0, $start-point, Direction::EAST, $start-point],);
    my Int %costs{Vector} is default(2**32);
    my $lowest-cost = 2**32;
    my $visited = SetHash[Point].new;

    while @to-visit {
        # Raku unfortunately does not have a min-heap data structure
        # emulate it by ordering the @to-visit array by current cost
        # this is expensive :(
        @to-visit = @to-visit.sort({ $^a[0] <=> $^b[0] });
        my ($current-cost, $current-tile, $current-direction, @path) = @to-visit.shift();

        # track distance by a combination of position + direction to avoid intersecting 
        # paths overwriting each other
        my $v = Vector.new(position => $current-tile, direction => $current-direction);

        # if traveling this path would cost most the current position + direction cost
        # stop following
        next if $current-cost > %costs{$v};
        %costs{$v} = $current-cost;

        # if we have reached the goal tile and have a lower cost
        # record the score (part 1)
        # record all unique positions seen on this path (part 2)
        if %maze{$current-tile} eq $GOAL and $current-cost <= $lowest-cost {
            $visited.set: @path;
            $lowest-cost = $current-cost;
        }

        # combine turns with taking a step forward (1000 + 1)
        for ($current-direction, 1), 
            (clockwise($current-direction), 1001), 
            (counter-clockwise($current-direction), 1001) -> ($target-direction, $cost) {
            my $delta = %DIRECTION-MAP{$target-direction};
            my $target-tile = Point.new(x => $current-tile.x + $delta[0], y => $current-tile.y + $delta[1]);

            # ignore possible moves that are not valid spaces in the maze
            next unless %maze{$target-tile}:exists;

            # calculate the cost of moving to $target-tile
            my $new-cost = $current-cost + $cost;
            # add $target-tile to the todo list
            @to-visit.push: [$new-cost, $target-tile, $target-direction, |(@path, $target-tile).flat];
        }
    }
    
    $lowest-cost, $visited.keys.elems
}

say djikstra($START-POINT);