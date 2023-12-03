#!raku 

my @directions = (
  [ -1, -1 ], # up + left
  [ -1, +0 ], # up
  [ -1, +1 ], # up + right
  [ +0, +1 ], # right
  [ +1, +1 ], # down + right
  [ +1, +0 ], # down
  [ +1, -1 ], # down + left
  [ +0, -1 ], # left
);

my @parts;
my @symbols;
for 'input.txt'.IO.lines.kv -> $line-number, $line {
    my @matches := $line ~~ m:g/(<digit>+)/;
    for @matches -> $match {
        @parts.push: {x => $line-number, y => +$match.from, length => $match.pos - $match.from, value => +$match};
    }

    my @symbol-matches := $line ~~ m:g/(<-[\d.]>)/;
    for @symbol-matches -> $match {
        @symbols.push: {x => $line-number, y => +$match.from, length => $match.pos - $match.from, value => ~$match};
    }
}

# assume that all parts are adjacent to a sybmol
my $part-number-sum = [+] @parts.map(*<value>);
my $gear-ratios = 0;
my %symbols-that-touch-parts;

# loop over all part numbers and remove them from the sum if they have 
# no adjacent symbol
PART_NUMBER:
for @parts -> $part {
    # search in all directions
    for @directions -> [$dx, $dy] {
        # search across the entire length of the number
        # e.g. 467 at (0, 0) needs to check for adjacent symbols at (0, 0), (0, 1), and (0, 2)
        for ^$part<length> -> $py {
            my $nx = $part<x> + $dx;
            my $ny = $part<y> + $dy + $py;

            # ignore impossible positions
            next unless 0 <= $nx and 0 <= $ny;

            # find any symbols this part touches
            my @touching-symbols = 
                @symbols.grep: -> $s { $nx == $s<x> and $ny == $s<y> };

            # if this part is touching a symbol, record that mapping for part2
            if (@touching-symbols) {
                %symbols-that-touch-parts{
                    $_<value> ~ "(" ~ $_<x> ~ "," ~ $_<y> ~ ")"
                }.push: $part for @touching-symbols;

                # symbol found, move to next part
                next PART_NUMBER;
            }
        }
    }

    # no adjacent symbols were found, remove this part from the sum
    $part-number-sum -= $part<value>;
}

say $part-number-sum;
say [+] %symbols-that-touch-parts.\
    kv.\
    # only examine gears that are touching exactly two parts
    grep(-> $symbol, $parts { $symbol ~~ /^'*'/ and $parts.elems == 2 })>>.\
    # multiply the gear-adjacent part numbers together
    map(-> $symbol, $parts { [*] $parts.map(*<value>) }).\
    # flatten into a single result
    flat; 
