#!raku

sub priority(Str:D $c where *.chars === 1) {
  if $c ~~ /<[a .. z]>/ {
    return $c.ord - 'a'.ord + 1;
  } else {
    return $c.ord - 'A'.ord + 27;
  }
}

say [+] 'input'.IO.lines.map: -> $line { 
  my ($compartment1, $compartment2) = $line.comb('').rotor($line.chars / 2)>>.Set;

  my $intersection = $compartment1 (&) $compartment2;
  priority($intersection.keys.head());
};

say [+] 'input'.IO.lines.rotor(3).map: -> ($a, $b, $c) {
  my $intersection = $a.comb.Set (&) $b.comb.Set (&) $c.comb.Set;

  priority($intersection.keys.head());
};

