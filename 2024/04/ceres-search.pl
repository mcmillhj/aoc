#!perl 

use strict;
use warnings;

use feature    qw(say);
use List::Util qw(zip);

my @directions = (
    [ -1, -1 ],    # up + left
    [ -1, +0 ],    # up
    [ -1, +1 ],    # up + right
    [ +0, +1 ],    # right
    [ +1, +1 ],    # down + right
    [ +1, +0 ],    # down
    [ +1, -1 ],    # down + left
    [ +0, -1 ],    # left
);

sub make_key {
    my ( $y, $x ) = @_;

    return "$y,$x";
}

my %word_search = do {
    local $/ = undef;

    my @lines  = map { [ split // ] } split "\n", readline( \*STDIN );
    my $HEIGHT = $#lines;
    my $WIDTH  = $#{ $lines[0] };

    my @points;
    push @points, zip( [ ($_) x ( $HEIGHT + 1 ) ], [ 0 .. $WIDTH ] )
      for ( 0 .. $HEIGHT );

    map {
        my $y = $_->[0];
        my $x = $_->[1];

        make_key( $y, $x ) => $lines[$y]->[$x];
    } @points;
};

# part 1
{
    my $TARGET     = "XMAS";
    my $xmas_count = 0;
    while ( my ( $point, $letter ) = each %word_search ) {
        my ( $y, $x ) = split ',', $point;

        foreach my $d (@directions) {
            my ( $dy, $dx ) = @$d;

            my $possible_match = join '', map {
                $word_search{ make_key( $y + $dy * $_, $x + $dx * $_ ) } // ''
            } ( 0 .. length($TARGET) - 1 );
            next unless $possible_match eq $TARGET;

            $xmas_count++;
        }
    }

    say $xmas_count;
}

# part 2
{
    my $x_mas_count = 0;
    while ( my ( $point, $letter ) = each %word_search ) {
        next unless $word_search{$point} eq 'A';

        my ( $y, $x ) = split ',', $point;

        # say "($point) = $letter";
        my $left_to_right_diagonal = join '', map {
            my ( $dy, $dx ) = @$_;
            $word_search{ make_key( $y + $dy, $x + $dy ) } // ''
        } [ -1, -1 ], [ +1, +1 ];
        my $right_to_left_diagonal = join '', map {
            my ( $dy, $dx ) = @$_;
            $word_search{ make_key( $y + $dy, $x + $dx ) } // ''
        } [ -1, +1 ], [ +1, -1 ];

        next
          unless ( $left_to_right_diagonal eq 'SM'
            or $left_to_right_diagonal eq 'MS' )
          and ($right_to_left_diagonal eq 'SM'
            or $right_to_left_diagonal eq 'MS' );

        $x_mas_count++;
    }

    say $x_mas_count;
}
