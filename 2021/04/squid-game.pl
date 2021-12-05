#!perl

use strict; 
use warnings;

use feature qw(say);
use List::Util qw(min max sum);
use Data::Dumper;

chomp(my @call_numbers = split /,/, readline(\*DATA));
my @call_turns;
foreach my $i (0 .. @call_numbers - 1) {
  @call_turns[$call_numbers[$i]] = $i;
}

sub transpose {
  my (@rows) = @_;

  my @transposed; 
  foreach my $row (@rows) {
    foreach my $column (0 .. $#{$row}) {
      push @{$transposed[$column]}, $row->[$column];
    }
  }

  \@transposed;
}

my @lines = do {
  local $/;

  # separate into rows and translate to order called
  map { [map { $call_turns[$_]} split /\s+/] } 
  # filter out empty lines
  grep { /\S/ } 
  # remove leading and trailing space
  map { s/^\s*|\s*$//gr } 
  # split into lines
  split "\n", readline(\*DATA);
}; 

# group input into boards
my @boards; 
push @boards, [ splice @lines, 0, 5 ] while @lines;

my $minimum = 2**32 - 1;
my $maximum = 0;

my $winning_board; 
foreach my $board (@boards) {
  my $tranposed_board = transpose(@$board);

  foreach my $i (0 .. $#{ $board }) {
    my $row = $board->[$i];
    my $column = $tranposed_board->[$i];

    # the earliest row or column that _could_ win is the minimum of the two
    # maximums of the row and the column
    my $row_col_minmax = min((max @$row), (max @$column));
    if ($row_col_minmax < $minimum) {
      $minimum = $row_col_minmax;
      $winning_board = $board;
    }
  }
}

my $sum = 0;
foreach my $row (@$winning_board) {
  # do not include empty rows or columns
  next unless grep { $_ > $minimum } @$row;

  # convert back to value from the order
  # only include numbers are _not_ in the winning row or column
  $sum += sum map { $call_numbers[$_] } grep { $_ > $minimum } @$row; 
}

say "$sum * $call_numbers[$minimum] = " . $sum * $call_numbers[$minimum];

__DATA__
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7