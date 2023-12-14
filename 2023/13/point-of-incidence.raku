#!raku 

my @mirror-grids = $*IN.slurp.split("\n\n")>>.split("\n")>>.comb;

my $summary = 0;
my $previous-summary = 0;
for @mirror-grids.kv -> $k, @mirror-grid {
    my (@columns, @rows) := encode(@mirror-grid);

    my $previous-vertical-reflection-point = reflection-points(@columns).head;
    my $previous-horizontal-reflection-point = reflection-points(@rows).head;
    my $vertical-reflection-point = unsmudge(@columns, @rows.elems)
        .flatmap({ reflection-points($_) })
        .first({ $_ != 0 and $_ != $previous-vertical-reflection-point }) // 0;
    my $horizontal-reflection-point = unsmudge(@rows, @columns.elems)
        .flatmap({ reflection-points($_) })
        .first({ $_ != 0 and $_ != $previous-horizontal-reflection-point }) // 0;


    $summary += summarize($vertical-reflection-point, $horizontal-reflection-point);
    $previous-summary += summarize($previous-vertical-reflection-point, $previous-horizontal-reflection-point)
}

say "Part 1: $previous-summary";
say "Part 2: $summary";

sub summarize($vertical-reflection-point, $horizontal-reflection-point) {
    return $vertical-reflection-point + $horizontal-reflection-point * 100;
}

# to "unsmudge" the encoded columns we check if the bit representing
# an x,y on the grid is set ('#') or not set ('.')
# if the bit is set, we model turning the rock into ash (subtracting)
# if the bit is not set, we model turning the ash into a rock (adding)
sub unsmudge(@mirrors, $LENGTH) {
    gather {
        for 0..^$LENGTH -> $p {
            for 0..^@mirrors -> $position {
                if @mirrors[$position] +& (1 +< $p) {
                    take (@mirrors[0..$position-1], @mirrors[$position] - 2**$p, @mirrors[$position+1..*-1]).flat;
                } 
                else {
                    take (@mirrors[0..$position-1], @mirrors[$position] + 2**$p, @mirrors[$position+1..*-1]).flat;
                }
            }
        }
    }
}

# encode each row or column as a unique number built with powers of 2
# where '#' counts as 1 and '.' counts as 0
# row `#.#` would be encoded as:
#   2^0 * 1 
# + 2^1 * 0 
# + 2^2 * 1 
#----------
#         5
sub encode(@mirror-grid) {
    my $COLUMNS = @mirror-grid[0].elems;
    my $ROWS = @mirror-grid.elems;

    my @columns = (0) xx $COLUMNS;
    my @rows = (0) xx $ROWS;
    for ^$ROWS -> $r {
        for ^$COLUMNS -> $c {
            @columns[$c] += 2**$r * (@mirror-grid[$r][$c] eq '#' ?? 1 !! 0);
            @rows[$r] += 2**$c * (@mirror-grid[$r][$c] eq '#' ?? 1 !! 0);
        }
    }

    return @columns, @rows;
}

# reflection always start between two matching numbers
# search the mirrors for matching rows (or columns)
# and search backward until either a mismatch is found 
# or the edge of the grid
sub reflection-points(@mirrors) {
    gather {
        loop (my $i = 0; $i < @mirrors.elems - 1; $i++) {
            if @mirrors[$i] == @mirrors[$i + 1] {
                my @left = @mirrors[0 .. $i];
                my @right = @mirrors[$i + 1 .. * - 1];
                my $closest-edge = min(@left.elems, @right.elems);

                take $i + 1 
                    if @left.reverse[0..^$closest-edge].List eqv @right[0..^$closest-edge].List;
            }
        }

        take 0;
    }
}