#!perl 

use strict;
use warnings;

use feature qw(say);

my @instructions = do {
    local $/ = undef;

    my $corrupted_memory = readline( \*STDIN );
    $corrupted_memory =~ m/mul\(\d+,\d+\)|do\(\)|don't\(\)/g;
};

my $sum = 0;
foreach (@instructions) {
    next if /^don't/ .. /^do(?!n)/;
    next unless /^mul/;

    my ( $a, $b ) = $_ =~ m/(\d+)/g;
    $sum += $a * $b;
}

say $sum;
