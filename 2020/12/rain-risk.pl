#!perl 

use strict;
use warnings;

use feature qw(say);

chomp(my @directions = readline(\*DATA));

# --- Day 12: Rain Risk ---

# Your ferry made decent progress toward the island, but the storm came in faster than anyone expected. The ferry needs to take evasive actions!

# Unfortunately, the ship's navigation computer seems to be malfunctioning; rather than giving a route directly to safety, it produced extremely circuitous instructions. When the captain uses the PA system to ask if anyone can help, you quickly volunteer.

# The navigation instructions (your puzzle input) consists of a sequence of single-character actions paired with integer input values. After staring at them for a few minutes, you work out what they probably mean:

#     Action N means to move north by the given value.
#     Action S means to move south by the given value.
#     Action E means to move east by the given value.
#     Action W means to move west by the given value.
#     Action L means to turn left the given number of degrees.
#     Action R means to turn right the given number of degrees.
#     Action F means to move forward by the given value in the direction the ship is currently facing.

# The ship starts by facing east. Only the L and R actions change the direction the ship is facing. (That is, if the ship is facing east and the next instruction is N10, the ship would move north 10 units, but would still move east if the following action were F.)

# For example:

# F10
# N3
# F7
# R90
# F11

# These instructions would be handled as follows:

#     F10 would move the ship 10 units east (because the ship starts by facing east) to east 10, north 0.
#     N3 would move the ship 3 units north to east 10, north 3.
#     F7 would move the ship another 7 units east (because the ship is still facing east) to east 17, north 3.
#     R90 would cause the ship to turn right by 90 degrees and face south; it remains at east 17, north 3.
#     F11 would move the ship 11 units south to east 17, south 8.

# At the end of these instructions, the ship's Manhattan distance (sum of the absolute values of its east/west position and its north/south position) from its starting position is 17 + 8 = 25.

# Figure out where the navigation instructions lead. What is the Manhattan distance between that location and the ship's starting position?

# approximation of pi
my $PI = 3.14159265358979;

sub to_radians {
  my ($degrees) = @_;

  return $degrees * $PI / 180;
}

{
  my $x     = 0;
  my $y     = 0;
  my $angle = 0;

  my %commands = (
    "N" => sub { $y += shift },
    "S" => sub { $y -= shift },
    "E" => sub { $x += shift },
    "W" => sub { $x -= shift },
    "F" => sub {
      my ($amount) = @_;

      $x += $amount * cos($angle);
      $y += $amount * sin($angle);
    },
    "L" => sub { $angle += to_radians(shift) },
    "R" => sub { $angle -= to_radians(shift) },
  );

  foreach my $direction (@directions) {
    my ($command, $amount) = $direction =~ /([NSEWFLR])(\d+)/;
    $commands{$command}->($amount);
  }

  say int(abs($x) + abs($y) + 0.5);
}

# --- Part Two ---

# Before you can give the destination to the captain, you realize that the actual action meanings were printed on the back of the instructions the whole time.

# Almost all of the actions indicate how to move a waypoint which is relative to the ship's position:

#     Action N means to move the waypoint north by the given value.
#     Action S means to move the waypoint south by the given value.
#     Action E means to move the waypoint east by the given value.
#     Action W means to move the waypoint west by the given value.
#     Action L means to rotate the waypoint around the ship left (counter-clockwise) the given number of degrees.
#     Action R means to rotate the waypoint around the ship right (clockwise) the given number of degrees.
#     Action F means to move forward to the waypoint a number of times equal to the given value.

# The waypoint starts 10 units east and 1 unit north relative to the ship. The waypoint is relative to the ship; that is, if the ship moves, the waypoint moves with it.

# For example, using the same instructions as above:

