#!/usr/bin/perl -w

# test mixed arguments and overloading

use strict;
use Test;

BEGIN 
  {
  chdir 't' if -d 't';
  unshift @INC, '../lib';
#  unshift @INC, '../old';
  plan tests => 6;
  }

use Math::BigInt;
use Math::BigFloat;

my $x = Math::BigFloat->new(10);
my $u = Math::BigFloat->new(2.5);
my $y = Math::BigInt->new(2);

my $z;

$z = $x + $y; ok ($z,12); ok (ref($z),'Math::BigFloat');
$z = $x / $y; ok ($z,5); ok (ref($z),'Math::BigFloat');
$z = $u * $y; ok ($z,5); ok (ref($z),'Math::BigFloat');

# breakage:
# $z = $y * $u; ok ($z,5); ok (ref($z),'Math::BigInt');
# $z = $y + $x; ok ($z,12); ok (ref($z),'Math::BigInt');
# $z = $y / $x; ok ($z,0); ok (ref($z),'Math::BigInt');

# all done

