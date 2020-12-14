#!perl 

use strict;
use warnings;

use feature qw(say);

# --- Day 11: Seating System ---

# Your plane lands with plenty of time to spare. The final leg of your journey is a ferry that goes directly to the tropical island where you can finally start your vacation. As you reach the waiting area to board the ferry, you realize you're so early, nobody else has even arrived yet!

# By modeling the process people use to choose (or abandon) their seat in the waiting area, you're pretty sure you can predict the best place to sit. You make a quick map of the seat layout (your puzzle input).

# The seat layout fits neatly on a grid. Each position is either floor (.), an empty seat (L), or an occupied seat (#). For example, the initial seat layout might look like this:

# L.LL.LL.LL
# LLLLLLL.LL
# L.L.L..L..
# LLLL.LL.LL
# L.LL.LL.LL
# L.LLLLL.LL
# ..L.L.....
# LLLLLLLLLL
# L.LLLLLL.L
# L.LLLLL.LL

# Now, you just need to model the people who will be arriving shortly. Fortunately, people are entirely predictable and always follow a simple set of rules. All decisions are based on the number of occupied seats adjacent to a given seat (one of the eight positions immediately up, down, left, right, or diagonal from the seat). The following rules are applied to every seat simultaneously:

#     If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
#     If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
#     Otherwise, the seat's state does not change.

# Floor (.) never changes; seats don't move, and nobody sits on the floor.

# After one round of these rules, every seat in the example layout becomes occupied:

# #.##.##.##
# #######.##
# #.#.#..#..
# ####.##.##
# #.##.##.##
# #.#####.##
# ..#.#.....
# ##########
# #.######.#
# #.#####.##

# After a second round, the seats with four or more occupied adjacent seats become empty again:

# #.LL.L#.##
# #LLLLLL.L#
# L.L.L..L..
# #LLL.LL.L#
# #.LL.LL.LL
# #.LLLL#.##
# ..L.L.....
# #LLLLLLLL#
# #.LLLLLL.L
# #.#LLLL.##

# This process continues for three more rounds:

# #.##.L#.##
# #L###LL.L#
# L.#.#..#..
# #L##.##.L#
# #.##.LL.LL
# #.###L#.##
# ..#.#.....
# #L######L#
# #.LL###L.L
# #.#L###.##

# #.#L.L#.##
# #LLL#LL.L#
# L.L.L..#..
# #LLL.##.L#
# #.LL.LL.LL
# #.LL#L#.##
# ..L.L.....
# #L#LLLL#L#
# #.LLLLLL.L
# #.#L#L#.##

# #.#L.L#.##
# #LLL#LL.L#
# L.#.L..#..
# #L##.##.L#
# #.#L.LL.LL
# #.#L#L#.##
# ..L.L.....
# #L#L##L#L#
# #.LLLLLL.L
# #.#L#L#.##

# At this point, something interesting happens: the chaos stabilizes and further applications of these rules cause no seats to change state! Once people stop moving around, you count 37 occupied seats.

# Simulate your seating area by applying the seating rules repeatedly until no seats change state. How many seats end up occupied?

