#!raku

my $complete-overlaps = 0;
my $partial-overlaps = 0;
for 'input'.IO.lines -> $line {
  my ($start1, $end1, $start2, $end2) = $line.split(',')>>.split('-').flat;

  # s1,e1 completely overlaps s2,e2 if s1,e1 starts before and ends after s2,e2
  # s2,e2 completely overlaps s1,e1 if s2,e2 starts before and ends after s1,e1
  if $start1 <= $start2 and $end1 >= $end2 or $start2 <= $start1 and $end2 >= $end1 {
    $complete-overlaps  += 1;   
  }

  # s2,e2 partially overlaps s1,s2 if s2,e2 not completely to the left or right of s1,s2
  if not ($end1 < $start2 or $start1 > $end2) {
    $partial-overlaps += 1;
  }
}

say $complete-overlaps;
say $partial-overlaps;