#!raku

sub scratchcard-points(Int $matches) {
    return 0 if $matches == 0;

    return 2 ** ($matches - 1);
}

my $points = 0;
my %scratchcard-copies; 
for 'input.txt'.IO.lines.kv -> $card-number, $line {
    # initialize each card to have a single copy
    %scratchcard-copies{$card-number} += 1;

    # convert the winning numbers and numbers you have to Sets and find the intersection
    my $matches = [(&)] $line.split(":")[1].split(' | ').map: { .comb(/\d+/).Set };

    # part 1
    # the number of points is equal to 2 ^ <number of matches> - 1
    # 1 => 1, 2 => 2, 3 => 4, 4 => 8, etc... 
    $points += scratchcard-points($matches.elems);

    # part 2
    # winning now provides copies of cards below the winning card I equal to the number of matches M
    # when you "win" you gain N copies of each card from (I, I + M) where N is equal to the number
    # copies of the current card that you hold
    # (e.g.) If you hold 2 copies of Card 5 and win with 4 matches. You gain two copies each of
    # Card 6, Card 7, Card 8, and Card 9
    for ^$matches {
        %scratchcard-copies{$card-number + $_ + 1} += %scratchcard-copies{$card-number};
    }
}
say $points;
say [+] %scratchcard-copies.values;