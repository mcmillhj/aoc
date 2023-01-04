#!raku 

our %distances;
our %flow-rates;
our %cache;

class Valve {
  has $.name;
  has $.flow-rate;
  has @.next-valves;

  method Str { join("|", self.name, self.flow-rate, self.next-valves.join(';')); }
  method WHICH {
    self.Str
  }
}

# compute the shortest path between all valves
sub compute-distances(Valve @valves) {
  my %distances; 
  for @valves -> $v {
    # distance between this valve and itself is 0
    %distances{$v.name}{$v.name} = 0;

    # distance between this valve and neighboring valves is 1
    for $v.next-valves -> $nv {
      %distances{$v.name}{$nv} = 1
    }
  }

  my @valve-names = @valves>>.name;
  for (@valve-names X @valve-names X @valve-names) -> ($k, $i, $j) {
    %distances{$i}{$j} //= 1000;
    %distances{$i}{$k} //= 1000;
    %distances{$k}{$j} //= 1000;

    %distances{$i}{$j} min= %distances{$i}{$k} + %distances{$k}{$j};
  }

  %distances
}


sub search(Int $remaining-time, Str $start-node, @valves, Bool $elephants-helping = False) {
  my $cache-key = $remaining-time ~ ":" ~ $start-node ~ ":" ~ @valves.join(";") ~ ":" ~ $elephants-helping;
  if %cache{$cache-key}:exists {
    return %cache{$cache-key};
  }

  my $maximum-flow = 0;
  for @valves -> $v {
    # skip if moving to this valve from $start-node would take longer than the remaining time
    next unless %distances{$start-node}{$v} < $remaining-time;

    # the amount of time left after we open this valve 
    # is the current time minus the distance it took us to get to this valve minus 1
    # the final minus 1 because opening the valve takes 1 minute
    my $time-after-this-valve = 
      $remaining-time - %distances{$start-node}{$v} - 1;

    # the total pressure from this valve across the entire time the valve is open
    my $flow-valve-after-opening = %flow-rates{$v} * $time-after-this-valve;

    # record the maximum pressure of opening this valve + any connected valves
    $maximum-flow max=
      $flow-valve-after-opening + search(
        $time-after-this-valve,
        $v,
        @valves.grep(* ne $v),
        $elephants-helping
      );
  }

  
  # part 2
  # or opening the starting valve + any connected valves with the help of the elephants
  if $elephants-helping {
    $maximum-flow max= search(26, 'AA', @valves);
  }

  %cache{$cache-key} = $maximum-flow;
  $maximum-flow
}

sub MAIN(IO() $inputfile where *.f = 'input') {
  my Valve @valves;
  for $inputfile.IO.lines -> $line {
    my (Int() $flow-rate) := $line ~~ m/'flow rate=' (\d+)/;
    my ($valve, @other-valves) = ($line ~~ m:g/(<[A .. Z]> ** 2)/).map({ ~$_ });

    @valves.push: Valve.new(
      name        => $valve,
      flow-rate   => $flow-rate,
      next-valves => @other-valves
    );
  }

  %distances = compute-distances(@valves); 

  # calculate the flow rates for each valve
  # valves with 0 flow rate can be ignored since they cannot be opened
  %flow-rates = @valves
    .grep(-> $v { $v.flow-rate > 0 })
    .map(-> $v { $v.name => $v.flow-rate });

  # part 1
  say search(30, 'AA', %flow-rates.keys);

  # %c = ();

  # part 2
  say search(26, 'AA', %flow-rates.keys, True);
}