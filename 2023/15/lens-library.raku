#!raku

my @lenses = $*IN.slurp.split(',');

sub hash(Str $s) {
    my $digest = 0;
    for $s.comb -> $c {
        $digest += $c.ord;
        $digest *= 17;
        $digest mod= 256;
    }

    return $digest;
}

sub focusing-power(%boxes) {
    [+] %boxes.keys.flatmap(-> $box-number {
        %boxes{$box-number}.kv.map(-> $slot, $lens {
            (1 + $box-number) * ($slot + 1) * ($lens<focal-length>);
        })
    });
}

my %boxes = (^256).map(-> $box-number { $box-number => [] });
for @lenses -> $s {
    my (Str() $label, Str() $operator, Int() $focal-length = -1) := $s ~~ m/(\w+) (<[-=]>) (\d+)?/;

    my $box-number = hash($label);
    given $operator {
        when "-" {
            my $existing-label-index = %boxes{$box-number}.first({ $_<label> eq $label }, :k) // -1;
            if $existing-label-index >= 0 {
                %boxes{$box-number}.splice($existing-label-index, 1);
            }
        }
        when "=" {
            my $existing-label-index = %boxes{$box-number}.first({ $_<label> eq $label }, :k) // -1;
            if $existing-label-index >= 0 {
                %boxes{$box-number}[$existing-label-index]<focal-length> = $focal-length;
            }
            else {
                %boxes{$box-number}.push: { label => $label, focal-length => $focal-length };
            }
        }
    }
}


say "Part 1: " ~ [+] @lenses.map(-> $s { hash($s) });
say "Part 2: " ~ focusing-power(%boxes);