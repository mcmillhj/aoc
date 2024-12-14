#!raku

class Point {
    has Int $.x is rw;
    has Int $.y is rw;

    method Str { self.x ~ ',' ~ self.y }
    method WHICH { self.Str }
}

# 1. Solve for x
# 
# x * Ax + y * Bx = Zx
# x * Ax = Zx - y * Bx
# x = Zx - y * Bx / Ax
#  
# x * Ay + y * By = Zy
# x * Ay = Zy - y * By
# x = Zy - y * By / Ay
#
# 2. Solve for y
# 
# (Zx - y * Bx)   (Zy - y * By)
# ------------- = -------------
#     Ax               Ay
# 
# (Zx - y * Bx) Ay = (Zy - y * By) Ax
# (Zx * Ay) - (y * Bx * Ay) = (Zy * Ax) - (y * By * Ax)
# (y * By * Ax) + (Zx * Ay) - (y * Bx * Ay) = (Zy * Ax)
# (y * By * Ax) - (y * Bx * Ay) = (Zy * Ax) - (Zx * Ay)
# y * (By * Ax) - (Bx * Ay) = (Zy * Ax) - (Zx * Ay)
# 
#     (Zy * Ax) - (Zx * Ay)
# y = ---------------------
#     (By * Ax) - (Bx * Ay)

# my $a = [94, 34];
# my $b = [22, 67];
# my $z = [8400, 5400];


sub calculate-presses(Point $a, Point $b, Point $z) {
    my $B = ($z.y * $a.x - $z.x * $a.y) / ($b.y * $a.x - $b.x * $a.y);
    my $A = ($z.x - $B * $b.x) / $a.x;

    return (0, 0) 
        if $A < 0 or $B < 0 or $A != $A.Int or $B != $B.Int;
        
    return ($A, $B);
}

my $A_COST = 3;
my $B_COST = 1;
my $Z_OFFSET = 10_000_000_000_000;
my @equations = $*IN.slurp.split("\n\n")>>.comb(/\d+/)>>.Int.map(-> ($ax, $ay, $bx, $by, $zx, $zy) {
    Point.new(x => $ax, y => $ay), Point.new(x => $bx, y => $by), Point.new(x => $zx, y => $zy);
});

say [+] @equations
    .map(-> ($a, $b, $z) { calculate-presses($a, $b, $z) })
    .map(-> ($A, $B) { $A_COST * $A + $B_COST * $B; });

say [+] @equations
    .map(-> ($a, $b, $z) { calculate-presses($a, $b, Point.new(x => $z.x + $Z_OFFSET, y => $z.y + $Z_OFFSET)) })
    .map(-> ($A, $B) { $A_COST * $A + $B_COST * $B; })