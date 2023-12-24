#!raku

use MONKEY-SEE-NO-EVAL;

my (@workflows, @parts) := $*IN.slurp.split("\n\n")>>.split("\n");

grammar Workflow {
    token TOP            { <workflow-name> \{ <workflow-rules>+ \} }
    rule workflow-rules  { [<workflow-rule> ',']+ <workflow-name> }
    rule workflow-rule   { <part> <operator> <threshold> ':' <workflow-name> }
    token part           { 'x' | 'm' | 'a' | 's' }
    token operator       { '>' | '<' }
    token threshold      { \d+ }
    token workflow-name  { \w+ }
}

class WorkflowActions {
    method TOP ($/) {
        make "our sub _$<workflow-name>\(" ~ '$x, $m, $a, $s' ~ "\) \{ " ~ $<workflow-rules>.map: *.made ~ ' }';
    }

    method workflow-rules ($/) {
        make $<workflow-rule>.map(*.made).join(' ') ~ " return _$<workflow-name>\(" ~ '$x, $m, $a, $s' ~ "\);";
    }

    method workflow-rule($/) {
        make "if (\$$<part> $<operator> $<threshold>) \{ return _$<workflow-name>\(" ~ '$x, $m, $a, $s' ~ "\); \};";
    }
}

class WorkflowRanges {
    method TOP($/) {
        make $<workflow-rules>.flatmap(*.made);
    }

    method workflow-rules($/) {
        make $<workflow-rule>.map(*.made);
    }

    method workflow-rule($/) {
        make ~$<part> => ($<operator> eq '<' ?? $<threshold> - 1 !! $<threshold>).Int
    }
}

# terminal states
sub _A($x, $m, $a, $s) { return True;  }
sub _R($x, $m, $a, $s) { return False; }

# parse workflows and serialize into subroutinues
EVAL @workflows.map(-> $workflow { Workflow.parse($workflow, actions => WorkflowActions).made }).join("\n");

# starting subroutine
my $IN = "_in";

say "Part 1: " ~
    [+] @parts
        # convert parts into xmas ratings
        .map(-> $part { ($part ~~ m:g/(\d+)/)>>.Int })
        # test if this part is accepted
        .grep({
            my ($x, $m, $a, $s) = $_;

            &::($IN)($x, $m, $a, $s);
        })
        # combine ratings into a single number
        .map({ [+] $_ });


my %inflection-points = (
    'x' => [0, 4000],
    'm' => [0, 4000],
    'a' => [0, 4000],
    's' => [0, 4000],
);

# find the inflection points for each rating by scanning all the workflows
# e.g. a<2006 implies that this rule matches any 0 <= a <= 2005
# after scanning we will have all of the inflection points for each rating
for @workflows -> $workflow {
    for Workflow.parse($workflow, actions => WorkflowRanges).made -> (:$key, :$value) {
        %inflection-points{$key}.push: $value;
    }
}

# order the inflection points in ascending order
for %inflection-points.keys -> $key {
    # convert to an array to avoid exhausting the Seq
    %inflection-points{$key} = %inflection-points{$key}.sort({ $^a <=> $^b }).Array;
}


my atomicint $accepted-combinations = 0;
my @x-inflection-points = %inflection-points<x>.keys.tail(* - 1);
my @m-inflection-points = %inflection-points<m>.keys.tail(* - 1);
my @a-inflection-points = %inflection-points<a>.keys.tail(* - 1);
my @s-inflection-points = %inflection-points<s>.keys.tail(* - 1);
# takes a long time [258*252*286*274] iterations
# use 8 threads to boost speed
hyper for @x-inflection-points.hyper(degree => 10) -> $x-i {
    say "Starting iteration $x-i of " ~ @x-inflection-points.elems ~ "...";
    for @m-inflection-points -> $m-i {
        for @a-inflection-points -> $a-i {
            for @s-inflection-points -> $s-i {
                my $x = %inflection-points<x>[$x-i];
                my $m = %inflection-points<m>[$m-i];
                my $a = %inflection-points<a>[$a-i];
                my $s = %inflection-points<s>[$s-i];

                # ignore parts that are rejected
                next unless &::($IN)($x, $m, $a, $s);

                # if we find an accepted part at one of the inflection points we can infer that
                # the entire range is accepted
                # the range for each x,m,a,s is the distance from inflection point $i to the
                # previous inflection point $i - 1
                $accepted-combinations ⚛+=
                      (%inflection-points<x>[$x-i] - %inflection-points<x>[$x-i - 1])
                    * (%inflection-points<m>[$m-i] - %inflection-points<m>[$m-i - 1])
                    * (%inflection-points<a>[$a-i] - %inflection-points<a>[$a-i - 1])
                    * (%inflection-points<s>[$s-i] - %inflection-points<s>[$s-i - 1]);
            }
        }
    }
}

say "Part 2: " ~ $accepted-combinations;