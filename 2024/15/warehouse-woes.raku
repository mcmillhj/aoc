#!raku

enum Direction<UP RIGHT DOWN LEFT>;

our %DIRECTIONS = (
    UP    => [ -1, +0 ], # up
    RIGHT => [ +0, +1 ], # right
    DOWN  => [ +1, +0 ], # down
    LEFT  => [ +0, -1 ], # left
);

class Point {
    has Int $.x is rw;
    has Int $.y is rw;

    method range(Point $other) {
        my Point @range;

        my Range $x-range = min(self.x, $other.x) .. max(self.x, $other.x);
        my Range $y-range = min(self.y, $other.y) .. max(self.y, $other.y);

        for $x-range.list -> $x {
            for $y-range.list -> $y {
                @range.push: Point.new(x => $x, y => $y);
            }
        }

        @range;
    }

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

multi sub infix:<cmp>(Point $a, Point $b) {
    $a.x <=> $b.x or $a.y <=> $b.y;
}

class Robot {
    has Point $.position is rw;

    method Str { "Robot: " ~ self.position }
    method WHICH { self.Str }
}


my ($warehouse-map-str, $moves-str) = $*IN.slurp.split("\n\n");

sub is-robot(Str $s) { $s eq '@' }
sub is-wall(Str $s) { $s eq '#' }
sub is-box(Str $s) { $s eq 'O' }
sub is-free-space(Str $s) { $s eq '.' }

my $HEIGHT = -1;
my $WIDTH = -1;
my Str %warehouse{Point};
my Robot $robot;
for $warehouse-map-str.lines.kv -> $y, $line {
    $HEIGHT max= $y;
    for $line.comb.kv -> $x, $tile-type {
        $WIDTH max= $x;

        if is-robot($tile-type) {
            $robot = Robot.new(position => Point.new(x => $x, y => $y));
        }

        %warehouse{Point.new(x => $x, y => $y)} = $tile-type;
    }
}

my @moves = $moves-str.comb(/<[v ^ < >]>/).map: -> $m { 
    given $m {
        when '^' { UP }
        when '>' { RIGHT }
        when 'v' { DOWN }
        when '<' { LEFT }
    }
};

sub print-warehouse {
    for 0..$HEIGHT -> $y {
        for 0..$WIDTH -> $x {
            print %warehouse{Point.new(x => $x, y => $y)} ~ " ";
        }

        print "\n"
    }
}

print-warehouse();

for @moves.kv -> $i, $move {
    # say "ROBOT @ $robot, MOVE = $move";

    my ($dy, $dx) = %DIRECTIONS{$move};
    my $nx = $robot.position.x + $dx;
    my $ny = $robot.position.y + $dy;
    my $next-position = Point.new(x => $nx, y => $ny);

   

    # if the move would cause the robot to collide with a wall, do not move
    next if is-wall(%warehouse{$next-position});

    # if the the move would cause the robot to enter an empty space, move
    # no pushing required 
    if is-free-space(%warehouse{$next-position}) {
        %warehouse{$robot.position} = '.';
        $robot.position = $next-position;
        %warehouse{$next-position} = '@';

        # next;
    }

    # if the move would cause the robot to collide with a box, check if the box can be pushed
    # search in the current direction to the edge of the warehouse until a free space or a wall is encountered
    # if a wall is encountered first, do not move
    # if a free space is encountered first, push all boxes 1 space in the current direction
    if is-box(%warehouse{$next-position}) {
        my $found-wall = False;
        my $found-free-space = False; 

        my $search-position = $next-position;
        while not $found-wall and not $found-free-space {
            $search-position = Point.new(x => $search-position.x + $dx, y => $search-position.y + $dy);

            # ignore boxes
            next if is-box(%warehouse{$search-position});

            if is-wall(%warehouse{$search-position}) {
                $found-wall = True;
                last;
            }

            if is-free-space(%warehouse{$search-position}) {
                $found-free-space = True;
                last;
            }
        }

        if $found-wall {
            # found wall, stop searching
            # do not push any boxes
        }

        if $found-free-space {
            # found free space, push any boxes between $next-position and $search-position 1 space in the current direction

            my @range = $next-position.range($search-position);
            if $move eq Direction::RIGHT or $move eq Direction::DOWN {
                @range = @range.reverse;
            }
            for @range -> $p {
                %warehouse{$p} = %warehouse{Point.new(x => $p.x - $dx, y => $p.y - $dy)};
            }

            # after moving any boxes, move the robot
            %warehouse{$robot.position} = '.';
            $robot.position = $next-position;
            %warehouse{$next-position} = '@';
        }
    }

    # print-warehouse();
    # say '-' x 80;
}

# print-warehouse();

say [+] %warehouse.keys.grep(-> $p { is-box(%warehouse{$p}) }).map(-> Point $p { 100 * abs(0 - $p.y) + abs(0 - $p.x) });
