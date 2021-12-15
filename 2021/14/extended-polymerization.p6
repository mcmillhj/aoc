#!perl6

my $template; 
my %rules;

for 'input'.IO.lines -> $line {
  next unless $line;

  if $line ~~ /^(<upper>*)$/ {
    $template = $0.Str;
  }

  if $line ~~ /(<upper>)(<upper>) " -> " (<upper>)/ {
    # from a production rule AB -> C produce two pairs AC, CB
    %rules{"$0$1"} = ["$0$2", "$2$1"];
  }
}

# tokenize the initial polymer template into pairs
# ABCD -> AB, BC, CD
my %pairs;
%pairs{"$_[0]$_[1]"}++ for $template.match(/ (.) (.) /, :overlap);

sub next-generation(%rules, %pairs) {
  my %new-pairs; 
  for %pairs.kv -> $pair, $count {
    for %rules{$pair}.List -> $rule {
      %new-pairs{$rule} += $count;
    }
  }

  %new-pairs;
}

sub minmax(%pairs, $template) {
  my %freq;

  # count the occurence of all pairs that start with a given polymer
  for %pairs.keys -> $pair {
    %freq{$pair.substr(0, 1)} += %pairs{$pair};
  }

  # count the final polymer in the template (it does not start any pairs)
  %freq{$template.substr(* - 1)} += 1;

  ([max] %freq.values) - ([min] %freq.values);
}

# part 1
for ^10 {
  %pairs = next-generation(%rules, %pairs);
}

say minmax(%pairs, $template);

# part 2 (we can use the first 10 from part 1)
for 11 .. 40 {
  %pairs = next-generation(%rules, %pairs);
}

say minmax(%pairs, $template);