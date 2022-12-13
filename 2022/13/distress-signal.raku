#!raku

my @data = [
  [1,1,[3],1,1],
  [1,1,5,1,1],

  [[1],[2,3,4]],
  [[1],4],

  [9],
  [[8,7,6]],

  [[4,4],4,4],
  [[4,4],4,4,4],

  [7,7,7,7],
  [7,7,7],

  [],
  [3],

  [$[$[]]],
  [$[]],

  [1,[2,[3,[4,[5,6,7]]]],8,9],
  [1,[2,[3,[4,[5,6,0]]]],8,9],
];

multi sub compare($left, $right) { $left <=> $right }
multi sub compare(@left, @right) {
  # zip together elements from @left and @right for comparison
  # if no ordering is determined, compare the lengths of @left and @right
  (@left Z @right).map(-> ($l, $r) { compare($l, $r) }).first(* != Order::Same) 
    || @left.elems <=> @right.elems
}
multi sub compare($left, @right) { compare([$left], @right) }
multi sub compare(@left, $right) { compare(@left, [$right]) }

# part 1
say [+] @data.rotor(2)
          # find the indexes of the pairs that are in the correct order
          .grep(-> (@left, @right) { compare(@left, @right) == Order::Less }, :k)
          # pairs are 1-indexed
          .map(* + 1);

# part 2
my @divider-packets = [[2]], [[6]];
# inject the divider packets at the end of the data
@data.append: @divider-packets;

say [*] @data
          # sort the packets based on their relative ordering (divider packets will get included in this)
          .sort(&compare)
          # find the indexes of the divider packats
          .grep(-> $d { @divider-packets.first(-> $divisor { compare($d, $divisor) == Order::Same }) }, :k)
          # pairs are 1-indexed
          .map(* + 1);