unit module AOCUtils;

sub differences(@history) {
    @history.rotor(2 => -1).map(-> ($a, $b) { $b - $a }).Array
}

sub successive-differences(@history) is export {
    my @differences = (@history.Array,);

    repeat {
        @differences.push: differences(@differences.tail);
    } until so 0 == @differences.tail.all;

    return @differences;
}

class Point is export {
    has Int $.x;
    has Int $.y;

    method WHICH {
        self.Str
    }

    method Str {
        self.x ~ ", " ~ self.y
    }
}


class Point3D is export {
    has Int $.x;
    has Int $.y;
    has Int $.z;

    method WHICH {
        self.Str
    }

    method Str {
        self.x ~ ", " ~ self.y ~ ", " ~ self.z
    }
}