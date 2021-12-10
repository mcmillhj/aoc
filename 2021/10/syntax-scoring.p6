#!perl6

my %symbols = (
  '(' => ')',
  '[' => ']',
  '{' => '}',
  '<' => '>',
);

my %opening-symbols = %symbols.keys.Bag;
my %closing-symbols = %symbols.values.Bag;


sub handle-corrupted(Str $closing-symbol) {
  given $closing-symbol {
    when ')' {     3 }
    when ']' {    57 }
    when '}' {  1197 }
    when '>' { 25137 }
  }
}

sub handle-incomplete(Str @remaining-symbols) {
  my $acc = 0;
  for @remaining-symbols.reverse() -> $current {
    $acc = $acc * 5 + (
      given $current {
        when '(' { 1 }
        when '[' { 2 }
        when '{' { 3 }
        when '<' { 4 }
      }
    );
  }

  return $acc;
}

my @navigation-commands = 'input'.IO.lines>>.comb;
my @corrupt-commands; 
my @incomplete-commands; 

# part 1 
for @navigation-commands -> $command {
  my Str @stack;

  my $is-corrupt = False;
  for @$command -> $symbol {
    # when we encounter an opening symbol, push it onto the stack
    if %opening-symbols{$symbol} {
      @stack.push: $symbol;
    }

    # when we encounter a closing symbol, pop the stack
    # test if the previous symbol was the expecting opening symbol
    # if yes continue
    # else, this sequence is invalid
    if %closing-symbols{$symbol} {
      my $opening-symbol = @stack.pop;
      if (!$opening-symbol || %symbols{$opening-symbol} ne $symbol) {
        @corrupt-commands.push: $symbol;
        $is-corrupt = True;
        last;
      }
    }
  }


  if ! $is-corrupt {
    @incomplete-commands.push: @stack
  }
}

# part 1
say [+] @corrupt-commands.map(&handle-corrupted);

# part 2
say @incomplete-commands.map(&handle-incomplete).sort[@incomplete-commands.elems / 2];
