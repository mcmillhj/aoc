#!raku

sub mix(Pair @coordinates) {
  for 0 ..^ @coordinates.elems -> $index {
    say "Index $index ..." if $index mod 1000 == 0;
    my $source-index = @coordinates.first(-> (:$key, :$value) { $key == $index }, :k);
    next unless defined $source-index; 

    # get the source coordinate 
    my Pair $coordinate = @coordinates[$source-index];

    # 0 does not move
    next if $coordinate.value === 0;

    # determine index this coordinate should be moved to
    my $target-index = ($source-index + $coordinate.value) mod (@coordinates.elems - 1);

    # next if $target-index == $source-index;
    if $target-index == $source-index {
      next;
    }

    # remove coordinate at current index
    @coordinates.splice($source-index, 1);

    # insert coordinate at target index
    @coordinates.splice($target-index, 0, $coordinate);
  }
}


# part 1
{
  my Pair @encrypted-coordinates = 'input'.IO.slurp.split("\n")>>.Int.pairs;
  mix(@encrypted-coordinates);

  my $zero-index = @encrypted-coordinates.first(-> (:$key, :$value) { $value == 0 }, :k);
  say [+] [1000,2000,3000].map(-> $ith {
    @encrypted-coordinates[($ith + $zero-index) mod @encrypted-coordinates.elems].value;
  });
}

# part 2
{
  my Pair @encrypted-coordinates = 'input'.IO.slurp.split("\n")>>.Int.pairs;  
  my $decryption-key = 811589153;
  my Pair @decrypted-coordinates = @encrypted-coordinates.map(-> (:$key, :$value) { $key => $value * $decryption-key });
  for ^10 {
    mix(@decrypted-coordinates);
    say '-' x 120;
  }

  my $zero-index = @decrypted-coordinates.first(-> (:$key, :$value) { $value == 0 }, :k);
  say [+] [1000,2000,3000].map(-> $ith {
    @decrypted-coordinates[($ith + $zero-index) mod @decrypted-coordinates.elems].value;
  });
}