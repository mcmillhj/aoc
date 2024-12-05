#!perl 

use strict;
use warnings;

use feature qw(say);

use List::Util qw(reduce);

my ( $page_ordering_rules, $pages_to_produce ) = do {
    local $/ = undef;

    my $data = readline( \*STDIN );
    my ( $ordering_str, $production_str ) = split "\n\n", $data;

    +{ map { $_ => 1 } split "\n", $ordering_str },
      [ map { [ split /,/ ] } split "\n", $production_str ];

};

sub get_middle_element {
    my ($page) = @_;

    my $middle_index = int( scalar @$page / 2 );
    return $page->[$middle_index];
}

my @processed_pages = map {
    my @original_page = @$_;

    # order the pages by the page ordering rules
    #   if page $b should come before $a, order $b first
    #    otherwise, order $a first
    my @ordered_page =
      sort { $page_ordering_rules->{ $a . '|' . $b } ? -1 : 1 } @original_page;

    [ $_, \@ordered_page ]
} @$pages_to_produce;

say reduce { $a + $b }

  # extract the middle element of the ordered page
  map { int +get_middle_element( $_->[1] ) }

  # collect all valid pages
  grep { join( '', $_->[0]->@* ) eq join( '', $_->[1]->@* ) } @processed_pages;

say reduce { $a + $b }

  # extract the middle element of the ordered page
  map { int +get_middle_element( $_->[1] ) }

  # collect all invalid pages
  grep { join( '', $_->[0]->@* ) ne join( '', $_->[1]->@* ) } @processed_pages;
