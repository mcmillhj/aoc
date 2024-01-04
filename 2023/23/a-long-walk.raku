#!raku

use lib '..';
use AOCUtils;

my $HEIGHT = -1;
my $WIDTH = -1;
my Str %map{Point};
for $*IN.lines>>.comb.kv -> $y, @map-row {
    $HEIGHT max= $y + 1;
    for @map-row.kv -> $x, $map-tile {
        $WIDTH max= $x + 1;
        %map{Point.new(x => $x, y => $y)} = $map-tile;
    }
}

my $UP    = Point.new(y => -1, x =>  0); # -Y
my $RIGHT = Point.new(y =>  0, x => +1); # +X
my $DOWN  = Point.new(y => +1, x =>  0); # +Y
my $LEFT  = Point.new(y =>  0, x => -1); # -X

my %directions = (
    '.' => [$UP, $RIGHT, $DOWN, $LEFT ],
    '^' => [$UP],
    '>' => [$RIGHT],
    'v' => [$DOWN],
    '<' => [$LEFT],
);

sub is-forest(Point $p) { %map{$p}:exists and %map{$p} eq '#' }
sub is-slope(Point $p) { so %map{$p} eq ('<','>','^','v').any }

sub neighbors(Point $p, Bool $has-slopes = True) {
    return %directions{$has-slopes ?? %map{$p} !! "."}
        .map(-> Point $d {
            Point.new(x => $p.x + $d.x, y => $p.y + $d.y);
        })
        .grep(-> Point $neighboring-point {
            # ensure that we do not leave the trail or enter a forest
                0 <= $neighboring-point.x < $WIDTH
            and 0 <= $neighboring-point.y < $HEIGHT
            and not is-forest($neighboring-point);
        })
}

my $starting-position = Point.new(x => 1, y => 0);
my $goal-position = Point.new(x => $WIDTH - 2, y => $HEIGHT - 1);

# modified BFS to find all viable paths from $start
sub build-trail-graph(Point $start, Bool $has-slopes = True) {
    my Point @todo = ($start);
    my SetHash[Point] $visited = SetHash[Point].new;
    my %trail-graph{Point};

    while @todo {
        my Point $node = @todo.shift;

        next if $node (elem) $visited;

        %trail-graph{$node} = [];

        # for each node determine how far we can travel to
        # stop at intersections and ignore dead ends
        for neighbors($node, $has-slopes) -> Point $neighbor {
            my $length = 1;
            my Point $previous-node = $node;
            my Point $current-node = $neighbor;
            my $is-dead-end = False;

            loop {
                my @neighbors = neighbors($current-node, $has-slopes);

                # if the current node is a slope that points backward to the previous node
                # we have encountered a dead end, stop searching
                if @neighbors.elems == 1 and @neighbors[0] eq $previous-node and is-slope($current-node) {
                    $is-dead-end = True;
                    last;
                }

                # when there is more than one viable path forward (intersection)
                # the search will start back from this node when the outer loop resumes
                if @neighbors.elems != 2 {
                    last;
                }

                for @neighbors -> Point $n {
                    if $n ne $previous-node {
                        $length += 1;
                        $previous-node = $current-node;
                        $current-node = $n;
                        last;
                    }
                }
            }

            # ignore paths that loop back on themselves
            next if $is-dead-end;

            # store the last node we were able to reach and the total length from $node to that node in the trail map
            %trail-graph{$node}.push: [$current-node, $length];

            # add the current node to the list of paths to explore
            # we should either have 1 or 2 more branches off of this node
            @todo.push: $current-node;
        }

        # mark this node as explored
        $visited.set: $node;
    }

    %trail-graph;
}

my %trail-with-slopes = build-trail-graph($starting-position);
say "Part 1: " 
    ~ [max] walk(%trail-with-slopes, $starting-position, $goal-position);

my %trail-without-slopes = build-trail-graph($starting-position, False);
say "Part 2: " 
    ~ [max] walk(%trail-without-slopes, $starting-position, $goal-position);

sub walk(%graph, $start, $goal) {
    my @stack = [($start, 0, SetHash[Point].new),];

    # store the highest max that we have seen so we consume less memory
    # not doing this also emitted > 65K elements which is the max size of a
    # flattening context in Raku *shrug*
    my $current-max = -1;
    gather {
        while @stack {
            my ($current-point, $current-length, $visited) = @stack.pop;

            if $current-point eq $goal and $current-length > $current-max {
                $current-max = $current-length;
                take $current-length;
                next;
            }

            for %graph{$current-point}.values -> [$next-point, $edge-length] {
                if not $next-point (elem) $visited {
                    @stack.push: ($next-point, $current-length + $edge-length, $visited (|) $next-point);
                }
            }
        }
    }
}