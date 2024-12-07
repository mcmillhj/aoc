#!raku

multi sub infix:<cat>(Int $a, Int $b) {
    ($a ~ $b).Int
}

my @operators = &infix:<+>, &infix:<*>, &infix:<cat>;
my @calibration-equations = 
    $*IN.lines.map: -> $line { $line.comb(/\d+/)>>.Int; };


sub calibrate(@equations, @operators) {
    my $total-calibration-result = 0;
    for @calibration-equations -> $c {
        my ($target, @operands) = $c;

        my @acc = @operands[0];
        for @operands[1..*] -> $operand {
            my @new-acc;
            for @operators.kv -> $i, $op {
                @new-acc.append: @acc.map(-> $a { $op($a, $operand )});
            }

            @acc = @new-acc;
        }

        if grep { $target == $_ }, @acc {
            $total-calibration-result += $target;
        }
    }

    return $total-calibration-result;
}

say calibrate(@calibration-equations, [&infix:<+>, &infix:<*>]);
say calibrate(@calibration-equations, [&infix:<+>, &infix:<*>, &infix:<cat>]);