#     F10 moves the ship to the waypoint 10 times (a total of 100 units east and 10 units north), leaving the ship at east 100, north 10. The waypoint stays 10 units east and 1 unit north of the ship.
#     N3 moves the waypoint 3 units north to 10 units east and 4 units north of the ship. The ship remains at east 100, north 10.
#     F7 moves the ship to the waypoint 7 times (a total of 70 units east and 28 units north), leaving the ship at east 170, north 38. The waypoint stays 10 units east and 4 units north of the ship.
#     R90 rotates the waypoint around the ship clockwise 90 degrees, moving it to 4 units east and 10 units south of the ship. The ship remains at east 170, north 38.
#     F11 moves the ship to the waypoint 11 times (a total of 44 units east and 110 units south), leaving the ship at east 214, south 72. The waypoint stays 4 units east and 10 units south of the ship.

# After these operations, the ship's Manhattan distance from its starting position is 214 + 72 = 286.

# Figure out where the navigation instructions actually lead. What is the Manhattan distance between that location and the ship's starting position?

{
  my $x          = 0;
  my $y          = 0;
  my $waypoint_x = 10;
  my $waypoint_y = 1;

  my %commands = (
    "N" => sub { $waypoint_y += shift },
    "S" => sub { $waypoint_y -= shift },
    "E" => sub { $waypoint_x += shift },
    "W" => sub { $waypoint_x -= shift },
    "F" => sub {
      my ($amount) = @_;

      $x += $amount * $waypoint_x;
      $y += $amount * $waypoint_y;
    },
    "L" => sub {
      my ($amount) = @_;

      my $sin = sin(to_radians($amount));
      my $cos = cos(to_radians($amount));

      my $new_waypoint_x = $cos * $waypoint_x - $sin * $waypoint_y;
      my $new_waypoint_y = $sin * $waypoint_x + $cos * $waypoint_y;

      $waypoint_x = $new_waypoint_x;
      $waypoint_y = $new_waypoint_y;
    },
    "R" => sub {
      my ($amount) = @_;

      my $sin = sin(to_radians($amount));
      my $cos = cos(to_radians($amount));

      my $new_waypoint_x = $cos * $waypoint_x + $sin * $waypoint_y;
      my $new_waypoint_y = -1 * $sin * $waypoint_x + $cos * $waypoint_y;

      $waypoint_x = $new_waypoint_x;
      $waypoint_y = $new_waypoint_y;
    },
  );

  foreach my $direction (@directions) {
    my ($command, $amount) = $direction =~ /([NSEWFLR])(\d+)/;
    $commands{$command}->($amount);
  }

  say int(abs($x) + abs($y) + 0.5);
}

