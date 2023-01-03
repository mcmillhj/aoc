#!raku

class Point {
  has Int $.x;
  has Int $.y;

  method manhatten-distance(Point $other --> Int) {
    abs($!x - $other.x) + abs($!y - $other.y);
  }

  method tuning-frequency() {
    4_000_000 * self.x + self.y;
  }

  method Str { $.x ~ ',' ~ $.y }
  method WHICH { self.Str }
}

multi sub infix:<==>(Point $a, Point $b) {
  $a.x == $b.x and $a.y == $b.y
}

class Sensor {
  has Point $.origin;
  has Point $.beacon;
  has Int $.range = $!origin.manhatten-distance($!beacon);

  method range-at-y(Int $y --> Range) {
    my $delta-x = self.range - abs(self.origin.y - $y);
    return 0..0 if $delta-x < 0;
    return self.origin.x - $delta-x .. self.origin.x + $delta-x;
  }

  method Str { "Sensor at $!origin sees beacon at $!beacon, distance $!range." }
  method gist { self.Str }
}

sub scan-for-empty-positions(Sensor @sensors, Int $target-y) {
  my $empty-positions = SetHash.new;

  for @sensors -> $sensor {
    for $sensor.range-at-y($target-y) -> $x {
      next if $x == $sensor.beacon.x and $target-y == $sensor.beacon.y;

      $empty-positions.set: Point.new(x => $x, y => $target-y);
    }
  }

  $empty-positions.elems;
}

sub merge(@ranges) {
  gather {
    # sort ranges by starting element
    # only adjacent ranges will overlap
    my Range @sorted-ranges = @ranges.sort(*.min);
    my ($min, $max) = @sorted-ranges[0].minmax;

    for @sorted-ranges.tail(* - 1) -> $range {
      if $range.min <= $max + 1 {
        # this range overlaps the previous range, merge them
        $max max= $range.max;
      }
      else {
        # this range does overlap the previous range
        # emit the previous range and reset min/max to this range
        take $min .. $max;
        ($min, $max) = $range.minmax;
      }
    }

    # emit the final range
    take $min .. $max;
  }
}

sub truncate(@ranges, Int $min, Int $max) {
  gather {
    for @ranges -> $range {
      my $new-min = max($range.min, $min);
      my $new-max = min($range.max, $max);

      next unless $new-min <= $new-max;

      take $new-min .. $new-max;
    }
  }
}

sub possible-beacon(Sensor @sensors, Int $min, Int $max) {
  for $min .. $max -> $y {
    my Range @ranges = @sensors.map(*.range-at-y($y)).&merge.&truncate($min, $max);

    # if the sensors combined visibility at $y is less than the number of possible elements
    # there might be a beacon
    if @ranges».elems.sum < $max - $min + 1 {
      # if there is only a single range then the beacon has to be 
      # at one end 
      if @ranges == 1 {
        return @ranges[0] ~~ $min 
          ?? Point.new(x => $min, y => $y) 
          !! Point.new(x => $max, y => $y);
      }
      # otherwise, the beacon is between the two ranges 
      else {
        return Point.new(x => @ranges[0].max + 1, y => $y)
      }
    }
  }
}

sub MAIN(IO() $inputfile where *.f = 'input') {
  my Sensor @sensors;
  for $inputfile.IO.lines -> $line {
    if $line ~~ m/'Sensor at x=' ('-'?\d+) ', y=' ('-'?\d+) ': closest beacon is at x=' ('-'?\d+) ', y=' ('-'?\d+)/ {
      my ($sensor-x, $sensor-y, $beacon-x, $beacon-y) = ($0.Int, $1.Int, $2.Int, $3.Int)>>.Int;

      @sensors.push: Sensor.new(
        origin => Point.new(x => $sensor-x, y => $sensor-y),
        beacon => Point.new(x => $beacon-x, y => $beacon-y)
      );
    }
  }

  # part 1 [pretty slow]
  say 'Part 1: ', scan-for-empty-positions(@sensors, 2_000_000);

  # part 2 [very slow :(]
  say 'Part 2: ', possible-beacon(@sensors, 0, 4_000_000).tuning-frequency;
}