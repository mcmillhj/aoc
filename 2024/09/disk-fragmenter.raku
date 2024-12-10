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
# dd @disk-map;
# die;


sub find-first-free-space {
    @disk-map.first(-> $file { $file[0] == -1 }, :k) // 2**32;
}

sub find-last-file-block {
    @disk-map.first(-> $file { $file[0] != -1 }, :k, :end) // -1;
}

my @to-process-files = @disk-map.grep(-> $file { $file[0] != -1}).reverse();
# dd @to-process-files;
while (@to-process-files) {
    say @to-process-files.elems ~ " left...";
    my @file := @to-process-files.shift();
    my @free-space-start-indexes = @disk-map.grep(-> $file { $file[0] == -1}, :k);
    # my @file-start-indexes = @disk-map.grep(-> $file { $file[0] != -1}, :k);

    # dd @file, @file[0];
    # say "FILE[0] = " ~ @file.WHAT;
    # say "FREE SPACE INDEXES = " ~  @free-space-start-indexes;
    # dd @file-start-indexes;

    my $file-start-index = @disk-map.first(-> $f { $f[0] == @file[0] }, :k, :end);
    # dd $file-start-index;
    # die;
    # for @file-start-indexes.reverse -> $file-start-index {
    # my @file = |@disk-map[$file-start-index];
    for @free-space-start-indexes -> $free-space-start-index {
        my @free-space = |@disk-map[$free-space-start-index];

        next unless $free-space-start-index < $file-start-index;
        next unless @free-space.elems >= @file.elems;

        if (@free-space.elems == @file.elems) {
            # say "EQUAL FREE SPACE AND FILE BLOCKS...";
            # dd [@free-space, @file, $free-space-start-index, $file-start-index];
            @disk-map.splice($free-space-start-index, 1, [@disk-map.splice($file-start-index, 1, [[-1 xx @file.elems],])]);
            # dd @disk-map;
            # say '-' x 80;
            last;
        } 
        elsif (@free-space.elems > @file.elems) {
            # say "MORE FREE SPACE THAN FILE BLOCKS...";
            # dd [@free-space, @file, $free-space-start-index, $file-start-index];
            @disk-map[$free-space-start-index].splice(0, @file.elems);
            @disk-map.splice($free-space-start-index, 0, [@disk-map.splice($file-start-index, 1, [[-1 xx @file.elems],])]);
            # dd @disk-map;
            # say '-' x 80;
            last;
        }
    }
    # }
}

# dd @disk-map;

# die;
# my $free-space-start-index = find-first-free-space();
# my $file-end-index = find-last-file-block();
# while ($free-space-start-index < $file-end-index) {
#     my @free-space = |@disk-map[$free-space-start-index];
#     my @file = |@disk-map[$file-end-index];

#     # say "FREE SPACE = " ~ @free-space;
#     # say "FILE = " ~ @file;

#     # fill available free space with file blocks
#     if @free-space.elems < @file.elems {
#         @disk-map.splice($free-space-start-index, 1, [[@disk-map[$file-end-index].splice(0, @free-space.elems)],])
#     } 
#     elsif (@free-space.elems == @file.elems) {
#         # say "EQUAL FREE SPACE AND FILE BLOCKS...";
#         # dd [@free-space, @file];
#         # @disk-map
#         @disk-map.splice($free-space-start-index, 1, [@disk-map.splice($file-end-index, 1)]);
#     } 
#     else {
#         # say "MORE FREE SPACE THAN FILE BLOCKS...";
#         # dd [@free-space, @file];
#         @disk-map[$free-space-start-index].splice(0, @file.elems);
#         @disk-map.splice($free-space-start-index, 0, [@disk-map.splice($file-end-index, 1)]);
#     }

#     # dd @disk-map;
#     # die;
#     # die if $x++ == 1;

#     # recalculate pointers
#     $free-space-start-index = find-first-free-space();
#     $file-end-index = find-last-file-block();

#     # dd $free-space-start-index;
#     # dd $file-end-index;
#     # dd @disk-map;
#     # say '-' x 80;

#     # die;
# }

my $c = 0;
my $file-idx = 0;
for @disk-map -> @file {
    for @file -> $block {
        # next if $block == -1;
        if $block == -1 {
            $file-idx++;
            next;
        }

        # dd [$file-idx, $block];
        say "$file-idx x $block = " ~ ($file-idx * $block);
        $c += $file-idx * $block;

        $file-idx++;
    }
}

say $c;