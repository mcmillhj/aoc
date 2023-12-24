#!perl

use strict;
use warnings;

use feature    qw(say);
use List::Util qw(sum);
use Data::Dumper;

my ($_x, $_m, $_a, $_s) = (0, 0, 0, 0);

sub __A { return 1; }
sub __R { return 0; }

my ($workflows, $parts) = do {
  local $/ = undef;

  map { [ split "\n" ] } split "\n\n", <>;
};

print Dumper $workflows, $parts;
foreach my $workflow (@$workflows) {
  my $workflow_copy = $workflow;
  $workflow_copy =~ s/(\w+)\{/sub __$1 { /;
  $workflow_copy =~
    s/(\w+)([<>])(\d+):(\w+),/ if(\$_$1 $2 $3) { return __$4(); }/g;
  $workflow_copy =~
    s/(\w+)\}/return __$1(); } 1;/; # 1; ensures a truthy return value from eval

  say $workflow_copy;
  eval($workflow_copy) or die $!;
}

sub rating { $_->[0] + $_->[1] + $_->[2] + $_->[3] }

say "Part 1: " . sum map { rating($_) }
  grep { ($_x, $_m, $_a, $_s) = @$_; __in(); }
  map { [ $_ =~ m/(\d+)/g ] } @$parts;

my %ranges = (
  _x => [ 0, 4000 ],
  _m => [ 0, 4000 ],
  _a => [ 0, 4000 ],
  _s => [ 0, 4000 ],
);

# find allowed ranges for each rating by scanning all the workflows
# e.g. a<2006 implies that this rule matches any 0 <= a <= 2005
# after scanning we will have all of the possible ranges of allowed values
# for each rating and can initialize each rating using the range start
foreach my $workflow (@$workflows) {
  print Dumper $workflow;

  my @matches = $workflow =~ m/(?:(\w+)([<>])(\d+):\w+,)/g;
  while (@matches) {
    my ($target, $operator, $threshold) = splice(@matches, 0, 3);
    print Dumper [ $target, $operator, $threshold ];

    push @{ $ranges{ "_" . $target } },
      int($operator eq '<' ? $threshold - 1 : $threshold);
  }
}

# order ranges for each rating from smallest to largest
while (my ($rating, $thresholds) = each %ranges) {
  $ranges{$rating} = [ sort { $a <=> $b } @$thresholds ];
}

my $c = 0;

for (my $x_i = 1 ; $x_i <= $#{ $ranges{'_x'} } ; $x_i++) {
  say "Starting loop $x_i of " . $#{ $ranges{'_x'} } . " ...";
  for (my $m_i = 1 ; $m_i <= $#{ $ranges{'_m'} } ; $m_i++) {
    for (my $a_i = 1 ; $a_i <= $#{ $ranges{'_a'} } ; $a_i++) {
      for (my $s_i = 1 ; $s_i <= $#{ $ranges{'_s'} } ; $s_i++) {
        $_x = $ranges{"_x"}[$x_i];
        $_m = $ranges{"_m"}[$m_i];
        $_a = $ranges{"_a"}[$a_i];
        $_s = $ranges{"_s"}[$s_i];

        next unless __in();

        $c +=
          ($ranges{"_x"}[$x_i] - $ranges{"_x"}[ $x_i - 1 ]) *
          ($ranges{"_m"}[$m_i] - $ranges{"_m"}[ $m_i - 1 ]) *
          ($ranges{"_a"}[$a_i] - $ranges{"_a"}[ $a_i - 1 ]) *
          ($ranges{"_s"}[$s_i] - $ranges{"_s"}[ $s_i - 1 ]);
      }
    }
  }
}

print Dumper \%ranges;
say $c;

