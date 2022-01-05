#!perl6

class Point {
  has Int $.x;
  has Int $.y;

  method length {
    self.y - self.x + 1;
  }

  method range {
    return self.x .. self.y;
  }

  method min-x(Point $other) {
    min(self.x, $other.x)
  }

  method max-x(Point $other) {
    max(self.x, $other.x)
  }

  method min-y(Point $other) {
    min(self.y, $other.y)
  }

  method max-y(Point $other) {
    max(self.y, $other.y)
  }  

  method Str {
    "(" ~ self.x ~ ", " ~ self.y ~ ")"; 
  }
}

class Cuboid {
  has Point $.x;
  has Point $.y;
  has Point $.z; 

  method volume {
    self.x.length * self.y.length * self.z.length
  }

  method bounds(Cuboid $other) {
    self.x.max-x($other.x), 
    self.x.min-y($other.x), 
    self.y.max-x($other.y), 
    self.y.min-y($other.y),
    self.z.max-x($other.z), 
    self.z.min-y($other.z),
  }

  method overlaps(Cuboid $other --> Bool) {
    my ($min-x, $max-x, $min-y, $max-y, $min-z, $max-z) = self.bounds($other);

    $max-x - $min-x >= 0 and $max-y - $min-y >= 0 and $max-z - $min-z >= 0;
  }

  method new-from-bounds(Cuboid $other --> Cuboid) {
    my ($min-x, $max-x, $min-y, $max-y, $min-z, $max-z) = self.bounds($other);

    Cuboid.new(
      x => Point.new(x => $min-x, y => $max-x), 
      y => Point.new(x => $min-y, y => $max-y), 
      z => Point.new(x => $min-z, y => $max-z)
    );
  }

  method Str {
    self.x ~ ", " ~ self.y ~ ", " ~ self.z
  }
}

my @commands;
for 'input'.IO.lines -> $instruction {
  $instruction ~~ /(on|off) ' x=' ('-'?\d+) '..' ('-'?\d+) ',y=' ('-'?\d+) '..' ('-'?\d+) ',z=' ('-'?\d+) '..' ('-'?\d+)/;

  @commands.push: [
    ~$0,
    Cuboid.new(
      x => Point.new(x => $1.Int, y => $2.Int), 
      y => Point.new(x => $3.Int, y => $4.Int), 
      z => Point.new(x => $5.Int, y => $6.Int),
    ),
  ];
}

# part 1
# my %state; 
# for @commands -> [$state, $cuboid] {
#   next unless $cuboid.x.x >= -50 and $cuboid.x.y <= 50
#     and $cuboid.y.x >= -50 and $cuboid.y.y <= 50
#     and $cuboid.z.x >= -50 and $cuboid.z.y <= 50;

#   for $cuboid.x.range -> $x {
#     for $cuboid.y.range -> $y {
#       for $cuboid.z.range -> $z {
#         %state{$x => $y => $z} = $state eq 'on';
#       }
#     }
#   }
# }

# say %state.values.grep(* == True).elems;

# part 2
sub overlapping-volume(Cuboid $cuboid, Cuboid @cuboids) {
  my $sum = 0;
  for @cuboids.kv -> $i, $c {
    # if this cuboid does not overlap, there is nothing to subtract
    next unless $cuboid.overlaps($c);

    # create a new smaller cuboid using the intersection between the two cuboids
    my $bounded-cuboid = $cuboid.new-from-bounds($c);

    # only consider cuboids that occur _after_ this intersection for future intersections
    my Cuboid @sub-cuboids = @cuboids[$i + 1 .. *];
    $sum += $bounded-cuboid.volume - overlapping-volume($bounded-cuboid, @sub-cuboids);
  }

  return $sum;
}

my $lit-cubes = 0;
my Cuboid @cuboids;
# start from a state where all cuboids are 'on'
# when an instruction would turn a set of cubes 'on' compute it's volume (total # of cubes within this cuboid)
# but subtract the volume of the intersections with other cuboids
for @commands.reverse() -> [$state, $cuboid] {
  if $state eq 'on' {
    $lit-cubes += $cuboid.volume - overlapping-volume($cuboid, @cuboids);
  }

  @cuboids.push: $cuboid;
}

say $lit-cubes;