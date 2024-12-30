#!raku 

use experimental :cached;

sub prune(Int $secret --> Int) {
    $secret mod 16777216;
}

sub mix(Int $secret, Int $mixer --> Int) {
    $secret +^ $mixer;
}

sub calculate-next-secret(Int $secret is copy) {
    $secret = prune( mix($secret, $secret * 64) );
    $secret = prune( mix($secret, $secret div 32) );
    $secret = prune( mix($secret, $secret * 2048) );

    $secret
}

sub calculate-n-secrets(Int $initial-secret, Int $n = 2000) is cached {
    my @secrets = $initial-secret, { calculate-next-secret($_) } ... *;

    @secrets[0 .. $n];
}


my @initial-secrets = $*IN.lines>>.Int;

say [+] @initial-secrets.map: -> $initial-secret { calculate-n-secrets($initial-secret)[* - 1] };

my Int %banana-cost-by-sequence{Str} is default(0);
for @initial-secrets -> $initial-secret {
    # calculate the first 2000 secrets
    my @secrets = calculate-n-secrets($initial-secret);

    # calculate the successive differences between the tens place of each secret to determine the 'price'
    my @differences = @secrets.map(-> $secret { $secret mod 10 }).rotor(2 => -1).map(-> ($a, $b) { $b - $a });
    
    # iterate over all sequences of length 4 to determine how much the sequence affects the final cost
    # each 'buyer' will only process each sequence once
    my $seen = SetHash[Str].new;
    for ^(@secrets.elems - 4) -> $index {
        my @sequence = @differences[$index ..^ $index + 4];

        # if this 'buyer' has not already seen this sequence, update the maximum bananas than can be provided for this sequence
        my $sequence-key = @sequence.join(';');
        if not $seen{$sequence-key}:exists {
            %banana-cost-by-sequence{$sequence-key} += @secrets[$index + 4] mod 10;
            
            # record that this buyer has already seen now sequence
            $seen.set: $sequence-key;
        }
    }
}

say [max] %banana-cost-by-sequence.values;