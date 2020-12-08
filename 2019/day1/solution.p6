#!perl6

sub calculateFuel(Int $mass is copy --> Int) {
  return 0 if $mass <= 0;
  my $new-mass = floor($mass / 3) - 2;
  return 0 if $new-mass <= 0;

  return $new-mass + calculateFuel($new-mass);
}

my $sum = 0;
for 'input.txt'.IO.lines -> $line {
  $sum += calculateFuel($line.Int);
}

say $sum;
