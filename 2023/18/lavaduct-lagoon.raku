#!raku
my @dig-plan = $*IN.lines>>.split(' ');

constant %DIRECTIONS = (
    U => [-1, 0],
    3 => [-1, 0],
    R => [0, +1],
    0 => [0, +1],
    D => [+1, 0],
    1 => [+1, 0],
    L => [0, -1],
    2 => [0, -1],
);

sub dig(@plan) {
    my $enclosed-area = 0;
    my $trench-perimeter = 0;
    my $current-position = (0, 0);
    for @plan -> [$direction, $distance, $color] {
        my ($y, $x) = $current-position;
        my ($dy, $dx) = %DIRECTIONS{$direction}.map({ $_ * $distance });
        $current-position = ($y + $dy, $x + $dx);

        # learned about this after Day 10 when I did a lot of manual searching to find the enclosed spaces
        # https://en.wikipedia.org/wiki/Shoelace_formula#Triangle_formula
        $enclosed-area += -$y * $dx;
        $trench-perimeter += $distance;
    }

    ($enclosed-area + $trench-perimeter div 2) + 1
}

say "Part 1: " ~ dig(@dig-plan);
say "Part 2: " ~ dig(
    @dig-plan.map(-> ($direction, $distance, $color) { ($color.substr(7,1), :16($color.substr(2,5)), $color) })
);