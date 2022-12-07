#!raku 

my @path = [];
my %directory = ();
for 'input'.IO.lines -> $line {
  my ($command, $argument) = $line ~~ /^\$/ ?? $line.split(" ")[1..*] !! $line.split(" ");

  # none of the `ls` commands seem to be repeated so we can assign the file size the current directory (and parents)
  next if $command eq 'ls';
  # dir commands are unused, only the files matter
  next if $command eq 'dir';

  given $command {
    when 'cd' {
      given $argument {
        # `cd /` navigate back to the root, remove the entire path
        when '/' { 
          @path = ['/'];
        } 
        # `cd ..` go back one directly, remove the last `cd` command
        when '..' { 
          @path.pop(); 
        }
        # `cd X` update the current directory to be `X``        
        default { 
          @path.push($argument);
        }
      }
    }
    default {
      for (
        # "/" is always the first element
        @path.head,
        # build out subdirectories
        # if we are currently in directory 'c' but were previously in 'b' and 'a' we need to add the size of this file to 
        # ['/', 'a', 'b', 'c'] maps to `/ /a/ /a/b /a/b/c`
        @path.tail(* - 1).produce({ $^a ~ '/' ~ $^b })
      ).flat -> $p {
        %directory{$p} += $command.Int;
      }
    }
  }
}

say [+] %directory.values.grep: * <= 100000;
say [min] %directory.values.grep: * >= %directory{'/'} - (70000000 - 30000000);