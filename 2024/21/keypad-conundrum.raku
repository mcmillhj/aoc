#!raku

use experimental :cached;

class Point {
    has Int $.x;
    has Int $.y;

    our @directions = (
        [ -1, +0, '^' ], # up
        [ +0, +1, '>' ], # right
        [ +1, +0, 'v' ], # down
        [ +0, -1, '<' ], # left
    );

    method neighbors {
        @directions.map: -> ($dy, $dx, $symbol) { (Point.new(x => self.x + $dx, y => self.y + $dy), $symbol) };
    }

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

my @numeric-keypad = (
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['3', '2', '1'],
    ['X', '0', 'A']
);

my Str %numeric-keypad{Point} = (
    Point.new(x => 0, y => 0) => '7', Point.new(x => 1, y => 0) => '8', Point.new(x => 2, y => 0) => '9',
    Point.new(x => 0, y => 1) => '4', Point.new(x => 1, y => 1) => '5', Point.new(x => 2, y => 1) => '6',
    Point.new(x => 0, y => 2) => '1', Point.new(x => 1, y => 2) => '2', Point.new(x => 2, y => 2) => '3',
                                      Point.new(x => 1, y => 3) => '0', Point.new(x => 2, y => 3) => 'A',
);

my Str %directional-keypad{Point} = (
                                      Point.new(x => 1, y => 0) => '^', Point.new(x => 2, y => 0) => 'A',
    Point.new(x => 0, y => 1) => '<', Point.new(x => 1, y => 1) => 'v', Point.new(x => 2, y => 1) => '>',
);

# for each node in the graph (numeric or directional) map the shortest path to every other node
sub map-shortest-sequences(%graph) {
    my %sequence-map;
    for %graph.keys X %graph.keys -> ($a, $b) {
        my @possible-paths = find-all-paths(%graph, $a, $b);

        %sequence-map{%graph{$a}}{%graph{$b}} = @possible-paths.grep(-> $p { 
            not $p ~~ rx/ '>' '^' '>' || '<' '^' '<' /  # paths that zigzag will always produce a longer sequence when expanding (e.g. >^> vs >>^ or ^>>)
        }).Array;
    }

    %sequence-map;
}

# djikstra
# given two nodes in the graph determine the shortest path between them as a string of directional inputs
sub find-all-paths(%graph, Point $start, Point $goal) {
    my @to-visit = ([$start, [$start], []],);
    my Int %costs{Point} is default(0) = ( $start => 0 );
    my @paths; 
    my @directions;
    while @to-visit {
        my ($current-location, @path, @direction) := @to-visit.shift();

        if $current-location eq $goal {
            @paths.push: @path;
            @directions.push: @direction;
        }

        for $current-location.neighbors -> ($neighbor, $direction) {
            # ignore moves that would take you off the graph
            next unless %graph{$neighbor}:exists;

            # if the target node has not been visited or has been visited but this path has a lower cost
            # update the cost for the target and add the target to the visited set
            if not %costs{$neighbor}:exists or %costs{$current-location} + 1 <= %costs{$neighbor} {
                %costs{$neighbor} = %costs{$current-location} + 1;

                @to-visit.push: [$neighbor, [|(@path, $neighbor).flat], [|(@direction, $direction).flat]];
            }
        }
    }

    return @directions.map(-> $direction { $direction.join('') }).Array;
}

my %directional-keypad-sequences = map-shortest-sequences(%directional-keypad);
my %numeric-keypad-sequences = map-shortest-sequences(%numeric-keypad);

sub build-sequences(%sequence-map, Str $code, $current-position, $current-path, @sequences) {
    # stop building if there is no remaining code left
    if $code.chars == 0 {
        @sequences.push: $current-path;

        return;
    }

    my $next-position = $code.substr(0, 1);
    for %sequence-map{$current-position}{$next-position} -> @paths {
        for @paths -> $next-path {
            build-sequences(%sequence-map, $code.substr(1), $next-position, $current-path ~ $next-path ~ 'A', @sequences);
        }
    }

    return @sequences;
}


# successivefully expand a sequence by breaking into subsequences and recursing to a lower depth
# breaking the sequences up like allows results to only be calculated once per sequence+level
sub find-shortest-sequence-length(Str $sequence, Int $depth) is cached {
    # at the lowest level of the search the sequence won't be expaneded any more, return the length
    if $depth == 0 {
        return $sequence.chars;
    }

    my $total = 0;
    # break sequence into subsequences that can be solved independently
    # if there are multiple consequtive 'A' characters, split at the last one
    my @subsequences = $sequence.split(rx/ 'A' <!before 'A'>/, :skip-empty).map(-> $s { $s ~ "A" });
    for @subsequences -> $subsequence {
        my $minimum-sequence-length = Inf;
        for build-sequences(%directional-keypad-sequences, $subsequence, 'A', '', []) -> $s {
            $minimum-sequence-length min= find-shortest-sequence-length($s, $depth - 1);            
        }

        # the total is the sum of the smallest subsequences that can form the current sequence
        $total += $minimum-sequence-length;
    }

    return $total;
}

sub calculate-complexity(@codes, Int $depth) {
    [+] @codes.map(-> $code {
        $code.chop(1).Int
            * [min] build-sequences(%numeric-keypad-sequences, $code, 'A', '', []).map(-> $sequence { find-shortest-sequence-length($sequence, $depth )})
    })
}

my @codes = $*IN.lines;
say calculate-complexity(@codes, 2);
say calculate-complexity(@codes, 25);