#!raku

use experimental :cached;

my %device-map;
for $*IN.lines>>.split(':')>>.trim -> ($device-name, $output-devices-string) {
    %device-map{$device-name} := $output-devices-string.split(' ').Array;
}

sub count-device-paths(Str $start, Str $goal, Bool $seen-dac = True, Bool $seen-fft = True) is cached {
    my $path-count = 0;

    if $start eq $goal {
        if $seen-dac and $seen-fft {
            $path-count++;
        }

        return $path-count;
    }

    for %device-map{$start} -> $output-device {
        $path-count += count-device-paths($output-device, $goal, ($seen-dac or $output-device eq 'dac'), ($seen-fft or $output-device eq 'fft'));
    }

    return $path-count;
}

say count-device-paths('you', 'out');
say count-device-paths('svr', 'out', False, False);