#!perl 

my $dots = SetHash.new;
my @folds; 

for 'input'.IO.lines -> $line {
  next unless $line;

  if $line ~~ /(\d+)","(\d+)/ {
    $dots.set: ($0.Int ~ '-' ~ $1.Int);
  }

  if $line ~~ /"fold along "(.)\=(\d+)/ {
    @folds.push: ($0.Str => $1.Int);
  }
}

sub print-paper($dots) {
  # 6 and 40 come from the final horizontal and vertical fold values
  for ^6 -> $y {
    for ^40 -> $x {
      if $dots{$x ~ '-' ~ $y} {
        print "#";
      } else {
        print ".";
      }
    }
  
    print "\n";
  }
}

sub translate(Int $position, Int $offset) {
  $offset - abs($offset - $position);
}

sub fold($dots, $axis, $offset) {
  my $new-dots = SetHash.new;

  for $dots.keys -> $dot {
    my ($x, $y) = $dot.split('-')>>.Int;

    given $axis {
      when 'x' { my $new-x = translate($x, $offset); $new-dots.set: ($new-x ~ '-' ~ $y); }
      when 'y' { my $new-y = translate($y, $offset); $new-dots.set: ($x ~ '-' ~ $new-y); }
    }
  }

  return $new-dots;
}

# part 1 
my $p1 = SetHash.new($dots.keys);
for @folds -> $fold {
  $p1 = fold($p1, $fold.key, $fold.value);

  last;
}

say $p1.elems;

# part 2
my $p2 = SetHash.new($dots.keys);
for @folds -> $fold {
  $p2 = fold($p2, $fold.key, $fold.value);
}

print-paper($p2);