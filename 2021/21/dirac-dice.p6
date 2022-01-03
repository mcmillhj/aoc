#!perl6

# part 1
my $die = 0;
sub roll {
  $die = $die + 1;
}

my %state = {
  1 => { position => 4, score => 0 },
  2 => { position => 7, score => 0 },
}

loop {
  my $roll1 = roll() + roll() + roll();
  my $np1 = (%state{"1"}{"position"} + $roll1  - 1) % 10 + 1;
  %state{"1"}{"position"} = $np1;
  %state{"1"}{"score"} += $np1;

  if %state{"1"}{"score"} >= 1000 {
    say $die * %state{"2"}{"score"};
    last;
  }

  my $roll2 = roll() + roll() + roll();
  my $np2 = (%state{"2"}{"position"} + $roll2 - 1) % 10 + 1;
  %state{"2"}{"position"} = $np2;
  %state{"2"}{"score"} += $np2;

  if %state{"2"}{"score"} >= 1000 {
    say $die * %state{"1"}{"score"};
    last;
  }
}

dd %state;

# part 2
my %cache;

sub play($position1, $position2, $score1, $score2) {
  return [1, 0] if $score1 >= 21;
  return [0, 1] if $score2 >= 21;

  if %cache{$position1 ~ $position2 ~ $score1 ~ $score2}:exists {
    return %cache{$position1 ~ $position2 ~ $score1 ~ $score2};
  }

  my $universes-won = [0, 0];
  for 1 .. 3 -> $dice1 {
    for 1 .. 3 -> $dice2 {
      for 1 .. 3 -> $dice3 {
        my $new-position1 = ($position1 + $dice1 + $dice2 + $dice3 - 1) % 10 + 1;
        my $new-score1 = $score1 + $new-position1;

        my $sub-universes-won = play($position2, $new-position1, $score2, $new-score1);
        $universes-won = [
          $universes-won[0] + $sub-universes-won[1], 
          $universes-won[1] + $sub-universes-won[0]
        ];
      }
    }
  }

  # store results
  %cache{$position1 ~ $position2 ~ $score1 ~ $score2} = $universes-won;
  return $universes-won;
}

say [max] play(4, 7, 0, 0).List;