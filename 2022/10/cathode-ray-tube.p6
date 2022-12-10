#!raku

my @commands = 'input'.IO.lines>>.split(" ");

sub cycle(@commands) {
  my $current-cycle = 1;
  my $register = 1;

  gather {
    for @commands -> $c {
      my ($command, $argument) = $c;

      given $command {
        when 'noop' { 
          take $current-cycle, $register;

          $current-cycle += 1;
        }
        when 'addx' { 
          take $current-cycle, $register; 
          $current-cycle += 1;

          take $current-cycle, $register; 
          $current-cycle += 1;

          $register += $argument;
        }
      }
    }
  }
}

my @signals = [20, 60, 100, 140, 180, 220];
my $CRT-HEIGHT = 6;
my $CRT-WIDTH = 40;
my %screen;
say [+] gather {
  for cycle(@commands) -> ($current-cycle, $register-value) {
    my $column = ($current-cycle - 1) mod $CRT-WIDTH;
    my $row = ($current-cycle - 1) div $CRT-WIDTH;
    
    if $register-value - 1 <= $column <= $register-value + 1 {
      %screen{$column ~ "," ~ $row} = '#'
    } else {
      %screen{$column ~ "," ~ $row} = '.'
    }

    next unless @signals.grep: * == $current-cycle;

    take $current-cycle * $register-value;
  }
}; 

for ^$CRT-HEIGHT -> $row { 
  for ^$CRT-WIDTH -> $column {
    print %screen{$column ~ "," ~ $row}
  }
  print "\n"; 
}