#!raku

sub make-point(Int $x, Int $y --> Complex) {
    $x + $y * 1i;
}

sub is-paper(Str $s) {
    $s eq "@";
}

constant @ADJACENTS = (
  make-point(-1, -1), # left + up
  make-point(-1, +0), # left
  make-point(-1, +1), # left + down
  make-point(+0, +1), # down
  make-point(+1, +1), # down + right
  make-point(+1, +0), # right
  make-point(+1, -1), # right + up
  make-point(+0, -1), # up
);


my Str %paper{Complex};
for $*IN.lines.kv -> $y, $row {
  for $row.comb.kv -> $x, $column {
    %paper{make-point($x, $y)} = $column;
  }
}

sub can-access(Complex $point --> Bool) {
    %paper{$point}:exists and is-paper(%paper{$point}) and @ADJACENTS.grep(-> $adjacent-point {
        my $new-point = $point + $adjacent-point;

        %paper{$new-point}:exists and is-paper(%paper{$new-point})
    }).elems < 4;
}

sub accessible-paper-rolls(@points) {
    @points.grep(-> $p { can-access($p) });
}

my @paper-rolls = accessible-paper-rolls(%paper.keys);

my $accessible-paper-count = 0;
my $accessible-paper-count-without-removal = @paper-rolls.elems;
repeat {
    # count the currently accessible paper rolls
    $accessible-paper-count += @paper-rolls.elems;

    # use the forklift to remove all currently accessible paper rolls
    %paper{@paper-rolls}:delete;

    # find paper rolls that are accessible now that we have removed paper rolls
    @paper-rolls = accessible-paper-rolls(%paper.keys);
} while @paper-rolls.elems > 0;

say $accessible-paper-count-without-removal;
say $accessible-paper-count;