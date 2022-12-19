#!raku

class Point3D {
  has Int $.x;
  has Int $.y;
  has Int $.z; 

  method adjacents() {
    Point3D.new(x => self.x - 1, y => self.y,     z => self.z    ),
    Point3D.new(x => self.x + 1, y => self.y,     z => self.z    ),
    Point3D.new(x => self.x,     y => self.y - 1, z => self.z    ),
    Point3D.new(x => self.x,     y => self.y + 1, z => self.z    ),
    Point3D.new(x => self.x,     y => self.y,     z => self.z - 1),
    Point3D.new(x => self.x,     y => self.y,     z => self.z + 1)
  }

  method WHICH {
    self.Str
  }

  method Str {
    self.x ~ ", " ~ self.y ~ ", " ~ self.z
  }
}

my Set $droplets = 'input'.IO.lines.map(-> $line { 
  my ($x, $y, $z) = $line.split(',')>>.Int; 
  
  Point3D.new(x => $x, y => $y, z => $z) 
}).Set;


say $droplets.keys
      # generate a list of all of adjacent droplets
      .flatmap(-> $droplet { $droplet.adjacents })
      # filter out droplets are not contained in the droplets set
      .grep(-> $droplet { $droplets ∌ $droplet }).elems;

my Set $visited = Set.new;
# initialize the list of droplets to visit at -1 to represent starting at the outer edge of the cube (e.g. air)
my @to-visit = [Point3D.new(x => -1, y => -1, z => -1)];
while @to-visit {
  my $current-droplet = @to-visit.pop;
  for $current-droplet.adjacents -> $droplet {
    # skip this droplet if it is lava
    next if $droplets (cont) $droplet;

    # skip this droplet if we have already visited it
    next if $visited (cont) $droplet;

    # skip this droplet if it falls outside of the min/max boounds of possible droplets
    # noticed that my input never had an x,y,z > 20 and -1 represents the air surrounding the cube
    next unless -1 <= $droplet.x <= 20 
      and -1 <= $droplet.y <= 20
      and -1 <= $droplet.z <= 20;

    @to-visit.push: $droplet; 
  }

  $visited = $visited (|) Set.new($current-droplet);
}

say $droplets.keys
      # generate a list of all of adjacent droplets
      .flatmap(-> $droplet { $droplet.adjacents })
      # filter out droplets that we visited in our search of the outer layer of the cube
      # the only droplets in the visited set are accessible from the outside of the cube (e.g. not air pockets)
      .grep(-> $droplet { $visited (cont) $droplet }).elems;

