#!raku

sub snafu-to-base-ten(Str $s where *.chars == 1, $place) {
  do given $s {
    when '-' { -1 }
    when '=' { -2 }
    default {
      $s.Int
    }
  } * (5 ** $place)
}

sub from-snafu(Str $s) {
  [+] $s.comb.kv.map(-> $i, $c { 
    snafu-to-base-ten($c, $s.chars - $i - 1)
  })
}

sub to-snafu(Int $n) {
  return "" if $n == 0;

  do given $n mod 5 {
    when 0 { to-snafu($n div 5)       ~ "0" }
    when 1 { to-snafu($n div 5)       ~ "1" }
    when 2 { to-snafu($n div 5)       ~ "2" }
    # snafu cannot represent N mod 5 = 3 or N mod 5 = 4 without offsetting the 
    # next division by +2 or +1
    when 3 { to-snafu(($n + 2) div 5) ~ "=" }
    when 4 { to-snafu(($n + 1) div 5) ~ "-" }
  }
}

say to-snafu [+] 'input'.IO.lines.map(-> $snafu-number { 
  from-snafu($snafu-number);
});