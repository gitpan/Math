#!/usr/bin/perl -w
use Test::More tests => 896;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
}

use Math  ();
use POSIX ();

my ( $v, $v1, $v2 );

is( $v = Math::E,    2**( 1 / CORE::log(2) ), "Math::E = $v" );
is( $v = Math::LN10, CORE::log(10),           "Math::LN10 = $v" );
is( $v = Math::LN2,  CORE::log(2),            "Math::LN2 = $v" );
is( $v = Math::PI,    CORE::atan2( 0, -1 ),     "Math::PI = $v" );
is( $v = Math::PI1_4, CORE::atan2( 1, 1 ),      "Math::PI1_4 = $v" );
is( $v = Math::PI1_2, CORE::atan2( 1, 0 ),      "Math::PI1_2 = $v" );
is( $v = Math::PI3_4, CORE::atan2( 1, -1 ),     "Math::PI1_4 = $v" );
is( $v = Math::PI2,   CORE::atan2( 0, -1 ) * 2, "Math::PI2 = $v" );
is( $v = Math::SQRT1_2, CORE::sqrt(0.5), "Math::SQRT1_2 = $v" );
is( $v = Math::SQRT2,   CORE::sqrt(2),   "Math::SQRT2 = $v" );

is( Math::abs(-1),     1,                  "Math::abs(-1)" );
is( Math::acos(-1),    POSIX::acos(-1),    "Math::acos(-1)" );
is( Math::asin(-1),    POSIX::asin(-1),    "Math::asin(-1)" );
is( Math::atan(-1),    POSIX::atan(-1),    "Math::atan(-1)" );
is( Math::ceil(-1.2),  POSIX::ceil(-1.2),  "Math::ceil(-1)" );
is( Math::cos(-1),     CORE::cos(-1),      "Math::cos(-1)" );
is( Math::exp(2),      CORE::exp(2),       "Math::exp(2)" );
is( Math::floor(-2.3), POSIX::floor(-2.3), "Math::floor(-1)" );
is( Math::log(2),      CORE::log(2),       "Math::log(-1)" );
is( Math::log10(2),    POSIX::log10(2),    "Math::log(-1)" );
is( Math::min( 3, 2 ), 2, "Math::min(3, 2)" );
is( Math::max( 3, 2 ), 3, "Math::max(3, 2)" );
is( Math::minmax( -1, 3, 2 ), 2, "Math::minmax(-1, 3, 2)" );
is( Math::pow( 2, 4 ), 2**4, "Math::pow(2, 4)" );
ok( Math::random( 1, 2 ), "Math::random()" );
is( Math::round(-1), -1,             "Math::round(-1)" );
is( Math::sin(-1),   CORE::sin(-1),  "Math::sin(-1)" );
is( Math::sqrt(2),   CORE::sqrt(2),  "Math::sqrt(-1)" );
is( Math::sum(-1),   -1,             "Math::sum(-1)" );
is( Math::tan(-1),   POSIX::tan(-1), "Math::tan(-1)" );

my ( $min, $max, $n ) = ( 10, 100, 0 );
for ( 0 .. 17_000 ) {
	$n = Math::random( $min, $max );
	ok(0) if $n < $min || $n > $max;
}
ok($n);

is( Math::round(0),    0 );
is( Math::round(-0.4), 0 );
is( Math::round(-0.5), -1 );
is( Math::round(-0.6), -1 );
is( Math::round(0.4),  0 );
is( Math::round(0.5),  1 );
is( Math::round(0.6),  1 );
is( Math::round( 4,  -1 ), 0 );
is( Math::round( 5,  -1 ), 10 );
is( Math::round( 6,  -1 ), 10 );
is( Math::round( 40, -2 ), 0 );
is( Math::round( 50, -2 ), 100 );
is( Math::round( 60, -2 ), 100 );

is( Math::round( 12345, -2 ), 12300 );

is( Math::round( 0,    0 ), 0 );
is( Math::round( -0.4, 0 ), 0 );
is( Math::round( -0.5, 0 ), -1 );
is( Math::round( -0.6, 0 ), -1 );
is( Math::round( 0.4,  0 ), 0 );
is( Math::round( 0.5,  0 ), 1 );
is( Math::round( 0.6,  0 ), 1 );

is( Math::min( 3, 2 ), 2 );
is( Math::min( 2, 3 ), 2 );
is( Math::min( 4, 5, 3, 2 ), 2 );
is( Math::min( 7, 7, 2, 2, 3, 4, 7, 3 ), 2 );

is( Math::max( 3, 2 ), 3 );
is( Math::max( 2, 3 ), 3 );
is( Math::max( 4, 5, 3, 2 ), 5 );
is( Math::max( 7, 7, 2, 2, 8, 4, 7, 3 ), 8 );

is( Math::minmax( 4,  2, 8 ), 4 );
is( Math::minmax( 1,  2, 8 ), 2 );
is( Math::minmax( 10, 2, 8 ), 8 );

is( Math::sum(), 0 );
is( Math::sum(23), 23 );
is( Math::sum( 3, 45 ), 48 );
is( Math::sum( 10, 2, 8 ), 20 );
is( Math::sum( 0 .. 100 ), 5050 );

is( Math::pro(), 0 );
is( Math::pro(23), 23 );
is( Math::pro( 2, 3 ), 6 );
is( Math::pro( 2, 3, 4 ), 24 );

is( Math::even(-1), 0 );
is( Math::even(1),  0 );
is( Math::even(0),  1 );
is( Math::even(2),  1 );
is( Math::even(-2), 1 );

is( Math::odd(-1), 1 );
is( Math::odd(1),  1 );
is( Math::odd(0),  0 );
is( Math::odd(2),  0 );
is( Math::odd(-2), 0 );

is( Math::even($_), 1 ) foreach map { $_ * 2 } ( -100 .. 100 );
is( Math::odd($_),  0 ) foreach map { $_ * 2 } ( -100 .. 100 );
is( Math::even($_), 0 ) foreach map { 1 + $_ * 2 } ( -100 .. 100 );
is( Math::odd($_),  1 ) foreach map { 1 + $_ * 2 } ( -100 .. 100 );
is( Math::sig(2),   1 );

is( Math::even(3), 0 );
is( Math::odd(3),  1 );
is( Math::sig(3),  1 );

is( Math::even(-3), 0 );
is( Math::odd(-3),  1 );
is( Math::sig(-3),  -1 );

is( Math::even(-2), 1 );
is( Math::odd(-2),  0 );
is( Math::sig(-2),  -1 );

