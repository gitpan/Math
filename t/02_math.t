#!/usr/bin/perl -w
#package 02_math
use Test::More tests => 899;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
}

use Math ':all';
use POSIX ();

my ( $v, $v1, $v2 );

is( $v = E,    2**( 1 / CORE::log(2) ), "E = $v" );
is( $v = LN10, CORE::log(10),           "LN10 = $v" );
is( $v = LN2,  CORE::log(2),            "LN2 = $v" );
is( $v = PI,    CORE::atan2( 0, -1 ),     "PI = $v" );
is( $v = PI1_4, CORE::atan2( 1, 1 ),      "PI1_4 = $v" );
is( $v = PI1_2, CORE::atan2( 1, 0 ),      "PI1_2 = $v" );
is( $v = PI3_4, CORE::atan2( 1, -1 ),     "PI1_4 = $v" );
is( $v = PI2,   CORE::atan2( 0, -1 ) * 2, "PI2 = $v" );
is( $v = SQRT1_2, CORE::sqrt(0.5), "SQRT1_2 = $v" );
is( $v = SQRT2,   CORE::sqrt(2),   "SQRT2 = $v" );

is( abs(-1),     1,                  "abs(-1)" );
is( acos(-1),    POSIX::acos(-1),    "acos(-1)" );
is( asin(-1),    POSIX::asin(-1),    "asin(-1)" );
is( atan(-1),    POSIX::atan(-1),    "atan(-1)" );
is( ceil(-1.2),  POSIX::ceil(-1.2),  "ceil(-1)" );
is( cos(-1),     CORE::cos(-1),      "cos(-1)" );
is( exp(2),      CORE::exp(2),       "exp(2)" );
is( floor(-2.3), POSIX::floor(-2.3), "floor(-1)" );
is( log(2),      CORE::log(2),       "log(-1)" );
is( log10(2),    POSIX::log10(2),    "log(-1)" );
is( min( 3, 2 ), 2, "min(3, 2)" );
is( max( 3, 2 ), 3, "max(3, 2)" );
is( clamp( -1, 3, 2 ), 2, "clamp(-1, 3, 2)" );
is( pow( 2, 4 ), 2**4, "pow(2, 4)" );
ok( random( 1, 2 ), "random()" );
is( round(-1), -1,             "round(-1)" );
is( sin(-1),   CORE::sin(-1),  "sin(-1)" );
is( sqrt(2),   CORE::sqrt(2),  "sqrt(-1)" );
is( sum(-1),   -1,             "sum(-1)" );
is( tan(-1),   POSIX::tan(-1), "tan(-1)" );

my ( $min, $max, $n ) = ( 10, 100, 0 );
for ( 0 .. 17_000 ) {
	$n = random( $min, $max );
	ok(0) if $n < $min || $n > $max;
}
ok($n);

is( round(0),    0 );
is( round(-0.4), 0 );
is( round(-0.5), -1 );
is( round(-0.6), -1 );
is( round(0.4),  0 );
is( round(0.5),  1 );
is( round(0.6),  1 );
is( round( 4,  -1 ), 0 );
is( round( 5,  -1 ), 10 );
is( round( 6,  -1 ), 10 );
is( round( 40, -2 ), 0 );
is( round( 50, -2 ), 100 );
is( round( 60, -2 ), 100 );

is( round( 12345, -2 ), 12300 );

is( round( 0,    0 ), 0 );
is( round( -0.4, 0 ), 0 );
is( round( -0.5, 0 ), -1 );
is( round( -0.6, 0 ), -1 );
is( round( 0.4,  0 ), 0 );
is( round( 0.5,  0 ), 1 );
is( round( 0.6,  0 ), 1 );

is( min( 3, 2 ), 2 );
is( min( 2, 3 ), 2 );
is( min( 4, 5, 3, 2 ), 2 );
is( min( 7, 7, 2, 2, 3, 4, 7, 3 ), 2 );

is( max( 3, 2 ), 3 );
is( max( 2, 3 ), 3 );
is( max( 4, 5, 3, 2 ), 5 );
is( max( 7, 7, 2, 2, 8, 4, 7, 3 ), 8 );

is( clamp( 4,  2, 8 ), 4 );
is( clamp( 1,  2, 8 ), 2 );
is( clamp( 10, 2, 8 ), 8 );

is( sum(), 0 );
is( sum(23), 23 );
is( sum( 3, 45 ), 48 );
is( sum( 10, 2, 8 ), 20 );
is( sum( 0 .. 100 ), 5050 );

is( pro(), 0 );
is( pro(23), 23 );
is( pro( 2, 3 ), 6 );
is( pro( 2, 3, 4 ), 24 );

is( even(-1), 0 );
is( even(1),  0 );
is( even(0),  1 );
is( even(2),  1 );
is( even(-2), 1 );

is( odd(-1), 1 );
is( odd(1),  1 );
is( odd(0),  0 );
is( odd(2),  0 );
is( odd(-2), 0 );

is( even($_), 1 ) foreach map { $_ * 2 } ( -100 .. 100 );
is( odd($_),  0 ) foreach map { $_ * 2 } ( -100 .. 100 );
is( even($_), 0 ) foreach map { 1 + $_ * 2 } ( -100 .. 100 );
is( odd($_),  1 ) foreach map { 1 + $_ * 2 } ( -100 .. 100 );
is( sig(2),   1 );

is( even(3), 0 );
is( odd(3),  1 );
is( sig(3),  1 );

is( even(-3), 0 );
is( odd(-3),  1 );
is( sig(-3),  -1 );

is( even(-2), 1 );
is( odd(-2),  0 );
is( sig(-2),  -1 );

ok( atan2( 1, 1 ) == CORE::atan2( 1, 1 ) );
ok( fmod( 23.5, 4.7 ) );
ok( fmod( 23, 5 ) == 23 % 5 );

__END__
