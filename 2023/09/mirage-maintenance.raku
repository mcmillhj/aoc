#!raku

    my @histories = $*IN.lines>>.comb(/'-'?\d+/)>>.Int;

    say "Part 1: "
        ~ [+] @histories.map(-> @history { next-reading(@history) });
    say "Part 2: "
        ~ [+] @histories.map(-> @history { previous-reading(@history) });

    sub differences(@history) {
        @history.rotor(2 => -1).map(-> ($a, $b) { $b - $a }).Array
    }

    sub successive-differences(@history) {
        my @differences = (@history.Array,);

        repeat {
            @differences.push: differences(@differences.tail);
        } until so 0 == @differences.tail.all;

        return @differences;
    }

    sub next-reading(@history) {
        [+] successive-differences(@history)>>.tail>>.pop
    }

    # reverse the input so that the "next" reading is the previous reading
    sub previous-reading(@history) {
        next-reading(@history.reverse)
    }