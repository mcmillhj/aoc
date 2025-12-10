#!raku

class Point { 
    has Complex $!repr; 
    
    submethod BUILD(:$x, :$y){ 
        $!repr= $x + $y * 1i 
    } 
    
    method x { $!repr.re.Int } 
    method y { $!repr.im.Int }
    method Str { "(" ~ self.x ~ ',' ~ self.y ~ ")" }
    method WHICH { self.Str }
}

multi sub infix:<+>(Point $a, Point $b) {
  Point.new(x => $a.x + $b.x, y => $a.y + $b.y)
}

sub is-empty-space(Str $s) { $s eq '.' }
sub is-beam(Str $s) { $s eq '|' }
sub is-splitter(Str $s) { $s eq '^' }

constant UP    = Point.new(x => +0, y => -1);
constant DOWN  = Point.new(x => +0, y => +1);
constant LEFT  = Point.new(x => -1, y => +0);
constant RIGHT = Point.new(x => +1, y => +0);

my Str %tachyon-manifold{Point};
my Point $START;
for $*IN.lines.kv -> $y, $row {
  for $row.comb.kv -> $x, $column {
    my Point $point = Point.new(x => $x, y => $y);
    %tachyon-manifold{$point} = $column;

    if $column eq 'S' {
        $START = $point
    }
  }
}

# part 1:
# model the beams path through the manifold and record each time we hit a splitter

# the beam starts below S
my Point @beams = ($START + DOWN);
my $split-count = 0;
my Int %split-at{Point};
while @beams.elems > 0 {
    my Point $beam = shift @beams;

    # the beam continues moving down until it encounters a spliiter or it leaves the tachyon manifold
    repeat {
        $beam += DOWN;
    } until %tachyon-manifold{$beam}:!exists or is-splitter(%tachyon-manifold{$beam});

    # if the beam has left the tachyon manifold, do nothing
    next unless %tachyon-manifold{$beam}:exists;
    next unless %split-at{$beam}:!exists;

    # split the beam + record that this splitter was reached
    $split-count++;
    %split-at{$beam}++;
    
    # when a beam encounters a splitter it stops, then two new beam are generated on each side of the splitter
    for LEFT, RIGHT -> $direction {
        my $new-beam = $beam + $direction;

        # beams created by adjacent splitters only count as 1 if they occupy the same x,y coordinates
        next unless %tachyon-manifold{$new-beam}:exists 
            and is-empty-space(%tachyon-manifold{$new-beam});

        @beams.push: $new-beam;
    }
}

say $split-count;

# part 2:
# modeling the beam wont work here since there will be more than one possible path
# a search + backtrack might work but since we know that a beam can only be active in a single column of the manifold
# at one time we can track the counts to represent each "path" the beam took
# the column with S starts with the beam enabled

my Int %counts{Int} = (($START + DOWN).x => 1);
for %tachyon-manifold.sort({ $^a.key.y <=> $^b.key.y or $a.key.x <=> $b.key.x }) -> (:$key, :$value) {
    # when we encounter a splitter, pass along the count of the # of beams that hit the splitter to the new beams that are 
    # created to the left and the right
    if is-splitter($value) {
        %counts{$key.x - 1} += %counts{$key.x};
        %counts{$key.x + 1} += %counts{$key.x};
        %counts{$key.x} = 0;
    }
}

dd [+] %counts.values;