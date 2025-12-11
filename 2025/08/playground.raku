#!raku

class Point3D { 
    has Int $.x is required;
    has Int $.y is required;
    has Int $.z is required;
    
    method Str { "(" ~ self.x ~ "," ~ self.y ~ "," ~ self.z ~ ")" }
    method WHICH { self.Str }
}

multi sub infix:<∆>(Point3D $a, Point3D $b) {
  (($b.x - $a.x) ** 2 + ($b.y - $a.y) ** 2 + ($b.z - $a.z) ** 2).sqrt
}

multi sub infix:<==>(Point3D $a, Point3D $b) {
  $a.x == $b.x and $a.y == $b.y and $a.z == $b.z
}

class Circuit {
    has Int $.id;
    has Point3D @.junction-boxes;

    multi method add(Point3D $junction-box) {
        @.junction-boxes.push: $junction-box;
    }

    multi method add(Circuit $circuit) {
        for $circuit.junction-boxes -> $junction-box {
            self.add($junction-box);
        }
    }

    method contains(Point3D $junction-box) {
        ? @.junction-boxes.first: * == $junction-box;
    }

    method Str {
        $.id ~ ": " ~ @.junction-boxes.sort({ $^a cmp $^b }).join(' -> ');
    }

    method WHICH { 
        $.id.Str; 
    }
}

my Circuit %circuits{Int};
my Point3D @junction-boxes; 
# collect all junction boxes and initialize a circuit for each (a junction box is implicitly part of its own circuit)
my Int $circuit-id = 0;
for $*IN.lines>>.split(',')>>.Int -> ($x, $y, $z) {
    my $junction-box = Point3D.new(x => $x, y => $y, z => $z);
    @junction-boxes.push: $junction-box;

    my $circuit-name = $circuit-id++;
    %circuits{$circuit-name} = Circuit.new(id => $circuit-name, junction-boxes => [$junction-box]);
}

# order pairs of junction boxes by distance
my @sorted-junction-box-pairs = @junction-boxes.combinations(2).sort(-> ($a, $b) { $a ∆ $b });

# iterate over the closest pairs and combine their circuit (if not already combined)
for @sorted-junction-box-pairs.kv -> $processed-junction-boxes-count, ($box1, $box2) {
    # find the circuit that each junction box is a part of
    my Circuit $box1-circuit = %circuits.values.first(-> $circuit { $circuit.contains($box1) });
    my Circuit $box2-circuit = %circuits.values.first(-> $circuit { $circuit.contains($box2) });
    
    # if they are not a part of the same circuit, combine them and delete the other circuit
    if $box1-circuit ne $box2-circuit {
        $box1-circuit.add($box2-circuit);
        %circuits{$box2-circuit.id}:delete;
    }

    if $processed-junction-boxes-count == 999 {
        say [*] %circuits\
            .values\
            .sort({ $^b.junction-boxes.elems <=> $^a.junction-boxes.elems })[0..2]\
            .map(-> $circuit { $circuit.junction-boxes.elems });
    }
    
    if %circuits.elems == 1 {
        say $box1.x * $box2.x;
        last;
    }
}