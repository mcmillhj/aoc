#!raku

class Point {
    has Int $.x;
    has Int $.y;

    method Str {
        self.x ~ "," ~ self.y;
    }

    method WHICH {
        self.Str
    }
}

sub infix:<north>(Point $a, Point $b) {
    $a.y <=> $b.y or $a.x <=> $b.x;
}

sub infix:<west>(Point $a, Point $b) {
    $a.x <=> $b.x or $a.y <=> $b.y;
}

sub infix:<east>(Point $a, Point $b) {
    $b.x <=> $a.x or $a.y <=> $b.y;
}

sub infix:<south>(Point $a, Point $b) {
    $b.y <=> $a.y or $b.x <=> $a.x;
}

class Direction {
    has Int $.x;
    has Int $.y;
    has Sub $.bound;

    method Str {
        self.x ~ "," ~ self.y;
    }

    method WHICH {
        self.Str
    }
}

my %control-panel{Point};
my $WIDTH = -1;
my $HEIGHT = -1;
for $*IN.lines>>.comb.kv -> $y, @panel-row {
    $HEIGHT max= $y;
    for @panel-row.kv -> $x, $tile {
        $WIDTH max= $x;
        %control-panel{Point.new(x => $x, y => $y)} = $tile;
    }
}

my $NORTH = Direction.new(x =>  0, y => -1, bound => sub (Point $p) { $p.y >= 0 });
my $SOUTH = Direction.new(x =>  0, y => +1, bound => sub (Point $p) { $p.y < $HEIGHT + 1 });
my $EAST = Direction.new(x => +1, y =>  0, bound => sub (Point $p) { $p.x < $WIDTH + 1 });
my $WEST = Direction.new(x => -1, y =>  0, bound => sub (Point $p) { $p.x >= 0 });

sub roll(Point @rocks, Direction $direction) {
    my @to-move = @rocks;
    while (my $rock = @to-move.shift) {
        my $previous-coordinates = $rock;
        my $new-coordinates = Point.new(
            x => $previous-coordinates.x + $direction.x,
            y => $previous-coordinates.y + $direction.y
        );

        while $direction.bound.($new-coordinates) and %control-panel{$new-coordinates} ne 'O' and %control-panel{$new-coordinates} ne '#' {
            %control-panel{$new-coordinates} = %control-panel{$previous-coordinates}:delete;
            %control-panel{$previous-coordinates} = '.';

            $previous-coordinates = $new-coordinates;
            $new-coordinates = Point.new(
                x => $new-coordinates.x + $direction.x,
                y => $new-coordinates.y + $direction.y
            );
        }
    }
}

sub cycle(%control-panel) {
    my @directions = [$NORTH, $WEST, $SOUTH, $EAST];

    
    for @directions -> $direction {
        # get rock positions
        my Point @rounded-rocks = %control-panel.grep(-> (:$key, :$value) { $value eq 'O' }).map(-> (:$key, :$value) { $key });

        # organize the rocks so the ones closest to the desired direction move first
        # i.e. when we want to move all of the rocks WEST start moving the most EASTWARD
        # rocks first to avoid collisions
        given $direction {
            when $NORTH { @rounded-rocks .= sort(&[north]); }
            when $WEST  { @rounded-rocks .= sort(&[west]); }
            when $SOUTH { @rounded-rocks .= sort(&[south]); }
            when $EAST  { @rounded-rocks .= sort(&[east]); }
        }
        
        # tilt the panel in the specified direction
        roll(@rounded-rocks, $direction);
    }
}

sub total-support-load(%control-panel) {
    [+] %control-panel.keys
        .grep(-> $point { %control-panel{$point} eq 'O' })
        .map(-> $point { $HEIGHT + 1 - $point.y });
}

sub encode(%control-panel) {
    my @rows = (0) xx $WIDTH;
    for (0..^$HEIGHT+1) -> $y {
        for (0..^$WIDTH+1) -> $x {
            my $v = %control-panel{Point.new(x => $x, y => $y)};
            @rows[$y] +=
                2**$x * ($v eq 'O' ?? 1 !! 0);
        }
    }

    return @rows.join(',');
}

{
    my %part1-control-panel{Point} = %control-panel.deepmap(-> $entry is copy { $entry });
    my Point @rounded-rocks = %control-panel.grep(-> (:$key, :$value) { $value eq 'O' }).map(-> (:$key, :$value) { $key });
    @rounded-rocks .= sort(&[north]);
    roll(@rounded-rocks, $NORTH);

    say "Part 1: " ~ total-support-load(%part1-control-panel);
}

# part 2
{
    my %seen;
    my $target = 10**9;
    loop (my $cycle-number = 1; $cycle-number <= $target; $cycle-number++) {
        say "Starting cycle $cycle-number...";

        cycle(%control-panel);

        my $encoding = encode(%control-panel);
        if %seen{$encoding} {
            my $cycle-length = $cycle-number - %seen{$encoding};
            $cycle-number = $target - ($target - $cycle-number) mod $cycle-length;
        }

        %seen{$encoding} = $cycle-number;
    }

    say "Part 2: " ~ total-support-load(%control-panel);
}