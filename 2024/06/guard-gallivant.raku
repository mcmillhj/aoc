#!raku

enum Direction <UP DOWN LEFT RIGHT>;

class Point {
    has Int $.x is rw;
    has Int $.y is rw;

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

sub turn-right(Direction $d) {
    given $d {
        when UP    { RIGHT }
        when RIGHT { DOWN  }
        when DOWN  { LEFT  }
        when LEFT  { UP    }
    }
}

sub move(Point $position, Direction $d --> Point) {
    given $d {
        when UP    { Point.new(x => $position.x, y => $position.y - 1) }
        when RIGHT { Point.new(x => $position.x + 1, y => $position.y) }
        when DOWN  { Point.new(x => $position.x, y => $position.y + 1) }
        when LEFT  { Point.new(x => $position.x - 1, y => $position.y) }
    } 
}


constant $GUARD = '^';
my Str %lab{Point};
my Point $guard-starting-position;
my Direction $guard-starting-direction = UP;
for $*IN.lines.kv -> $y, $line {
    for $line.comb.kv -> $x, $c {
        my $p = Point.new(x => $x, y => $y);

        # record guard starting position
        if $c eq $GUARD {
            $guard-starting-position = $p;
        }

        %lab{$p} = $c;
    }
}

sub patrol(%map, Point $starting-position, Direction $starting-direction) {
    my Point $current-position = $starting-position;
    my Direction $current-direction = $starting-direction;
    my Bool $guard-left-map = False;
    my %patrol-path{Point};

    # keep patrolling while the guard is still on the map 
    while %map{$current-position}:exists and not %patrol-path{$current-position}{$current-direction} {
        # add current position to the list of patrolled tiles
        %patrol-path{$current-position}{$current-direction} = True;

        # calculate a new position based on the current direction
        my $new-position = move($current-position, $current-direction);

        # stop if the guard walks out of the lab
        if not %map{$new-position}:exists {
            $guard-left-map = True;
            last;
        }

        # if moving in the current direction would encounter an obstacle, turn right
        if %map{$new-position} eq '#' {
            $current-direction = turn-right($current-direction);
        } 
        # move 1 space in the current direction
        else {
            $current-position = $new-position;
        }
    }

    return $guard-left-map, %patrol-path.keys;
}

my Point @patrol-path = patrol(%lab, $guard-starting-position, $guard-starting-direction)[1];
say @patrol-path.elems;

# attempt to place an obstruction at each place in the guard's patrol path and check whether the guard enters a loop
my $loop-count = 0;
for @patrol-path -> Point $p {
    # cannot place an obstruction at the guard's starting position
    next if $p eq $guard-starting-position;

    # replace the current path point with an obstruction
    my $original-tile = %lab{$p};
    %lab{$p} = '#';

    # patrol the modified lab
    my ($guard-left-map, @path) = patrol(%lab, $guard-starting-position, $guard-starting-direction);

    if not $guard-left-map {
        $loop-count++;
    }

    # restore lab to original state
    %lab{$p} = $original-tile;
}

say $loop-count;
