#!raku

my @game-records = 'input.txt'.IO.slurp.split("\n");

constant %MAX-ALLOWED-CUBES-BY-COLOR = (
    red => 12, 
    green => 13, 
    blue => 14
);

my $possible-games = 0;
my $cube-power = 0;
for @game-records -> $game-record {
    # extract the game ID
    my (Int() $game-id) := $game-record ~~ /^Game \s (\d+) ':'/; 

    # partition cubes by color
    my %cubes-by-color = 
        # 1. Find all cubes and split them into a list "3 blue" -> ("3", "blue")
        $game-record.comb(/\d+ \s (red|green|blue)/)>>.split(' ')>>.\
        # 2. Convert to a pair ("3", "blue") -> { "blue" => 3 }
        map(-> $quantity, $color { $color => +$quantity })
        # 3. Flatten list of pairs
        .flat
        # 4. Group by color, only project the value
        # { "blue" => 3 } -> { "blue" => [3] }
        .classify(*.key, :as{ $_.value });

    # a game if only possible if it does not exceed the cube color maximums
    $possible-games += $game-id 
        if %cubes-by-color<red>.max <= %MAX-ALLOWED-CUBES-BY-COLOR<red> 
        and %cubes-by-color<green>.max <= %MAX-ALLOWED-CUBES-BY-COLOR<green>
        and %cubes-by-color<blue>.max <= %MAX-ALLOWED-CUBES-BY-COLOR<blue>; 

    # the power of a game is measured by multiplying the maximum number of 
    # red, green, and blue cubes
    $cube-power += %cubes-by-color<red>.max 
        * %cubes-by-color<green>.max 
        * %cubes-by-color<blue>.max ; 
}

say $possible-games;
say $cube-power;