__DATA__
W2
F23
S1
W3
L180
W3
R90
N4
F17
S4
W4
R90
W4
E1
N4
F5
N2
R90
F43
N5
L90
F12
S4
W1
S3
W2
N4
F76
S1
W4
W2
F20
N4
F81
W4
N3
R180
W2
N4
W3
F16
N4
L180
F1
W3
F34
W3
S3
F92
L90
S2
L90
E5
N2
F85
W3
R90
W2
F88
N2
L90
W1
N4
L90
E5
N3
L90
F8
E1
L90
N3
F3
F61
S5
R90
W2
F84
W1
L90
E1
S3
W5
F89
E3
F67
E2
E5
F29
N5
W4
F53
N2
E5
F73
W4
L90
S2
R180
N3
R90
F27
N2
F41
L270
W5
F3
N5
F81
R90
N2
W5
N2
R90
S1
R180
S3
L90
E2
F38
S1
E3
S5
F44
N1
F26
E1
S2
F25
E1
S2
F33
S4
R90
N2
W2
F9
R90
F64
W1
S3
E5
R180
N2
L90
S4
E4
L90
S2
F50
S3
R90
F8
E2
N1
R90
S5
S1
F100
N3
F97
R180
S3
L180
F45
W5
S1
E5
E3
F26
N4
R90
N4
F50
W5
R90
F58
S4
W3
E1
N3
R90
S4
E2
F26
N4
L90
F60
W4
N1
F10
E5
L180
N4
E1
F15
E3
L270
F23
R90
F61
R90
F25
L90
W2
S3
R180
F44
W5
E1
R90
S2
R270
W2
S1
F13
E5
N2
R270
F68
F99
W1
F31
N5
F89
E5
N4
W5
N2
F59
E3
L180
E3
L90
L180
S5
F27
E1
S3
R180
N5
E4
L180
N2
E3
W1
L180
F23
N4
E1
F87
N1
E3
F45
W5
F17
L90
N1
L90
W3
S2
F62
R180
F8
R90
F19
W1
S2
S5
W4
F40
F52
S3
F6
R90
S5
W3
S5
E3
W3
S1
F11
S2
E4
F3
R90
L270
E1
S1
W4
L180
W2
S4
E2
N3
W3
S2
W4
L90
F24
W3
F58
E5
R90
F73
E4
F92
R90
F62
W4
R90
W2
S3
W2
F75
N4
R180
W5
S5
W1
S2
L90
S1
E5
L180
N3
W3
F77
E2
S5
L90
E5
S4
L90
S4
F32
L90
W3
F92
W3
S4
W1
R90
F6
R180
E4
W2
R90
W4
S2
W5
S2
F79
R90
S4
F50
S4
W3
F87
W5
R90
S2
F23
E1
N1
R90
F24
L90
F29
N1
R90
E5
N5
F79
W3
L90
S4
E5
S1
F36
W2
R90
F36
R270
F82
E4
F82
S3
F94
N2
L180
S2
E1
N3
F54
S3
F11
E2
R90
W2
F39
R90
S2
W2
R90
E4
N2
E5
F59
W3
R90
W3
F78
N4
F97
S4
W1
F48
N2
E2
R180
F6
R90
W4
R90
E5
F19
N2
R180
F50
W3
N5
R90
N1
W4
F68
R90
N2
L90
F83
E3
N4
W2
F48
W3
E3
L180
F73
R90
F81
W1
R90
F25
S3
F23
L270
S4
F76
W3
F73
N2
E5
L90
N3
W3
R270
F37
S5
R90
F46
S4
E4
F92
L90
N1
L180
W3
S5
F27
N1
L180
F91
W4
N3
F11
L180
N1
E3
L90
S2
R90
S2
E3
F55
S4
E2
S2
F3
E3
F58
W4
N4
E5
F2
N1
W3
F86
E5
F60
W3
F9
S4
R180
F44
E4
N1
F74
L270
E4
L270
F52
R180
F70
L180
E1
F68
R90
E5
W4
R90
E4
F27
S2
L90
W5
N5
R90
E2
N5
F15
R180
F72
S5
L90
F31
R90
E4
R270
S3
W3
R270
N1
S3
R90
F80
R90
E2
N5
W2
L90
F40
N1
F14
L90
W2
F9
W4
R90
F88
R180
N1
E5
F96
N1
F4
R90
F56
F14
L90
F8
R180
S2
F75
L90
E5
R90
F81
N1
W3
F46
R270
S2
F15
W3
R180
F27
W3
F53
R90
E5
L90
S3
W1
F62
S5
W2
S5
R90
F82
W2
N4
L270
E1
N5
E2
F52
N1
E2
S2
R180
N1
L90
W2
L90
F78
L90
W1
N4
F81
E1
N4
W2
F86
W1
F30
W5
N4
E3
F42
N2
F5
R90
F60
L90
E5
S4
E5
S3
F70
S3
R90
W5
R90
W2
N3
L180
E3
S2
E3
F82
E2
F5
E4
E1
S1
R180
W4
F1
R180
N4
E1
S3
E3
F59
W3
F73
L90
F74
R90
E1
F54
W3
F54
L90
S4
F100
F56
L90
F26
L180
F50
W3
S2
E3
F87
N2
W5
F50
S2
W5
S1
F46
R90
F89
L90
N4
F53
W1
F56
E4
S5
F68
L90
F22
R90
F73
S5
S5
L90
E4
S2
R270
E3
L90
F20
L90
F84
S1
F29
W2
S4
L90
W4
N1
F65
E5
L90
S3
F38
L90
L90
N5
F50
S1
F16
R90
F12
E2
N3
F49
R90
F4
N1
R90
F80
R180
W2
L90
S5
E1
F93
R90
F32
L180
F44
L90
S4
F42
N2
R90
S1
F56
L180
E2
F90
N1
F3
L90
E1
F91
L90
W4
L90
F10
S3
W5
S3
F87
