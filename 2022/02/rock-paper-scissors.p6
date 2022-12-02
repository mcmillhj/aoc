#!raku

sub score(Pair $p (:$key, :$value)) {
  given ($key => $value) {
    when ("A" => "X") { return 3 + 1 } # rock == rock, draw + rock
    when ("A" => "Y") { return 6 + 2 } # paper > rock, win + paper
    when ("A" => "Z") { return 0 + 3 } # scissors < rock, loss + scissors
    when ("B" => "X") { return 0 + 1 } # rock < paper, loss + rock
    when ("B" => "Y") { return 3 + 2 } # paper == paper, draw + rock
    when ("B" => "Z") { return 6 + 3 } # scissors > paper, win + scissors
    when ("C" => "X") { return 6 + 1 } # scissors < rock, win + rock
    when ("C" => "Y") { return 0 + 2 } # scissors > paper, loss + paper
    when ("C" => "Z") { return 3 + 3 } # scissors == scissors, draw + scissors
  }
}

# calculate the next character based on what the opponent threw and whether we should lose, draw, or win
# X = LOSE, Y = DRAW, Z = WIN
sub next(Str:D $opponent, Str:D $self) {
  my $direction = do given $self {
    when "X" { -1  }
    when "Y" {  0  }
    when "Z" {  1  }
  };

  # map the opponent throw to [-1, 1] mod 3
  # add the ordinal value for "X" to map [-1, 1] mod 3 to X (ROCK), Y (PAPER), or Z (SCISSORS)
  return ((($opponent.ord - "A".ord + $direction) mod 3) + "X".ord).chr;
}

my $score1 = 0;
my $score2 = 0;
for 'input'.IO.lines>>.split(" ") -> ($opponent, $self) {
  # part 1
  $score1 += score($opponent => $self);

  # part 2
  $score2 += score($opponent => next($opponent, $self));
}

say $score1 ~ ", " ~ $score2;
