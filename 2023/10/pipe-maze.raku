#!raku 

# NORTH = -y
# EAST  = +x
# SOUTH = +y
# WEST  = -x
enum Direction <NORTH EAST SOUTH WEST>;
constant %DIRECTION-MAP = (
    NORTH => (-1, 0),
    EAST  => (0, +1), 
    SOUTH => (+1, 0),
    WEST  => (0, -1),
);

constant %PIPE-TO-DIRECTION-MAP = (
    "|" => { NORTH => NORTH, SOUTH => SOUTH },
    "-" => { WEST => WEST, EAST => EAST },
    "L" => { WEST => NORTH, SOUTH => EAST },
    "J" => { EAST => NORTH, SOUTH => WEST },
    "7" => { EAST => SOUTH, NORTH => WEST },
    "F" => { WEST => SOUTH, NORTH => EAST },
);

subset Pipe where * ~~ "|" | "-" | "L" | "J" | "7" | "F";
my @tile-grid;
my %starting-tile;
my Pipe $starting-pipe;
my Direction $starting-direction;
for $*IN.lines.kv -> $y, $line {
    for $line.comb.kv -> $x, $tile {
        @tile-grid[$y][$x] = $tile;
        if $tile eq 'S' {
            %starting-tile = (x => $x, y => $y);
        }
    }
}

sub starting-pipe-and-direction(Int $x, Int $y) {
    my $can-move-north = so @tile-grid[$y-1][$x] eq ('|', '7', 'J').any;
    my $can-move-east = so @tile-grid[$y][$x+1] eq ('-', '7', 'J').any;
    my $can-move-south = so @tile-grid[$y+1][$x] eq ('|', 'L', 'J').any;
    my $can-move-west = so @tile-grid[$y][$x-1] eq ('-', 'L', 'F').any;

    given (
        [~] $can-move-north ?? 'NORTH' !! '', 
            $can-move-south ?? 'SOUTH' !! '', 
            $can-move-east ?? 'EAST' !! '', 
            $can-move-west ?? 'WEST' !! ''
    ) {
        # the starting direction is given from the POV of traveling toward the Tile
        # (e.g. if the starting tile is 'L' the possible starting directions are WEST or SOUTH
        # since those are the only directions that can move into an 'L' tile)
        when "NORTHSOUTH" { return '|', SOUTH }
        when "NORTHEAST"  { return 'L', SOUTH }
        when "SOUTHEAST"  { return 'F', NORTH }
        when "SOUTHWEST"  { return '7', NORTH }
        when "NORTHWEST"  { return 'J', SOUTH }
        when "EASTWEST"   { return '-', WEST  }
        default { say "SHOULD NOT BE HERE..." }
    }
}


($starting-pipe, $starting-direction) 
    = starting-pipe-and-direction(%starting-tile<x>, %starting-tile<y>);

# replace the 'S' Tile with the actual Tile it represents
@tile-grid[%starting-tile<y>][%starting-tile<x>] = $starting-pipe;

my %current = %starting-tile;
my Direction $direction = $starting-direction;
my Bool %visited;
repeat {
    # extract the current Tile
    my $pipe = @tile-grid[%current<y>][%current<x>];

    # mark this Tile as visited
    %visited{"Y=%current<y>,X=%current<x>"} = True;

    # change direction based on the type of Tile and the current direction
    $direction = %PIPE-TO-DIRECTION-MAP{$pipe}{$direction};

    # change x,y coordinates based on the new direction
    my ($dy, $dx) = %DIRECTION-MAP{$direction};
    %current<x> += $dx;
    %current<y> += $dy;
} until %current<x> == %starting-tile<x> and %current<y> == %starting-tile<y>;

say "Part 1: " ~ %visited.elems div 2;

# scan each line of tiles 
# when we encounter a vertical bar we can assume a direction (down) 
# if we encoutner another vertical bar the direction has to swap (up)
# because we are in a loop
my $enclosed-tiles = 0;
for ^@tile-grid.elems -> $y {
    my $is-enclosed = False; 
    for ^@tile-grid[0].elems -> $x {
        if %visited{"Y=$y,X=$x"} {
            if so @tile-grid[$y][$x] eq <L | J>.any {
                $is-enclosed = not $is-enclosed;
            }
        }
        else {
            $enclosed-tiles++ if $is-enclosed;
        }
    }
}

say "Part 2: " ~ $enclosed-tiles;
