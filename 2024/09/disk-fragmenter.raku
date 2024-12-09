#!raku

class File {
    has Int $.id is rw;
    has Int $.blocks is rw;
}

class FileSystem {
    has File $.files is rw;
}



class FreeSpace {

}

my @disk-map = do {
    my $file-id = 0;

    my @t;
    for $*IN.slurp.comb(/\d/)>>.Int.kv -> $i, $file-block-size { 
        # dd [$i, $file-block-size];
        # dd [ $file-id];
        # say '-' x 80;
        my $is-empty-space = $i % 2 == 1;
        
        @t.push: [($is-empty-space ?? -1 !! $file-id) xx $file-block-size]
            unless $file-block-size == 0;
        $file-id++ unless $is-empty-space;
    }

    @t;
};
dd @disk-map;
# die;


sub find-first-free-space {
    @disk-map.first(-> $file { $file[0] == -1 }, :k) // 2**32;
}

sub find-last-file-block {
    @disk-map.first(-> $file { $file[0] != -1 }, :k, :end) // -1;
}

my $free-space-start-index = find-first-free-space();
my $file-end-index = find-last-file-block();
while ($free-space-start-index < $file-end-index) {
    my @free-space = |@disk-map[$free-space-start-index];
    my @file = |@disk-map[$file-end-index];

    # say "FREE SPACE = " ~ @free-space;
    # say "FILE = " ~ @file;

    # fill available free space with file blocks
    if @free-space.elems < @file.elems {
        @disk-map.splice($free-space-start-index, 1, [[@disk-map[$file-end-index].splice(0, @free-space.elems)],])
    } 
    elsif (@free-space.elems == @file.elems) {
        # say "EQUAL FREE SPACE AND FILE BLOCKS...";
        # dd [@free-space, @file];
        # @disk-map
        @disk-map.splice($free-space-start-index, 1, [@disk-map.splice($file-end-index, 1)]);
    } 
    else {
        # say "MORE FREE SPACE THAN FILE BLOCKS...";
        # dd [@free-space, @file];
        @disk-map[$free-space-start-index].splice(0, @file.elems);
        @disk-map.splice($free-space-start-index, 0, [@disk-map.splice($file-end-index, 1)]);
    }

    # dd @disk-map;
    # die;
    # die if $x++ == 1;

    # recalculate pointers
    $free-space-start-index = find-first-free-space();
    $file-end-index = find-last-file-block();

    # dd $free-space-start-index;
    # dd $file-end-index;
    # dd @disk-map;
    # say '-' x 80;

    # die;
}

my $c = 0;
my $file-idx = 0;
for @disk-map -> @file {
    for @file -> $block {
        next if $block == -1;
        $c += $file-idx * $block;

        $file-idx++;
    }
}

say $c;