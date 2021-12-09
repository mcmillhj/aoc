#!perl6

#   0:      1:      2:      3:      4:
#  aaaa    ....    aaaa    aaaa    ....
# b    c  .    c  .    c  .    c  b    c
# b    c  .    c  .    c  .    c  b    c
#  ....    ....    dddd    dddd    dddd
# e    f  .    f  e    .  .    f  .    f
# e    f  .    f  e    .  .    f  .    f
#  gggg    ....    gggg    gggg    ....

#   5:      6:      7:      8:      9:
#  aaaa    aaaa    aaaa    aaaa    aaaa
# b    .  b    .  .    c  b    c  b    c
# b    .  b    .  .    c  b    c  b    c
#  dddd    dddd    ....    dddd    dddd
# .    f  e    f  .    f  e    f  .    f
# .    f  e    f  .    f  e    f  .    f
#  gggg    gggg    ....    gggg    gggg

sub find-number-from-segment(Set $segment) {
  given $segment {
    when <a b c e f g>.Set   { 0 }
    when <c f>.Set           { 1 }
    when <a c d e g>.Set   { 2 }
    when <a c d f g>.Set     { 3 }
    when <b c d f>.Set       { 4 }
    when <a b d f g>.Set     { 5 }
    when <a b d e f g>.Set   { 6 }
    when <a c f>.Set         { 7 }
    when <a b c d e f g>.Set { 8 }
    when <a b c d f g>.Set   { 9 }
  }
}

sub create-decoder(@signals) {
  my $one = @signals.first: *.elems == 2;
  my $four = @signals.first: *.elems == 4;
  my $seven = @signals.first: *.elems == 3;
  my $eight = @signals.first: *.elems == 7;

  my @six-segments = @signals.grep: *.elems == 6;
  my $nine = @six-segments.first({ $_ (&) $four (==) $four });
  my $six = @six-segments.first({ $_ (&) $one !(==) $one });
  my $zero =  @six-segments.first({ $_ !(==) $nine && $_ !(==) $six });

  my @five-segments = @signals.grep: *.elems == 5;
  my $three = @five-segments.first({ $_ (>) $one });
  my $five = @five-segments.first({ $_ (>) ($four (-) ($one)) });
  my $two = @five-segments.first({ $_ !(==) $three && $_ !(==) $five });


  # 7 - 1 isolates the top segment
  my $encoded_a = $seven (-) $one;
  # 4 - 3 isolates the top-left segment
  my $encoded_b = $four (-) $three;
  # 4 - 6 isolates the top-right segment
  my $encoded_c = $four (-) $six;
  # 4 - 0 isolates the middle segment
  my $encoded_d = $four (-) $zero;
  # 2 - 3 isolates the bottom-left segment
  my $encoded_e = $two (-) $three;
  # (4 U 1) - 2 isolates the bottom-right segment
  my $encoded_f = ($four (&) $one) (-) $two; 
  # 9 - 4 - 7 isolates the top-right segment
  my $encoded_g = $nine (-) $four (-) $seven;

  return -> $input {
    given $input  {
      when $encoded_a { 'a' }
      when $encoded_b { 'b' }
      when $encoded_c { 'c' }
      when $encoded_d { 'd' }
      when $encoded_e { 'e' }
      when $encoded_f { 'f' }
      when $encoded_g { 'g' }
    }
  }
}

my $sum = 0;
for 'input'.IO.lines -> $line {
  my ($signal_strings, $output_strings) = $line.split(" | ")>>.split(" ");
  my @signals = $signal_strings.map({ .comb.Set });
  my @outputs = $output_strings.map({ .comb.Set });

  for @signals, @outputs -> $signal, $output {
    my $decode = create-decoder($signal);

    $sum += @$output.map(-> $output {
      my $unscrambled-segment = $output.map($decode).Set;

      find-number-from-segment($unscrambled-segment);
    }).join('').Int;
  }
}

say $sum;