#!/usr/bin/env perl

use strict;
use warnings; 

use Data::Dumper;

my %cache;
while ( <DATA> ) {
   chomp;
   my ($a, $b, $c) = /(\w+) to (\w+) = (\d+)/;
   $cache{$a}->{$b} = $c;
   $cache{$b}->{$a} = $c;
}


my @permutations = permutations(keys %cache);
my ($fastest, $slowest) = compute_distances(
   \@permutations,
   [ sub { return sort { $a <=> $b } @_; },
     sub { return sort { $b <=> $a } @_; },
   ],
);

print "fastest: $fastest\n";
print "slowest: $slowest\n";

sub compute_distances {
   my ($permutations, $funcs) = @_;

   my @distances;
   foreach my $perm ( @$permutations ) {
      my $acc = 0;
      foreach my $i ( 0 .. $#{ $perm } - 1 ) {
         $acc += $cache{ $perm->[$i] }->{ $perm->[$i+1] } 
      }
   
      push @distances, $acc;
   }

   return map { ($_->(@distances))[0] } @$funcs;
}

sub permutations {
   my (@elements) = @_;

   return []
      unless @elements;
   return [ shift @elements ]
      if @elements == 1;
   
   my ($head, @tail) = @elements;
   my @perms;
   foreach my $p ( permutations(@tail) ) {
      my $p_len = $#{ $p };
      foreach my $i ( 0 .. @$p ) {
         push @perms, [ @$p[0..$i-1], $head, @$p[$i..$p_len] ];
      }
   }

   return @perms;
}

__DATA__
AlphaCentauri to Snowdin = 66
AlphaCentauri to Tambi = 28
AlphaCentauri to Faerun = 60
AlphaCentauri to Norrath = 34
AlphaCentauri to Straylight = 34
AlphaCentauri to Tristram = 3
AlphaCentauri to Arbre = 108
Snowdin to Tambi = 22
Snowdin to Faerun = 12
Snowdin to Norrath = 91
Snowdin to Straylight = 121
Snowdin to Tristram = 111
Snowdin to Arbre = 71
Tambi to Faerun = 39
Tambi to Norrath = 113
Tambi to Straylight = 130
Tambi to Tristram = 35
Tambi to Arbre = 40
Faerun to Norrath = 63
Faerun to Straylight = 21
Faerun to Tristram = 57
Faerun to Arbre = 83
Norrath to Straylight = 9
Norrath to Tristram = 50
Norrath to Arbre = 60
Straylight to Tristram = 27
Straylight to Arbre = 81
Tristram to Arbre = 90
