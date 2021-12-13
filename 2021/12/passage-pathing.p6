#!perl6

my %adjacency-list; 

for 'input'.IO.lines>>.split('-') -> [$source, $target] {
  if $source ne 'start' {
    %adjacency-list{$target}.push: $source;
  }

  if $target ne 'start' {
    %adjacency-list{$source}.push: $target;
  }
}

sub walk(%caves, %visited is copy, $current) {
  # if we have found the 'end' token, count it and return
  return 1 if $current eq 'end';


  # mark that we have visited this node 
  %visited{$current}++;

  # find the maximum number of times a small cave has been visited
  my $number-of-small-cave-visits = [max] %visited.kv.grep(-> $k, $v { $k.lc eq $k }).map(-> ($k, $v) { $v });
  
  my $count = 0;
  for %adjacency-list{$current}.flat -> $next {
    # recurse if:
    #  1. we have not visited this cave
    #  2. this is a small cave, and we have not already visited a small cave twice
    #  3. this is a big cave
    if $number-of-small-cave-visits < 2 or %visited{$next}:!exists or $next.uc eq $next {
      $count += walk(%caves, %visited, $next);
    }
  }

  $count;
}

say walk(%adjacency-list, %(), 'start');