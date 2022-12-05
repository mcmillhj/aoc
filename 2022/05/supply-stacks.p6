#!raku

my ($stacks, $moves) = 'input'.IO.slurp.split("\n\n");

# [V]     [B]                     [C]
# [C]     [N] [G]         [W]     [P]
# [W]     [C] [Q] [S]     [C]     [M]
# [L]     [W] [B] [Z]     [F] [S] [V]
# [R]     [G] [H] [F] [P] [V] [M] [T]
# [M] [L] [R] [D] [L] [N] [P] [D] [W]
# [F] [Q] [S] [C] [G] [G] [Z] [P] [N]
# [Q] [D] [P] [L] [V] [D] [D] [C] [Z]
#  1   2   3   4   5   6   7   8   9 

my @stacks = [
  [], [<Q F M R L W C V>], [<D Q L>], [<P S R G W C N B>], [<L C D H B Q G>], [<V G L F Z S>], [<D G N P>], [<D Z P V F C W>], [<C P D M S>], [<Z N W T V M P C>]
];

my @stacks2 = [
  [], [<Q F M R L W C V>], [<D Q L>], [<P S R G W C N B>], [<L C D H B Q G>], [<V G L F Z S>], [<D G N P>], [<D Z P V F C W>], [<C P D M S>], [<Z N W T V M P C>]
];

for $moves.split("\n") -> $move {
  my ($count, $from, $to) = ($move ~~ m:s/move (\d+) from (\d+) to (\d+)/).list>>.Int;

  # part 1
  @stacks[$to].push: @stacks[$from].pop() for 1 .. $count;

  # part 2
  @stacks2[$to].append: @stacks2[$from].splice(* - $count);
}

say join '', @stacks.map: { .tail(1) };
say join '', @stacks2.map: { .tail(1) };