#!perl

use strict;
use warnings;

use feature    qw(say);
use Storable   qw(dclone);
use List::Util qw(all any);

sub is_decreasing {
    my @report_pairs = @_;

    return all { $_->[1] < $_->[0] } @report_pairs;
}

sub is_increasing {
    my @report_pairs = @_;

    return all { $_->[1] > $_->[0] } @report_pairs;
}

sub has_unsafe_level_change {
    my @report_pairs = @_;

    return any {
        my $level_change = abs( $_->[1] - $_->[0] );

        $level_change == 0 or $level_change > 3
    } @report_pairs;
}

sub is_safe_report {
    my ($report) = @_;

    my @pairs =
      map { [ $report->[$_], $report->[ $_ + 1 ] ] } 0 .. $#{$report} - 1;

    return ( is_decreasing(@pairs) || is_increasing(@pairs) )
      && !has_unsafe_level_change(@pairs);
}

sub is_safe_report_after_dampening {
    my ($unsafe_report) = @_;

    return any {
        my $index = $_;

        # create a deep copy of the unsafe report
        my $dampened_report = dclone($unsafe_report);

        # remove the report level at the $ith index
        splice( @$dampened_report, $index, 1 );

        # test if the dampened report is safe
        is_safe_report($dampened_report)
    } 0 .. $#{$unsafe_report};
}

my @reports = do {
    local $/ = undef;

    map {
        [ map { int } split /\s+/ ]
    } split "\n", readline( \*STDIN );
};

my @safe_reports = grep { is_safe_report $_ } @reports;
say scalar @safe_reports;

my @safe_reports_after_dampening =
  grep { is_safe_report_after_dampening $_ }
  grep { !is_safe_report $_ } @reports;

say scalar @safe_reports + scalar @safe_reports_after_dampening;
