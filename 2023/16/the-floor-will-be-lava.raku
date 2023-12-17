#!raku

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

multi sub infix:<cmp>(Point $a, Point $b) {
    $a.x <=> $b.x or $a.y <=> $b.y;
}

class Direction {
    has Int $.x;
    has Int $.y;
    has Str $.name;
    has Sub $.bound;

    method Str {
        self.name
    }

    method WHICH {
        self.Str
    }
}

class Vector {
    has Point $.position;
    has Direction $.direction is rw;

    method can-move {
        self.direction.bound.(self.position);
    }

    method move {
        self.position.x += self.direction.x;
        self.position.y += self.direction.y;
    }

    method turn(Direction $d) {
        self.direction = $d;
    }

    method new-from-vector(Vector $other) {
        Vector.new(
            position  => Point.new(x => $other.position.x, y => $other.position.y),
            direction => $other.direction
        );
    }

    method Str {
        ~self.position ~ ":" ~ ~self.direction;
    }

    method WHICH {
        self.Str
    }
}

my %contraption{Point};
my $WIDTH = -1;
my $HEIGHT = -1;
for $*IN.lines>>.comb.kv -> $y, @contraption-row {
    $HEIGHT max= $y;
    for @contraption-row.kv -> $x, $tile {
        $WIDTH max= $x;
        %contraption{Point.new(x => $x, y => $y)} = { energized => False, value => $tile };
    }
}

my $UP = Direction.new(x =>  0, y => -1, name => "UP", bound => sub (Point $p) { $p.y >= 0 });
my $DOWN = Direction.new(x =>  0, y => +1, name => "DOWN", bound => sub (Point $p) { $p.y <= $HEIGHT  });
my $RIGHT = Direction.new(x => +1, y =>  0, name => "RIGHT", bound => sub (Point $p) { $p.x <= $WIDTH });
my $LEFT = Direction.new(x => -1, y =>  0, name => "LEFT", bound => sub (Point $p) { $p.x >= 0 });

sub mark-as-energized(Point $p) {
    return unless %contraption{$p}:exists;

    %contraption{$p}<energized> = True;
}

# model projecting a vector through the contraption
sub project(Vector $v, Hash[Any,Point] $contraption is copy) {

    my SetHash[Vector] $seen = SetHash[Vector].new;
    my $project-through = sub (Vector $v) {
        while $v.can-move and not $seen{$v}:exists {
            # mark that we have seen this vector (position + direction)
            $seen.set: Vector.new-from-vector($v);

            # move 1 space in the current direction
            $v.move;

            # get the current tile
            my $tile = %contraption{$v.position};

            given $tile<value> {
                when "."  {
                    # if you encounter empty space, keep going the same direction
                }
                when "/"  {
                    # if you encounter a mirror turn based on the current direction

                    given $v.direction {
                        when $UP    { $v.turn($RIGHT); }
                        when $DOWN  { $v.turn($LEFT);  }
                        when $LEFT  { $v.turn($DOWN);  }
                        when $RIGHT { $v.turn($UP);    }
                    }
                }
                when "\\" {
                    # if we encounter a mirror turn based on the current direction

                    given $v.direction {
                        when $UP    { $v.turn($LEFT);  }
                        when $DOWN  { $v.turn($RIGHT); }
                        when $LEFT  { $v.turn($UP);    }
                        when $RIGHT { $v.turn($DOWN);  }
                    }
                }
                when "-"  {
                    # project two new vectors traveling left and right from the current
                    # vector position if the current direction is up or down

                    if $v.direction eq $UP or $v.direction eq $DOWN {
                        $project-through.(Vector.new(position => Point.new(x => $v.position.x, y => $v.position.y), direction => $LEFT));
                        $project-through.(Vector.new(position => Point.new(x => $v.position.x, y => $v.position.y), direction => $RIGHT));

                        # stop projecting in this direction after splitting the light source
                        last;
                    }
                }
                when "|"  {
                    # project two new vectors traveling up and down from the current
                    # vector position if the current direction is left or right

                    if $v.direction eq $LEFT or $v.direction eq $RIGHT {
                        $project-through.(Vector.new(position => Point.new(x => $v.position.x, y => $v.position.y), direction => $UP));
                        $project-through.(Vector.new(position => Point.new(x => $v.position.x, y => $v.position.y), direction => $DOWN));

                        # stop projecting in this direction after splitting the light source
                        last;
                    }
                }
            }
        }
    }

    $project-through($v);

    $seen.keys>>.position.unique.elems - 1;
}

say "Part 1: " ~
    project(
        Vector.new(position  => Point.new(x => -1, y => 0), direction => $RIGHT),
        %contraption
    );

say "Part 2:" ~
    [max] [
        # right
        [(0..$HEIGHT).map(-> $y { Point.new(x => -1, y => $y ) }), $RIGHT],
        # left
        [(0..$HEIGHT).map(-> $y { Point.new(x => $WIDTH + 1, y => $y ) }), $LEFT],
        # down
        [(0..$WIDTH).map(-> $x { Point.new(x => $x, y => -1 ) }), $DOWN],
        # up
        [(0..$WIDTH).map(-> $x { Point.new(x => $x, y => $HEIGHT + 1 ) }), $UP]
    ].flatmap(-> [@starting-points, Direction $d] {
        @starting-points.map(-> Point $starting-point {
            project(Vector.new(position => $starting-point, direction => $d), %contraption);
        })
    });