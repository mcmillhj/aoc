#!raku

sub to-operator(Str $s) {
    do given $s {
        when "+" { &infix:<+> }
        when "*" { &infix:<*> }
    }
}

sub infix:<ZLONGEST>(**@lists --> Seq:D) is assoc<list> {
    sub pad(@list, $max-length) { @list.elems < $max-length ?? @list.append: -1 xx $max-length - @list.elems !! @list; }
    sub unpad(@list, Int $pad = -1) { @list.grep: * != $pad }


    my $max-length = @lists>>.elems.max;
    ([Z] @lists.map(-> @list { pad(@list, $max-length) })).map(-> @list { unpad(@list) });
}

sub solve(@operands, @operators) {
    [+] @operands.kv.map(-> $index, @operand-group { 
        @operand-group.reduce(@operators[$index]); 
    });
}

sub to-digits($n) {
    $n.comb>>.Int.Array;
}

sub from-digits(@digits) {
    @digits.join('').Int
}

sub to-columns(@rows) {
    # iterate through each row and collect the digits in their corresponding columns
    my @columns; 
    for @rows -> $row {
        for $row.comb.kv -> $i, $column {
            @columns[$i].push: $column;
        }
    }

    # use join->split->join to eliminate "" and create the correct subgroups for each operation
    @columns.map(-> @column { @column.join('').subst(/\s+/, '') }).join("|").split('||')>>.split('|')>>.Int
}

my @lines = $*IN.lines;
my @operands = @lines.head(* - 1).map(-> $line { $line.comb(/\d+/)>>.Int.Array });
my @operators = @lines.tail.map(-> $line { $line.comb(/<[+ *]>/).map(-> $operator-type { to-operator($operator-type) }) }).flat;

say solve(([Z] @operands), @operators);
say solve(to-columns(@lines.head(* - 1)), @operators);
