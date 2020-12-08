#!/usr/bin/env perl

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use feature qw(say);

my $secret = 'yzbqklnj';
my $data   = 1;

while ( (my $hash = md5_hex($secret . $data)) !~ m/^0{6}/ ) {
   $data++;
}
say $data;

