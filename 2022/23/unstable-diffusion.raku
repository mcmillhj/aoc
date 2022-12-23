#!raku

enum Direction <NORTHWEST NORTH NORTHEAST EAST SOUTHEAST SOUTH SOUTHWEST WEST>;

class Point {
  has Int $.x is rw;
  has Int $.y is rw;

  has @!directions = (
    [ -1, -1 ], # north + west
    [ +0, -1 ], # north
    [ +1, -1 ], # north + east
    [ +1, +0 ], # east
    [ +1, +1 ], # south + east
    [ +0, +1 ], # south
    [ -1, +1 ], # south + west
    [ -1, +0 ], # west
  );

  method move(Direction $d, Int $distance = 1) {
    do given $d {
      when NORTHWEST { Point.new(x => self.x - $distance, y => self.y - $distance) }
      when NORTH     { Point.new(x => self.x - $distance, y => self.y)             }
      when NORTHEAST { Point.new(x => self.x - $distance, y => self.y + $distance) }
      when EAST      { Point.new(x => self.x,             y => self.y + $distance) }
      when SOUTHEAST { Point.new(x => self.x + $distance, y => self.y + $distance) }
      when SOUTH     { Point.new(x => self.x + $distance, y => self.y)             }
      when SOUTHWEST { Point.new(x => self.x + $distance, y => self.y - $distance) }
      when WEST      { Point.new(x => self.x,             y => self.y - $distance) }
    }
  }

  method northern-adjacents() {
    [NORTHWEST, NORTH, NORTHEAST].map(-> Direction $d { self.move($d) })
  }

  method southern-adjacents() {
    [SOUTHWEST, SOUTH, SOUTHEAST].map(-> Direction $d { self.move($d) })
  }

  method western-adjacents() {
    [NORTHWEST, WEST, SOUTHWEST].map(-> Direction $d { self.move($d) })
  }

  method eastern-adjacents() {
    [NORTHEAST, EAST, SOUTHEAST].map(-> Direction $d { self.move($d) })
  }

  method adjacents() {
    @!directions.map: -> ($dx, $dy) { 
      Point.new(x => self.x + $dx, y => self.y + $dy) 
    }
  }

  method Str {
    self.x ~ ',' ~ self.y;
  }

  method WHICH() {
    self.Str
  }
}

my Str %grove{Point};

sub is-elf(Point $p) {
  %grove{$p}:exists and %grove{$p} eq '#'
}

class Elf is Point {
  has $!direction-index = 0; 
  has @!directions = [NORTH, SOUTH, WEST, EAST];

  method should-move() {
    any(self.adjacents.map(-> Point $p { is-elf($p) }))
  }

  method propose-move() {
    for $!direction-index ..^ $!direction-index + @!directions.elems -> $index {
      my $direction = @!directions[$index mod @!directions.elems];
      my @adjacents = do given $direction {
        when NORTH { self.northern-adjacents }
        when SOUTH { self.southern-adjacents }
        when WEST  { self.western-adjacents  }
        when EAST  { self.eastern-adjacents  }
      };

      # if none of the adjacent cells are elves
      if none(@adjacents.map(-> Point $p { is-elf($p) })) {
        return self.move($direction);
      }
    }
  }

  method finalize-move {
    # change the direction for the start of the next round
    $!direction-index += 1;
  }
}

# maintain a Set of all Elves so that we can track their positions over time
my SetHash[Elf] $elves = SetHash[Elf].new;
for 'input'.IO.lines.kv -> $row, $line {
  for $line.comb.kv -> $column, $board-value {
    if $board-value eq '#' {
      my $elf = Elf.new(x => $row, y => $column);
      $elves.set: $elf;
      %grove{$elf} = $board-value;
    } else {
      %grove{Point.new(x => $row, y => $column)} = $board-value;
    }
  }
}

my $round = 1;
loop {
  say "Starting round $round...";
  my Array[Point] %proposed-moves{Point};
  for $elves.keys -> $elf {
    # skip this elf if there are no elves in any adjacent cells
    next unless $elf.should-move;

    # calculate next move
    my $proposed-move = $elf.propose-move;

    # do not move if there is at least one Elf in all possible direction
    next unless $proposed-move;

    %proposed-moves{$proposed-move}.push: $elf;
  }

  for $elves.keys -> $elf {
    $elf.finalize-move;
  }

  # stop looping if no elves need to move
  if %proposed-moves.elems == 0 {
    last;
  }

  for %proposed-moves.kv -> $destination-point, $source-elves {
    # elves only move if they were the only Elf that proposed a move
    next unless $source-elves.elems == 1;

    my ($source-elf) = @$source-elves;

    # update the board state
    %grove{$source-elf} = '.';
    %grove{$destination-point} = '#';

    # move the elf to their new position by reference
    $source-elf.x = $destination-point.x;
    $source-elf.y = $destination-point.y;
  }

  $round++;

  if $round == 10 {
    my $min-x = [min] $elves.keys.map(-> Elf $e { $e.x });
    my $max-x = [max] $elves.keys.map(-> Elf $e { $e.x });
    my $min-y = [min] $elves.keys.map(-> Elf $e { $e.y });
    my $max-y = [max] $elves.keys.map(-> Elf $e { $e.y });

    say "Part 1 = " ~ ($max-x - $min-x + 1) * ($max-y - $min-y + 1) - $elves.elems;
  }
}

say $round;