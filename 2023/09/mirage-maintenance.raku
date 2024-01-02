#!raku

use lib '..';
use AOCUtils;

my @histories = $*IN.lines>>.comb(/'-'?\d+/)>>.Int;

say "Part 1: "
    ~ [+] @histories.map(-> @history { next-reading(@history) });
say "Part 2: "
    ~ [+] @histories.map(-> @history { previous-reading(@history) });

sub next-reading(@history) {
    [+] successive-differences(@history)>>.tail>>.pop
}

# reverse the input so that the "next" reading is the previous reading
sub previous-reading(@history) {
    next-reading(@history.reverse)
}