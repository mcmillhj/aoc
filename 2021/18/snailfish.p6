#!perl6

sub explode(@terms) {
  for @terms.kv -> $i, ($value, $depth) {
    next unless $depth == 4;

    my $left-term = @terms[$i - 1];
    my $right-term = @terms[$i + 2];

    # add to left term if possible
    if $left-term {
      @terms[$i - 1] = [@terms[$i - 1][0] + $value, @terms[$i - 1][1]];
    }

    # add to right term if possible
    # the right term is always at i + 2 because terms are pairs
    # $i and $i + 1 make up the left and right pieces of a single pair
    if $right-term {
      @terms[$i + 2] = [@terms[$i + 2][0] + @terms[$i + 1][0], @terms[$i +  2][1]];
    }

    # the exploding term is set to 0 and its depth is now depth - 1 since it is no longer a pair
    @terms[$i] = [0, $depth - 1];

    # remove i + 1 since that pair no longer exists
    @terms.splice($i + 1, 1);

    # return early since explodes + splits need to be processed in order
    return True;
  }

  return False;
}

sub split(@terms) {
  for @terms.kv -> $i, ($value, $depth) {
    if $value >= 10 {
      @terms = flat (
        @terms.head($i),
        [[($value / 2).floor, $depth + 1], [($value / 2).ceiling, $depth + 1]],
        @terms.tail(* - 1 - $i)
      );

      # return early since explodes and splits need to be processed in order
      return True;
    }
  }

  return False;
}

sub sum-snailfish(@terms-a is copy, @terms-b is copy) {
  my @buffer;
  @buffer.append: @terms-a.map(-> ($value, $depth) { [$value, $depth + 1] });
  @buffer.append: @terms-b.map(-> ($value, $depth) { [$value, $depth + 1] });
  
  my $should-continue = False; 
  loop {
     $should-continue = explode(@buffer);

    # process all explodes
    next 
      if $should-continue;

    $should-continue = split(@buffer);

    # process all splits
    next 
      if $should-continue;

    last
  }

  @buffer;
}

sub magnitude(@terms is copy) {
  while @terms.elems > 1 {
    for @terms.kv -> $i, ($value, $depth) {
      next unless $i < @terms.elems - 1;
      my ($next-value, $next-depth) = @terms[$i + 1];
      next unless $depth == $next-depth;

      # compute magnitude for this pair
      my $new-value = 3 * $value + 2 * $next-value;

      # remove pair and add child pair
      @terms[$i] = [$new-value, $depth - 1];
      @terms.splice($i+1, 1);

      last;
    }
  }

  @terms[0][0];
}

my @numbers; 
for 'input.txt'.IO.lines -> $line { 
  my $depth = -1; # count the outermost level as depth=0
  my @number;
  for $line.comb -> $c {
    $depth += 1 if $c eq '[';
    $depth -= 1 if $c eq ']';

    next unless $c ~~ /\d/; 

    @number.push: [$c.Int, $depth];
  }

  @numbers.push: @number;
}

# part 1
# say magnitude(@numbers.reduce(&sum-snailfish));

# part 2
sub all-pairs-magnitudes(@terms) {
  gather {
    for 0 .. @terms.end -> $i {
      for $i + 1 .. @terms.end -> $j {
        take max(
          magnitude(sum-snailfish(@terms[$i], @terms[$j])), 
          magnitude(sum-snailfish(@terms[$j], @terms[$i]))
        );
      }
    }
  }
}

say [max] all-pairs-magnitudes(@numbers);
