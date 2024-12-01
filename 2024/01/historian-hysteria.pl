#!perl 

use strict;
use warnings;

use feature    qw(say);
use List::Util qw(reduce zip);

open my $input_fh, '<', 'input.txt'
  or die $!;

my ( $sorted_left, $sorted_right ) = do {
    local $/ = undef;
    my @input = map { int } readline($input_fh) =~ m/(\d+)/g;
    my @left  = @input[ grep { $_ % 2 == 0 } 0 .. $#input ];
    my @right = @input[ grep { $_ % 2 == 1 } 0 .. $#input ];

    [ sort { $a <=> $b } @left ], [ sort { $a <=> $b } @right ];
};

my $distance_sum =
  reduce { $a + $b }
  map { abs( $_->[0] - $_->[1] ) } zip( $sorted_left, $sorted_right );
say $distance_sum;

my $similarity_score =
  reduce { $a + $b }
  map {
    my $target = $_;
    my $count  = grep { $_ == $target } @$sorted_right;

    $target * ( $count // 0 )
  } @$sorted_left;
say $similarity_score;
