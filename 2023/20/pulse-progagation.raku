#!raku
constant $HIGH_PULSE = 1;
constant $LOW_PULSE = 0;
subset Pulse of Int where * == $LOW_PULSE | $HIGH_PULSE;
subset ModuleType of Str where * ~~ 'conjunction' | 'flipflop' | 'broadcaster';

class PulseQueue {
    my PulseQueue $instance;
    has Int $!pulse-counter = 0;
    has @.pulses handles(
        'push', 'shift', 'head', 'tail', 'elems'
    );

    method new { !!! }

    submethod instance {
        $instance = PulseQueue.bless unless $instance;
        $instance;
    }
}

class Module {
    has ModuleType $.type is rw;
    has Str $.name;
    has Str @.input-modules;
    has Str @.output-modules;
    has PulseQueue $.pulse-queue;

    method pulse(Module $source, Pulse $p) {
        dd [$source, $p];
        ...
    }

    method Str {
        self.name;
    }

    method graphviz { ... }
}

class BroadcasterModule is Module {
    submethod TWEAK {
        self.type = "broadcaster"
    }

    method pulse(Module $source, Pulse $p) {
        # say $source.name ~ " -- $p --> " ~ self.name ~ "...";
        for self.output-modules -> $m {
            self.pulse-queue.push(($m, self, $p));
        }
    }

    method graphviz {
        (
            self.name ~ " [shape=box];",
            |self.output-modules.map(-> $m { self.name ~ " -> $m;"; });
        ).join("\n");
    }
}

class FlipFlopModule is Module {
    has Bool $!state = False;

    submethod TWEAK {
        self.type = "flipflop"
    }

    method pulse(Module $source, Pulse $p) {
        # flipflop modules ignore high pulses
        return if $p == $HIGH_PULSE;


        # if the flipflop module is off, it emits a high pulse
        # if the flipflop module is on, it emits a low pulse
        for self.output-modules -> $m {
            self.pulse-queue.push(
                [$m, self, $!state ?? $LOW_PULSE !! $HIGH_PULSE]
            );
        }

        # low pulses toggle the state of the flipflop module
        $!state = not $!state;
    }

    method Str {
        "%" ~ self.name;
    }

    method graphviz {
        (
            self.name ~ " [shape=invtriangle];",
            |self.output-modules.map(-> $m { self.name ~ " -> $m;"; });
        ).join("\n");
    }
}

class ConjunctionModule is Module {
    has Pulse %!input-pulses;

    submethod TWEAK {
        self.type = "conjunction";

        # initialize memory for all inputs to a low pulse
        for self.input-modules -> $m {
            %!input-pulses{$m} = $LOW_PULSE;
        }
    }

    method pulse(Module $source, Pulse $p) {
        # update pulse memory for inputs
        %!input-pulses{$source.name} = $p;

        my Bool $has-at-least-one-low-pulse =
            %!input-pulses.elems == 0 || so $LOW_PULSE == %!input-pulses.values.any;

        # emit a low pulse only if all input pulses are high
        # otherwise, emit a high pulse
        for self.output-modules -> $m {
            self.pulse-queue.push(
                [$m, self, $has-at-least-one-low-pulse ?? $HIGH_PULSE !! $LOW_PULSE]
            );
        }
    }

    method Str {
        "&" ~ self.name;
    }

    method graphviz {
        (
            self.name ~ " [shape=invhouse];",
            |self.output-modules.map(-> $m { self.name ~ " -> $m;"; });
        ).join("\n");
    }
}

class GoalModule is Module {
    method pulse(Module $source, Pulse $p) { 
        # do nothing
    }

    method graphviz {
        self.name ~ " [shape=circle]";
    }
}

my Module %modules;
my %module-outputs;
my %module-inputs;
my @module-definitions = $*IN.lines.map(-> $line {
    my ($module, $output-modules-string) = $line.split(' -> ');
    my @output-modules = $output-modules-string.split(", ");

    my $module-name = S/\W// given $module;
    my $module-type = do given $module {
        when m/\%/ { "flipflop" }
        when m/\&/ { "conjunction" }
        default { "broadcaster" }
    }
    %module-outputs{$module-name} = @output-modules;
    for @output-modules -> $output-module {
        %module-inputs{$output-module}.push: $module-name;
    }

    [$module-name, $module-type, @output-modules]
});

my $pulse-queue = PulseQueue.instance;
for @module-definitions -> [$module-name, $module-type, @output-modules] {
    given $module-type {
        when 'flipflop' {
            %modules{$module-name} = FlipFlopModule.new(
                name           => $module-name,
                input-modules  => |%module-inputs{$module-name},
                output-modules => @output-modules,
                pulse-queue    => $pulse-queue
            );
        }
        when 'conjunction' {
            %modules{$module-name} = ConjunctionModule.new(
                name           => $module-name,
                input-modules  => |%module-inputs{$module-name},
                output-modules => @output-modules,
                pulse-queue    => $pulse-queue
            );
        }
        default {
            %modules{$module-name} = BroadcasterModule.new(
                name           => $module-name,
                input-modules  => |(%module-inputs{$module-name} // []),
                output-modules => @output-modules,
                pulse-queue    => $pulse-queue
            );
        }
    }
}

%modules{"rx"} = GoalModule.new(name => "rx", pulse-queue => $pulse-queue);
sub press-button(Int $times = 1) {
    my $low-pulses = 0;
    my $high-pulses = 0;
    for ^$times -> $iteration {
        $pulse-queue.push(["broadcaster", Module.new(name => "button"), $LOW_PULSE]);

        while $pulse-queue.elems > 0 {
            my ($target-module-name, $source, $pulse) = $pulse-queue.shift;

            given $pulse {
                when $LOW_PULSE  {
                    $low-pulses++;
                }
                when $HIGH_PULSE { $high-pulses++; }
            }

            # ignore modules that do not have outputs
            next unless %modules{$target-module-name};

            %modules{$target-module-name}.pulse($source, $pulse);
        }
    }

    $low-pulses, $high-pulses
}

say "Part 1: " ~ [*] press-button(1000);

# graphviz debugging output
say 'digraph G {';
for %modules.keys -> $m {
    say %modules{$m}.graphviz;
}
say %modules<rx>.graphviz;
say '}';