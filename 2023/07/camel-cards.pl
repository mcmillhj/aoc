#!perl 

use strict;
use warnings;
use v5.20;
no warnings 'experimental';

use feature    qw/say switch/;
use List::Util qw/max sum/;

our %RANK = (
  A => 13,
  K => 12,
  Q => 11,
  Z => 10,    # to avoid clashes between part 1 and part 2 label Jacks with Z
  T => 9,
  9 => 8,
  8 => 7,
  7 => 6,
  6 => 5,
  5 => 4,
  4 => 3,
  3 => 2,
  2 => 1,
  J => 0
);

our %STRENGTH = (
  "HIGH CARD"       => 1,
  "ONE PAIR"        => 2,
  "TWO PAIR"        => 3,
  "THREE OF A KIND" => 4,
  "FULL HOUSE"      => 5,
  "FOUR OF A KIND"  => 6,
  "FIVE OF A KIND"  => 7
);

my @hands = do {
  local $/ = undef;

  map { [ split /\s+/ ] } split /\n/, <>;
};

sub classify {
  my ($hand, $jokers_enabled) = @_;

  if (!$jokers_enabled and $hand =~ /J/) {
    $hand =~ s/J/Z/g;
  }

  return [ map { $RANK{$_} } split //, $hand ];
}

sub counts {
  my ($hand) = @_;

  my %counts;
  foreach my $card (@$hand) {
    $counts{$card}++;
  }

  return %counts;
}

sub strength {
  my ($hand, $jokers_enabled) = @_;

  return joker_strength($hand)
    if $jokers_enabled;

  return non_joker_strength($hand);
}

sub joker_strength {
  my ($hand) = @_;

  # create all possible hands by substituting each possible
  # card in place of the joker
  my @possible_hands;
  foreach my $card (grep { $_ != $RANK{'J'} } values %RANK) {
    push @possible_hands, [ map { $_ == $RANK{'J'} ? $card : $_ } @$hand ];
  }

  return max map { non_joker_strength($_) } @possible_hands;
}

sub non_joker_strength {
  my ($hand) = @_;

  my %counts = counts($hand);
  for (join '', sort values %counts) {
    when ("11111") {
      return $STRENGTH{"HIGH CARD"};
    }
    when ("1112") {
      return $STRENGTH{"ONE PAIR"};
    }
    when ("122") {
      return $STRENGTH{"TWO PAIR"};
    }
    when ("113") {
      return $STRENGTH{"THREE OF A KIND"};
    }
    when ("14") {
      return $STRENGTH{"FOUR OF A KIND"};
    }
    when ("23") {
      return $STRENGTH{"FULL HOUSE"};
    }
    when ("5") {
      return $STRENGTH{"FIVE OF A KIND"};
    }
  }
}

sub compare {
  my ($hand1, $hand2, $jokers_enabled) = @_;

  return
       strength($hand1, $jokers_enabled) <=> strength($hand2, $jokers_enabled)
    || $hand1->[0]                       <=> $hand2->[0]
    || $hand1->[1]                       <=> $hand2->[1]
    || $hand1->[2]                       <=> $hand2->[2]
    || $hand1->[3]                       <=> $hand2->[3]
    || $hand1->[4]                       <=> $hand2->[4];
}

sub solve {
  my ($jokers_enabled) = @_;

  my @sorted_bids =

    # extract the bid
    map { $_->[1] }

    # sort the hands according to strength in ascending order
    sort { compare($a->[2], $b->[2], $jokers_enabled) }

    # map each card to its corresponding rank and store alongside the hand
    map { [ @$_, classify($_->[0], $jokers_enabled) ] } @hands;

  my $acc = 0;
  while (my ($rank, $bid) = each @sorted_bids) {
    $acc += $bid * ($rank + 1);
  }

  return $acc;
}

say "Part 1: " . solve();
say "Part 2: " . solve(1);