my @initial_seats;
while (my $line = readline(\*DATA)) {
  chomp($line);
  push @initial_seats, [ split //, $line ];
}

sub is_empty    { shift eq 'L'; }
sub is_occupied { shift eq '#'; }

my @directions = (
  [ 0,  -1 ],    # up
  [ 1,  -1 ],    # upper right diagonal
  [ 1,  0 ],     # right
  [ 1,  1 ],     # lower right diagonal
  [ 0,  1 ],     # down
  [ -1, 1 ],     # lower left diagonal
  [ -1, 0 ],     # left
  [ -1, -1 ],    # upper left diagonal
);

sub transition {
  my (@seats) = @_;

  my @seats_copy = map { [@$_] } @seats;
  my $changed    = 0;
  foreach my $i (0 .. $#seats) {
    foreach my $j (0 .. $#{ $seats[$i] }) {
      my $occupied_seats = grep { is_occupied($_) }
        grep { $_ }
        map  { $seats[ $i + $_->[0] ]->[ $j + $_->[1] ] }
        grep { $i + $_->[0] >= 0 and $j + $_->[1] >= 0 } @directions;

      if (is_empty($seats[$i]->[$j]) and $occupied_seats == 0) {
        $seats_copy[$i]->[$j] = '#';
        $changed = 1;
      }
      elsif (is_occupied($seats[$i]->[$j]) and $occupied_seats >= 4) {
        $seats_copy[$i]->[$j] = 'L';
        $changed = 1;
      }
    }
  }

  return ($changed, @seats_copy);
}

{
  my ($changed, @layout) = (0, @initial_seats);
  do {
    ($changed, @layout) = transition(@layout);
  } while ($changed);

  my $occupied_seats = 0;
  foreach my $row (@layout) {
    foreach my $col (@$row) {
      $occupied_seats++ if is_occupied($col);
    }
  }
  say $occupied_seats;
}

# --- Part Two ---

# As soon as people start to arrive, you realize your mistake. People don't just care about adjacent seats - they care about the first seat they can see in each of those eight directions!

# Now, instead of considering just the eight immediately adjacent seats, consider the first seat in each of those eight directions. For example, the empty seat below would see eight occupied seats:

# .......#.
# ...#.....
# .#.......
# .........
# ..#L....#
# ....#....
# .........
# #........
# ...#.....

# The leftmost empty seat below would only see one empty seat, but cannot see any of the occupied ones:

# .............
# .L.L.#.#.#.#.
# .............

# The empty seat below would see no occupied seats:

# .##.##.
# #.#.#.#
# ##...##
# ...L...
# ##...##
# #.#.#.#
# .##.##.

# Also, people seem to be more tolerant than you expected: it now takes five or more visible occupied seats for an occupied seat to become empty (rather than four or more from the previous rules). The other rules still apply: empty seats that see no occupied seats become occupied, seats matching no rule don't change, and floor never changes.

# Given the same starting layout as above, these new rules cause the seating area to shift around as follows:

# L.LL.LL.LL
# LLLLLLL.LL
# L.L.L..L..
# LLLL.LL.LL
# L.LL.LL.LL
# L.LLLLL.LL
# ..L.L.....
# LLLLLLLLLL
# L.LLLLLL.L
# L.LLLLL.LL

# #.##.##.##
# #######.##
# #.#.#..#..
# ####.##.##
# #.##.##.##
# #.#####.##
# ..#.#.....
# ##########
# #.######.#
# #.#####.##

# #.LL.LL.L#
# #LLLLLL.LL
# L.L.L..L..
# LLLL.LL.LL
# L.LL.LL.LL
# L.LLLLL.LL
# ..L.L.....
# LLLLLLLLL#
# #.LLLLLL.L
# #.LLLLL.L#

# #.L#.##.L#
# #L#####.LL
# L.#.#..#..
# ##L#.##.##
# #.##.#L.##
# #.#####.#L
# ..#.#.....
# LLL####LL#
# #.L#####.L
# #.L####.L#

# #.L#.L#.L#
# #LLLLLL.LL
# L.L.L..#..
# ##LL.LL.L#
# L.LL.LL.L#
# #.LLLLL.LL
# ..L.L.....
# LLLLLLLLL#
# #.LLLLL#.L
# #.L#LL#.L#

# #.L#.L#.L#
# #LLLLLL.LL
# L.L.L..#..
# ##L#.#L.L#
# L.L#.#L.L#
# #.L####.LL
# ..#.#.....
# LLL###LLL#
# #.LLLLL#.L
# #.L#LL#.L#

# #.L#.L#.L#
# #LLLLLL.LL
# L.L.L..#..
# ##L#.#L.L#
# L.L#.LL.L#
# #.LLLL#.LL
# ..#.L.....
# LLL###LLL#
# #.LLLLL#.L
# #.L#LL#.L#

# Again, at this point, people stop shifting around and the seating area reaches equilibrium. Once this occurs, you count 26 occupied seats.

# Given the new visibility method and the rule change for occupied seats becoming empty, once equilibrium is reached, how many seats end up occupied?

sub transition2 {
  my (@seats) = @_;

  my $mult       = 1;
  my $changed    = 0;
  my @seats_copy = map { [@$_] } @seats;
  foreach my $i (0 .. $#seats) {
    foreach my $j (0 .. $#{ $seats[$i] }) {
      my @visible;
      foreach my $dir (@directions) {
        my $mult = 1;
        while (($i + ($dir->[0] * $mult)) >= 0
          and ($j + ($dir->[1] * $mult)) >= 0)
        {
          my $seat =
            $seats[ $i + ($dir->[0] * $mult) ]->[ $j + ($dir->[1] * $mult) ];
          last unless $seat;
          $mult += 1;
          push @visible, $seat;
          last if is_occupied($seat) or is_empty($seat);
        }
      }
      my $occupied_seats = grep { is_occupied($_) } @visible;
      if (is_empty($seats[$i]->[$j]) and $occupied_seats == 0) {
        $seats_copy[$i]->[$j] = '#';
        $changed = 1;
      }
      elsif (is_occupied($seats[$i]->[$j]) and $occupied_seats >= 5) {
        $seats_copy[$i]->[$j] = 'L';
        $changed = 1;
      }
    }
  }

  return ($changed, @seats_copy);
}

{
  my ($changed, @layout) = (0, @initial_seats);
  do {
    ($changed, @layout) = transition2(@layout);
  } while ($changed);

  my $occupied_seats = 0;
  foreach my $row (@layout) {
    foreach my $col (@$row) {
      $occupied_seats++ if is_occupied($col);
    }
  }
  say $occupied_seats;
}

__DATA__
LLLLLLLLLLLLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLL.LLLL.LLLL.LLLLLLLLLL.LLLLLL.LLLLL
LLLLL.LLLL.LLLLL.LLLLL.L.LLLLLL.LLLL.LLLLLL.LL....LLLLLLLL.LLLLLLLLL.LLLL.LLLLLLLLLL.LLLLLLL
LLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLL.LL.LLLLLL.L.
LLLLLLLLLL.LLL...LLLLL.LLLLLLLL.L.LLLLLLLLLLLLL.LLLL.LLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
LLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLL.LLLLLLLLL.LLLLL..LLLL.LLLL.LL...LLLLLLLLLL.LLLLLL.LLLLL
LL.LLLLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLLLLLLLLLLLLLLLLL.L.LLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLL
LLLLLLLLLL.L.LLLL.LLLLLLLLLLLLL.LLLLLL.LLLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
.L...L...LLLL..LLL......L.LLL.L.L.....L...L..L.L................L...L...L.LLLL.......LLL....
L..LLLLLLL.LLLLL.LLLLL.LLLLLLLLLLL.LLLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL..LLLLL.LLLL.LLLLLL.LLL.L
LLLLLLLLLLLLLLLLLLLLLL.LLLLLLLL.LLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLL.LLLLLL.LLL.L
LLL.LLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLLLLL.LLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLL.LLLLLL....LL
LLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLL.LL.LLLL.L.L.LLL
LLLLLL.LLL.L.LL.LL.LLL.LLLLLLLL.LLLL.LLLLL.LLL.LLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
LLLLLLLLLL.LLLLLLLL.LL.LL.LLLLL.LLLL.LLLLLLLLLLLLLLL..LLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLL
.LL.....LLLL.L..L..L..L...L.L..L..L.L....LL..L...LLL...LL.....L..LL....L...LLL..L...LLL..LLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLL.L.LLLL.LLLLLLLL..LLLLL.LLLLL.L.LLLL.LLLLLLL.LLLLLLLLLLLL.LLLLL
LLLLLLLLLLLL.LLL.LLL.LL.LLLLLLL.LLLL.LLLLLLLLL..LLLL.LLLLLLLLLLLL.LL.LLLLLLLL.LLLLLLLLLLLLLL
LLLLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLL.LLLLLLLL..LLLLLLLLLLLLLLL.LLLLL.LLLL.LLLLL.LLL.LL.LLLLL
LLLLLL.L..LLLLLL.LLLLLLLL.LLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLLL.LLLLL.LLLLLLLLLL.LLLL.LLLLLLL
LLLLLLLLLL.LLLLLLLLLLL..LLLLLLL.LLLL.LLLLLLLLL.LLLLL.LLLL..LLLLLLLL..LLLL.LLLLL.LLLLLLLLLLLL
LLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLL.LLLLLLLLLLLLLLL.L..LL.LL.LLLLLL.LLLL.LLLLLLLLLLLLLLLLLL
LLLLLLLLLL.LLLLLLLLLLLL.LLL.LLL.LLLLLLLLLLLLLL.LLLLL.LLLLL.LLLLLLLLL.L.LL.LLLLLLLLLLLLLLLLLL
L.LLLLLLLL.LLL.LL.LL.LLLLLLLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLLL.LLLLL.LLLLL
L..LL...L.L..L..L.L..L.L.L..L.LL.L....LL....LL.L...L..LL..LLL....L...LL...L..L.L....L....LLL
LLLLLLLLLL.LLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLL.LLLLLLLLL..LLL.L.LLLLLLLLLL.LLLLL
LLLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLL.LLLLLLLLL.LLLLL.LLLLLLLLLLL.LLLLLLLL.LLLLL.LLLL.LLLLL.L
LLLLLLLLLL.LLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLL.L.LLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLL
LLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLLL.L.LLLLL.LLLLL.L.LLLL.LLLLLL.LLLLLLLLLLLLLLLLLLL
.LL......LLL....LL.L....LLL.L.L....L.LLL....L....L..L...L.......LL.....L...L.L..L.LLLL......
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.L.LL.LLLLLLLLLLLLLLL.LLLLLLL.LL.LLLLLLL.L.LL.LL.LLL.LLLLLLLL
LLLLLLLLLL.LLLLL.L.LLL.LLLLLL.L.LLLL.LLLLLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL.LLLLLLLLLLLL.L..LLLLLLLLLLLLLLL..LLL.LL.LLLLLLLLL.LLLLL
LLLLLLLLLL.LLLLLLLLLLL.LLLLLLLL..LLL.LLLLLLLLL.LLLLL.LLLLLLLLLL.LLLL.LLLL.LLLLL.LLL.LL.L.LLL
LLLLLLLLLL.LLLLLLLLLL.LLLLLL.LL.LLLL.LLLLLL.LL.LLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLL
LLLLLLL.LL.LLLLL.LLLLL.L.LLLL.L.LLLL.LLLLLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
LLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLLL.LLLL.LLLL.LLLLL.LLLLL.LLLLLLLLL.LLL..LLLLL.LLLLLLLLLLLL
LLLLLLLL.LLLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLL.L.LLLLL.L.LLLL.LLLLL
L...L.L...L...L.LL.........LL..........LLL.....LLL.....L...L.L..LL......L.L..LL.LL...L.L....
.LLLLLLLLL.LLL.L.LLLL..L.LLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
LLLLLLLLLL.LL..LLLL.LL.L.LLLLLL.LLLL.LLLLLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLL..LLLLLLLLLLLL.LLLLL
LLLLLLL.LLLLLLLL.LLLLL.LLL.LLLL.LLLL.L.LLLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLL.LLL.LL..LLLL
LLLLLLLLLLLLLLLL.LL.LLLLLLLLLLL.LLLL.LLLLLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
LLL.LLL.LL.LLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLL..LLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLL
.L.LLLLLLL.LL.LL.LLL.L.LLLLLLLL..LLL..LL.LLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
.LLLLLLLLL..LLLLL.LLL..LLLLLLLL.LLL..LLLLLLLLLLLLLLLLLLLLL.LLLLLLLL..LLLL.LLLLLLLLLLLL..LLLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL.LLLLLLLLL.LLLLLLLLLL..LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
L...L..L.....LL.L...........L...........LL.....L.L.L..L.........LLLLL...L.L..LL..L..L......L
LLLLLLLLLLLLLLLL.LL.LL.LLLLLLLL.LLLL.LLLLL..LLLLLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLLLLLLLL
LLLLLLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL..LLLL.LL.LL.L.LLLLLLLLLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLL.LL.LLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLL.LLL.L
LLLLLLLLLL.L.LL.LLLLLLLLLLLLLLL.LLLL..LLLLLLLL.LLLLL.LLLLL.LLLLLLLLL..LLL.LLLLLLLLLLLL.LLL.L
L.LLLLLLLL.LLL.L.LLLLLLLLLLL.LL.LLLLLLLLLLLLLL.LLL.L.LLLLL.L.LLLLLLL.LLLLLLLLLL.LLLLLL.LLLLL
LLLLLLLL.L.LLLLL.LLLLL...LL.LLL.LLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLLLLLL.LLLLLLL.LLLL
LLLLL.LL..LLLLLLLLLLLLLLLLLLLLL.LLLL.LLLLLLLLL.LLLLL.L.LLLLLLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLL
LLLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLL.LLL.LLLLL.L.LLL.LLLLLLLLL.LLLL.LLLLL..L.LLL.LLLLL
LL...L.L..L.L....LL...LLLL..L...............L...........L.L.LL..L..L.LLL...LL......LLL..L..L
LLLLLLLLLL.LLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL..LLLLL.LLLLL
.LL.LLLLLLLLLLLLLLLLL.L.LLLLLLL.LLL.LLLLLLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLL...LLLL.LLLLLLLLLLLL
.LLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLL.LLLLLL.LLLL.LLL.LLLLLLLLLLLLL.LLLLLLLLLL.LLLLLLLL.LLLLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL.LLLLLLLLLLL.LLL..LLLL.LL.L.LLLLLLLLLLLLLLL.LLLLLLLLL.LL
LLLLLLLLLL.LLLLLL.LLLLLLLLL.LLLLLL.L.LL.LL.LLLLLLLLL.LLLLLLLLLLLLLLL.LLLL.LLLLLLLLLL.LLLLLLL
LLLLLLLLLL.LLLLL.LLLLLLLLLLL.LL.LLLLLLLLLLL.LL.LL.LLLLLLLL..LLLLLLLL.LLLL.LLLLL.LLLLLLLL.LLL
LL.LLLLLLL.LLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLL.LLL.LLLLLLLLLL.L.LLLLL
...L.L.....L.L..LL.LL..L.L...LLLL.......L.LLL...LL..L.L.L..L...L..L......LLL...L.L...L...L..
LL.LLLLLL..LLLLL.LLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLL..LLLLLLLLLLL.LLLLL
LLLLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLLLLL.LLLLLLLLLLL.LLLLL..LLLLLLLL.LL.L.LLLLLLLLLLLLLLLLLL
LLLLLLLLLLLL.LLLLLLLLL.LLLLLLLL.LL..LLLLLLLLLLLLLLLL.LLLLL.LL.LLLLLL.LLLL.LLL.L.LLLLLL.LLLLL
LLLLLLLLLL.LLLLLLLLLLL.LLLLLLLLLLLL..LLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLL.L.LLLLLLLLLL
L.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL.L..L.LLLLLLLLL.LL.LL.LLLLLLLLL.LLLLLLLLLL.LLLLL.LLLLLL.LLLLL
LLLLLLLLLL.LLLLL.LL.LL.LLLLLLL..LL.L.LLLLLL.LL.LLLLLLLLLLL..LLLLLLLL.LLLLLLLLLL.LLLLL..LLLLL
LLLLLLLLLLLLLLLL.LLLLL.LLLLLLL..LLLL.LLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLLLL.LLLLLLL
LLLL.LLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL.LL.LLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLL.L..LLL.LLLLL
L.LL.....LLLL.LL.LLL..L....LLL.L..LLL.....L.L.L...L.L.L..L.L......L.....LL..LL..L..LL.....L.
LLLLLLLLLL.LLLL.LLLLLL.LLLLLLLL.LLLL.LLLL.LLLLLLLLLL.LLLLL.LLLLL.L.L.LLLLLLLLLLLLLLLLL.LLLLL
LLLLL.LL...LLLLLLLLLLL.LL.LLLLL.L.LLLLLLLLLLLL.LLLLLLLLLL..LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
LLLLLLLLLL.LLLLLL.LLLL.LLLLLLLL.LLLL.LLLLLLLLLLLLLL..LLLLLLLLLL.LLLL.LLL.L.LLLL.LLLLLLLLLLLL
LLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLL
LLL.LLLLLL.LLLLLLLLLLLLL.LLLLLL.LLL..LL.LLLLLLLLLL.L.LLLLL.LLLLLL.L...LLL.LLLLLLLLLLLLLLLLLL
LLLLLLLLLLL.LLLLLLLLLL.LLLLLLL.L.LLL.LLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLL
LLLLLLLLLLLLLL...LLLLLL.LLLLLLLLLLLL.LLLLLLLLLL.LLLL.LLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLL
L.......LL.L...LL...L......LL.L.....LL..L...L..L.LL........L.L..L.L.LL...L..L...LL..L.LLLL..
LLLLLLLLLL.LLLLL.L.LLLLLLLLLLLL..LLL.LLLLLLLLL.LLLLL.LLLLL.LLLLL.LLL.LLLL.LLLLL.LLLLLLLL.LLL
LLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLL.LLLLLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLL
LLLLLLLLLL.LLL.LLLLLLL.LLLLLLLL.LL.L.LLLL.LLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL.LLLLLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLL
LLLL.LLLL.LLLLLL.LLL.L.LLLLLLL..LLLL.LLLLLLLLLLLLLLL.LLLLL.L.LLLLLLL.LLLLLLLLLL.LLLLLLLLLLLL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL.LLLLLL.LL.LLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.L
LLLLLL.LLL.LLLLL.L.LLL.LLLLLLLL.LLLL.LLLLLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.L.LLL
LLLLLLLLLL.LLLL.LLLLLLLLLLL.LLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLL.LLLLLL.LLLLL
LL.LLLLLLL.LLLLL..LLLL..LLLLLLL.LLLL.LLLLLLLLLLLLL.L.LLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLLLLLLLL
.L.L.L.LL..L.L.......L.....LLLL.L.....L.L.L...L.L..L.L..L..L.....LL.LL.L.......LL.L.L.....LL
LLLLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL.LLLLLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLLL.LLLLLLLLLLL
LLLLLLLLLL.LL.LL.LLLLL.LLLLLLLL.LLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLL..LLLLLLLLLLLLLLL.LLLLL
LLLLLLLLLLLL.LLLLLLLLLLLLLLLL.L.LLLL.LL.LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLLLLL.LLLLLLLLL
LLLLLLLLLLLL.LLL.LLLLL.LLLL.LLL.LLLL.LLLL.LLLL.LLLLL..L.LLLLL.LLLLLL.LLLL.LLLLL.LLLLLL.LLLLL
L.LLLLLLLL.LLLLL.LLLLL.LLLLLLLL.LLLL..LLLLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLL..LLLLL.LLLLL
LLLLLLLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLL.LLLLLLLL.LLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLL..LLL.L.LLLLL
LLLLLLLLLL.LLLLL.LLLLLLL.LLLLLL.LL.LLLLLLLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLL.LLLLL.LLL.LLLLLLLL
