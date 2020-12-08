#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(say);

my $alphabet = join '', ('a'..'z');
my $password = 'hepxcrrq';

do {
   $password++;
} while ! _valid_password($password);
say $password;

sub _valid_password {
   my ($password) = @_;

   return 
      _has_increasing_triplet($password, $alphabet)
      && _has_no_blacklisted_chars($password ,qw(i o l))
      && _has_two_different_repeated_pairs($password);
}
   
sub _has_increasing_triplet {
   my ($password, $alphabet) = @_;

   my @triplets = $alphabet =~ m/(?=(...))/g;
   return grep { $password =~ m/$_/ } @triplets; 
}

sub _has_no_blacklisted_chars {
   my ($password) = @_;
   return $password !~ m/[oil]/;
}

sub _has_two_different_repeated_pairs {
   my ($password) = @_;

   my @matches = $password =~ m/(.)\1/g;
   return @matches > 1;
}

