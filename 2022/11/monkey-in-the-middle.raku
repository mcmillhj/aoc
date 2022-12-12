#!raku 

my @monkeys;

class Monkey {
  has Str $.name is rw;
  has Int @.items is rw;  
  has $.operation is rw;
  has $.divisor is rw; 
  has Int %.actions{Bool} is rw;
  has Int $.inspection-count is rw = 0;

  method inspect(Sub $extra-op) {
    # mark all of the items as inspected
    $.inspection-count += @.items.elems;

    # apply the operation to all items the monkey has
    for @.items -> $item {
      my ($op, $value) = $.operation.list;

      # compute the new worry-level based on the current item and operation
      my $new-item = $extra-op(do given $op { 
        when '+' { ($item + ($value eq 'old' ?? $item !! $value.Int)) } 
        when '*' { ($item * ($value eq 'old' ?? $item !! $value.Int)) } 
      });

      # throw the item to the next monkey
      @monkeys[%.actions{$new-item mod $.divisor == 0}].items.push: $new-item;

      # remove items one the monkey is finished inspecting
      @.items = [];
    }
  }
}

for 'input'.IO.slurp.split("\n\n") -> $lines {
  my $m = Monkey.new();

  my ($name, $items, $operation, $test, $if-true, $if-false) = $lines.split("\n")>>.trim;

  if $name ~~ m/'Monkey' \s (\d+)/ {
    $m.name = ~$0;
  }

  if $items ~~ /'Starting items:' \s (.*)/ {
    $m.items = [(~$0).split(",")>>.trim>>.Int];
  }

  if $operation ~~ /'Operation:' \s 'new = old' \s (<[+*]>) \s (\d+|'old')/ {
    $m.operation = [~$0, ~$1];
  }

  if $test ~~ /'Test:' \s 'divisible by' \s (\d+)/ {
    $m.divisor = (~$0).Int;
  } 

  if $if-true ~~ /'If true:' \s 'throw to monkey' \s (\d+)/ {
    $m.actions{True} = (~$0).Int;
  }

  if $if-false ~~ /'If false:' \s 'throw to monkey' \s (\d+)/ {
    $m.actions{False} = (~$0).Int;
  }  

  # say $m; die;
  @monkeys.push($m);
}

# part 1
for ^20 {
  for @monkeys -> $monkey {
    $monkey.inspect(sub ($n) { $n div 3 });
  }
}

say [*] @monkeys.sort({ $^b.inspection-count <=> $^a.inspection-count })[0..1].map({ $_.inspection-count });


# part 2
# find the lcm of all the divisors for each monkey
# this allows us to scale down the number with modulus without affecting 
# invidual divisiblity tests
my $lcm-of-divisors = [lcm] @monkeys.map: { .divisor };

for ^10000 {
  for @monkeys -> $monkey {
    $monkey.inspect(sub ($n) { $n mod $lcm-of-divisors });
  }
}

say [*] @monkeys.sort({ $^b.inspection-count <=> $^a.inspection-count })[0..1].map({ $_.inspection-count });

