#!/usr/bin/perl -w

BEGIN { unshift @INC, 'lib'; }

use Math::BigInt;
use Math::String;
use Test;
BEGIN { plan tests => 7; }

my ($x,$y);
# M::BI itself
$x = Math::BigInt::badd(4,5);
ok ($x,9);

$x = Math::BigInt->badd(4,5);
ok ($x,9);

$x = new Math::BigInt 4;
$x = Math::BigInt->badd($x,5);
ok ($x,9);

$x = new Math::BigInt 4;
$y = new Math::BigInt 5;
$x = Math::BigInt->badd($x,$y);
ok ($x,9);

$x = new Math::BigInt 4;
$y = new Math::BigInt 5;
$x->badd($y);
ok ($x,9);

$x = new Math::BigInt 4;
$x->badd(5);
ok ($x,9);

# a child of it
$x = Math::String->badd('d','e');
ok ($x,'i');

