#!raku

enum Rock <HORIZONTAL_LINE PLUS L VERTICAL_LINE SQUARE>;
enum Direction <LEFT RIGHT DOWN>;

class Point {
  has Int $.x;
  has Int $.y;

  method Str { self.x ~ ',' ~ self.y }
  method WHICH { self.Str }
}

constant $CHAMBER_WIDTH = 7;

my @jets = 'input'.IO.slurp.comb().map(-> $j {
  do given $j {
    when "<" { LEFT }
    when ">" { RIGHT }
  }
});

my @rocks = (
  HORIZONTAL_LINE,
  PLUS,
  L,
  VERTICAL_LINE,
  SQUARE
);

# x values are based on rocks starting 2 units from the left of the 7 unit wide vertical chamber
sub get-rock(Int $current-height, Rock $r) {
  do given $r {
    when HORIZONTAL_LINE { 
      SetHash.new: Point.new(x => 2, y => $current-height), Point.new(x => 3, y => $current-height), Point.new(x => 4, y => $current-height), Point.new(x => 5, y => $current-height);
    }
    when PLUS {
      SetHash.new: Point.new(x => 3, y => $current-height), Point.new(x => 2, y => $current-height + 1), Point.new(x => 3, y => $current-height + 1), Point.new(x => 4, y => $current-height + 1), Point.new(x => 3, y => $current-height + 2);
    }
    when L { 
      SetHash.new: Point.new(x => 2, y => $current-height), Point.new(x => 3, y => $current-height), Point.new(x => 4, y => $current-height), Point.new(x => 4, y => $current-height + 1), Point.new(x => 4, y => $current-height + 2);
    }
    when VERTICAL_LINE {
      SetHash.new: Point.new(x => 2, y => $current-height), Point.new(x => 2, y => $current-height + 1), Point.new(x => 2, y => $current-height + 2), Point.new(x => 2, y => $current-height + 3);
    }
    when SQUARE {
      SetHash.new: Point.new(x => 2, y => $current-height + 1), Point.new(x => 3, y => $current-height + 1), Point.new(x => 2, y => $current-height), Point.new(x => 3, y => $current-height);
    }
  }
}

sub move-left(SetHash $rock) {
  # if we have reached the left hand wall of the chamber do not move the rock any further
  if $rock.keys.grep(-> (:$x, :$y) { $x == 0 }) {
    return $rock;
  }

  SetHash.new: $rock.keys.map(-> (:$x, :$y) { 
    Point.new(x => $x - 1, y => $y) }
  )
}

sub move-right(SetHash $rock) {
  # if we have reached the right hand wall of the chamber do not move the rock any further
  if $rock.keys.grep(-> (:$x, :$y) { $x == $CHAMBER_WIDTH - 1 }) {
    return $rock;
  }

  SetHash.new: $rock.keys.map(-> (:$x, :$y) { 
    Point.new(x => $x + 1, y => $y) }
  )  
}

sub move-down(SetHash $rock) {
  SetHash.new: $rock.keys.map(-> (:$x, :$y) { 
    Point.new(x => $x, y => $y - 1) }
  )  
}

sub move-up(SetHash $rock) {
  SetHash.new: $rock.keys.map(-> (:$x, :$y) { 
    Point.new(x => $x, y => $y + 1) }
  )
}

sub get-next-rock(Int $iteration) {
  @rocks[$iteration mod @rocks.elems];
}

sub get-next-move(Int $iteration) {
  @jets[$iteration mod @jets.elems];
}

sub format-rock(SetHash $rock) {
  $rock.keys.map(-> (:$x, :$y) { "(" ~ $x ~ "," ~ $y ~ ")" }).join(", ")
}


sub max-tower-height(Int $num-rocks, Bool $detect-cycle = False) {
  # create a Set of spaces in the chamber that are occupied by rocks
  # initialized to be the "floor"
  my $occupied = SetHash.new: Point.new(x => 0, y => 0), Point.new(x => 1, y => 0), Point.new(x => 2, y => 0), Point.new(x => 3, y => 0), Point.new(x => 4, y => 0), Point.new(x => 5, y => 0), Point.new(x => 6, y => 0);
  my %visited; 
  my $accumulated-cycle-height = 0;
  my $height = 0;
  my $iteration = 0;
  my $direction-index = 0;
  while $iteration < $num-rocks {
    my SetHash $current-rock = get-rock($height + 4, get-next-rock($iteration));

    loop {
      my $direction = get-next-move($direction-index++);

      given $direction {
        when LEFT { 
          $current-rock = move-left($current-rock);

          # moving this space left caused it to collide with an another rock, move it back to the right
          if $current-rock (&) $occupied {
            $current-rock = move-right($current-rock);
          } 
        } 
        when RIGHT {
          $current-rock = move-right($current-rock);

          # moving this rock right caused it to collide with an another rock, move it back to the left
          if $current-rock (&) $occupied {
            $current-rock = move-left($current-rock);
          } 
        }
      }

      # rock falls down 1 unit
      $current-rock = move-down($current-rock);

      # moving this rock down caused it to collide with another rock, move it back up
      # the rock has stopped moving
      if $current-rock (&) $occupied {
        $current-rock = move-up($current-rock);
        # add the current rock to the occupied set
        $occupied = $current-rock (|) $occupied;

        # update height to match the top of the piece with the higest y-value
        $height = max($occupied.keys.map(-> (:$x, :$y) { $y }));

        if $detect-cycle {
          # if we have seen this same shape and direction before, we are at the start of a cycle
          my $cache-key = "$(get-next-rock($iteration))|$($direction-index mod @jets.elems)";
          if %visited{$cache-key}:exists {
            my ($previous-iteration, $previous-height) = %visited{$cache-key};

            # calculate the cycle length
            my $iteration-delta = $iteration - $previous-iteration;

            # calculate the cycle height
            my $height-delta = $height - $previous-height;

            # calculate how many times the cycle repeats
            my $cycle-length = ($num-rocks - $iteration) div $iteration-delta;

            # calculate the total height of the cycle after repeats (cycle length * |height - previous height|)
            my $cycle-height = $cycle-length * $height-delta - 1;

            # only consider cycles that evenly map into the remaining rocks
            if ($num-rocks - $iteration) mod $cycle-length == 0 {
              # for each detected cycle store its length to be added to the final result
              # on iteration $num-rocks
              $accumulated-cycle-height += $cycle-height;

              # jump to the iteration after this cycle
              $iteration += $cycle-length * $iteration-delta;
            }
          }

          %visited{$cache-key} = [$iteration, $height];
        }

        # this rock has come to a rest, move to the next rock
        last;
      }
    }

    $iteration += 1;
  }

  $accumulated-cycle-height + max($occupied.keys.map(-> (:$x, :$y) { $y }));
}


say max-tower-height(2022);
say max-tower-height(1000000000000, True);


