#!/usr/bin/perl -w

# test mixed arguments and overloading

use strict;
use Test;

BEGIN 
  {
  $| = 1;
  chdir 't' if -d 't';
  unshift @INC, '../lib';
#  unshift @INC, '../old';
  plan tests => 11;
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

$y = Math::BigInt->new(12345);
$z = $u->copy()->bmul($y,2,0,'odd'); ok ($z,31000);
$z = $u->copy()->bmul($y,3,0,'odd'); ok ($z,30900);
$z = $u->copy()->bmul($y,undef,0,'odd'); ok ($z,30863);
$z = $u->copy()->bmul($y,undef,1,'odd'); ok ($z,30860);
$z = $u->copy()->bmul($y,undef,-1,'odd'); ok ($z,30862.5);

# breakage:
# $z = $y->copy()->bmul($u,2,0,'odd'); ok ($z,31000);
# $z = $y * $u; ok ($z,5); ok (ref($z),'Math::BigInt');
# $z = $y + $x; ok ($z,12); ok (ref($z),'Math::BigInt');
# $z = $y / $x; ok ($z,0); ok (ref($z),'Math::BigInt');

# all done

