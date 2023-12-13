#!raku 

use experimental :cached;

my @rows = $*IN.lines>>.split(' ').map(-> ($s, $groups) {
    [$s, $groups.split(',')>>.Int]
});

constant $BROKEN_SPRING = '#';
constant $OPERATIONAL_SPRING = '.';
constant $UNKNOWN_SPRING = '?';

sub unfold(Str $row, @broken-spring-groups, Int $folds = 1) {
    return join('?', $row xx $folds), (@broken-spring-groups xx $folds).flat;
}

sub count-arrangements(Str $row, @broken-spring-groups) is cached {
    # only successful paths will exhaust both the list of springs and the broken spring groupings
    if $row.chars == 0 {
        return @broken-spring-groups.elems == 0 ?? 1 !! 0;
    }

    # ignore operational springs
    if $row.starts-with($OPERATIONAL_SPRING) {
        return count-arrangements($row.substr(1), @broken-spring-groups);
    }

    # when we encounter a spring in an unknown state
    # count the ways we can arrange the current broken spring groups assuming this 
    # spring is either operation ('.') or broken '#''
    if $row.starts-with($UNKNOWN_SPRING) {
        return count-arrangements("." ~ $row.substr(1), @broken-spring-groups) 
            + count-arrangements("#" ~ $row.substr(1), @broken-spring-groups);
    }

    if $row.starts-with($BROKEN_SPRING) {
        # this cannot be a successful match if 
        # 1. we run out of groups to match against
        # 2. there are not enough springs left to satisfy the current group size
        # 3. the characters in the range (0, current group size) contains an operational spring (cannot place broken springs on top of operational springs)
        return 0 if @broken-spring-groups.elems == 0
            or $row.chars < @broken-spring-groups.head
            or $row.substr(0, @broken-spring-groups.head).contains($OPERATIONAL_SPRING);


        # there is only one group left to match
        return count-arrangements(
            $row.substr(@broken-spring-groups.head), 
            @broken-spring-groups.tail(*-1)
        ) if @broken-spring-groups.elems == 1;

        # there are > 1 groups left to match
        # this cannot be a successful match if
        # 1. there will not be enough springs left to match against the next group (the one after the current group)
        # 2. the next spring AFTER handling the current group is broken (broken spring groups have to be separated by operational springs)
        return 0
            if $row.chars < @broken-spring-groups.head + 1 
                or $row.substr(@broken-spring-groups.head, 1) eq $BROKEN_SPRING;


        return count-arrangements(
            $row.substr(@broken-spring-groups.head + 1), 
            @broken-spring-groups.tail(*-1)
        );
    }
}


say "Part 1: " ~ 
    [+] @rows.map: -> [$spring-row, @groups] { count-arrangements($spring-row, @groups) };

say "Part 2: " ~ 
    [+] @rows.map: -> [$spring-row, @groups] { count-arrangements(|unfold($spring-row, @groups, 5)) };
