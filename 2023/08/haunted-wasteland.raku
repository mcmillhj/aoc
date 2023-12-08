#!raku

my @directions = $*IN.lines.first.comb();
my @nodes = $*IN.lines.map({ 
    # skip empty lines
    next unless $_;

    my ($source-node, @target-nodes) = .comb(/\w ** 3/);

    [$source-node, @target-nodes];
});

my %MAP;
for @nodes -> ($source-node, @target-nodes) {
    for @target-nodes -> $target-node {
        %MAP{$source-node}.push: $target-node;
    }
}

sub is-start-node(Str $node-name) { $node-name ~~ /A$/; }
sub is-goal-node(Str $node-name)  { $node-name ~~ /Z$/; }

my @START-NODES = %MAP.keys.grep(-> Str $key { is-start-node($key) });
my @GOAL-NODES = %MAP.keys.grep(-> Str $key { is-goal-node($key) });
my @current-nodes = @START-NODES;

# keep track of multiple paths using an array of stacks
my @paths = @START-NODES.map({ [$_] });

my $direction-pointer = 0;
my @cycles;
loop {
    my $direction = @directions[$direction-pointer++ % @directions.elems];

    for @current-nodes.kv -> $node-index, $current-node {
        given $direction {
            when "R" { 
                @current-nodes[$node-index] = %MAP{$current-node}[1];
                @paths[$node-index].push: %MAP{$current-node}[1];
            }
            when "L" { 
                @current-nodes[$node-index] = %MAP{$current-node}[0];
                @paths[$node-index].push: %MAP{$current-node}[0];
            }
        }
    }

    # collect any nodes that have reached a goal and record the cycle length
    my @nodes-at-goal-node = 
        @current-nodes.kv.map(-> $k, $v { [$k, $v ] })
        .grep(-> [$k, $v] { is-goal-node($v) });

    if @nodes-at-goal-node {
        @cycles.append: @nodes-at-goal-node.map(-> [$k, $v] { $v => @paths[$k].elems - 1 });
    }

    # stop looping when we have detected a cycle for each starting node
    last if
        @cycles.elems == @START-NODES.elems;
}

say "Part 1: " ~ @cycles>>.pairs.flat
    .grep(-> Pair $p (:$key, :$value) { $key eq 'ZZZ' })
    .map(-> Pair $p (:$key, :$value) { $value }).head;

say "Part 2: " ~ [lcm] @cycles>>.pairs.flat
    .map(-> Pair $p (:$key, :$value) { $value })
