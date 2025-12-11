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

sub rectangular-area(Point $corner1, Point $corner2) {
    (($corner2.x - $corner1.x).abs + 1) * (($corner2.y - $corner1.y).abs + 1)
}

my @red-tiles = $*IN.lines>>.split(',')>>.Int.map(-> ($x, $y) { Point.new(x => $x, y => $y) });

# part 1:
# iterate through all pairs of points and find the pair with the largest rectangular area
say @red-tiles.combinations(2).map(-> ($tile1, $tile2) { rectangular-area($tile1, $tile2) }).max;