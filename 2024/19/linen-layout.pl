#!perl 

use strict;
use warnings;

use feature    qw(say);
use List::Util qw(sum0);

my %counts_by_substr;

sub accepts {
    my ( $design, $patterns ) = @_;

    # return if we have already calculated the number of towel
    # arrangements for this substring
    if ( $counts_by_substr{$design} ) {
        return $counts_by_substr{$design};
    }

    # if the design is exhausted we are able to fully
    # match with available towels
    if ( length($design) == 0 ) {
        return 1;
    }

    my $result = sum0

      # recurse on a smaller string to determine if this designed can be matched
      map { accepts( substr( $design, $_ ), $patterns ) }

      # only continue searching for non-zero length matches
      grep { $_ }

      # find all patterns that match this substring
      # store the length of the match ($&)
      map { $design =~ $_; length($&); } @$patterns;

    # cache results to speed up future calculations
    $counts_by_substr{$design} = $result;

    return $result;
}

my ( $towel_patterns, $designs ) = do {
    local $/ = undef;

    my ( $towel_data, $design_data ) = split "\n\n", readline( \*STDIN );

    [ map { qr/^$_/ } split ", ", $towel_data ], [ split "\n", $design_data ];
};

say scalar grep { $_ > 0 } map { accepts( $_, $towel_patterns ) } @$designs;
say sum0 map { accepts( $_, $towel_patterns ) } @$designs
