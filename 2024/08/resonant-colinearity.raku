#!raku

class Point {
    has Int $.x is rw;
    has Int $.y is rw;

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

multi sub infix:<==>(Point $a, Point $b) {
    return $a.x == $b.x and $a.y == $b.y;
}

my $HEIGHT = -1;
my $WIDTH = -1;

# collect all antennae that have the same frequency
my Array[Point] %antennae;
for $*IN.lines.kv -> $y, $line {
    $HEIGHT max= $y;
    for $line.comb.kv -> $x, $c {
        $WIDTH max= $x;
        next unless $c ~~ m/<alpha>+|<digit>+/;

        %antennae{$c}.append: Point.new(x => $x, y => $y);
    }
} 

sub scan(%antennae, $antinode-finder) {
    my $antinodes = SetHash[Point].new;
    
    for %antennae.kv -> $k, @v {
        # only calculate antinodes between antennae with the same frequency
        for @v X @v -> [$a, $b] {
            # skip identical antenna
            next if $a == $b;       

            # find antinodes along the path of Point a + Point b
            for $antinode-finder($a, $b) -> $antinode {
                # ignore antinodes that are outside the bounds of the scan
                last unless is-in-bounds($antinode);

                $antinodes.set: $antinode;
            }
        }
    }

    return $antinodes;
}


sub is-in-bounds(Point $p) {
    0 <= $p.x <= $WIDTH and 0 <= $p.y <= $HEIGHT;
}

# calculate the next antinode along the line of Point a + Point b
# A = P1 + (P1 - P2)
#   = (P1.X + (P1.X - P2.X), P1.Y + (P1.Y - P2.Y))
sub find-next-antinode(Point $a, Point $b) {
    Point.new(x => $a.x + ($a.x - $b.x), y => $a.y + ($a.y - $b.y))
}

# # calculate all antinodes along the line of Point a + Point b
sub find-all-antinodes(Point $a, Point $b) {
    my $current-antinode = $a;
    my $previous-antinode = $b;
    
    lazy gather {
        loop {
            take $current-antinode;

            ($current-antinode, $previous-antinode) = (
                find-next-antinode($current-antinode, $previous-antinode),
                $current-antinode
            );
        } 
    }
}

say scan(%antennae, &find-next-antinode).elems;
say scan(%antennae, &find-all-antinodes).elems;