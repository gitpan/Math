#!/usr/bin/perl -w
use Test::More tests => 31;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
	use_ok('Math::Vec4');
}

my ( $v, $v1, $v2 );

is( $v = new Math::Vec4(), "0 0 0 0", "$v new Math::Vec4()" );
is( $v = new Math::Vec4( 1, 2, 3, 4 ), "1 2 3 4", "$v new Math::Vec4()" );
is( $v = new Math::Vec4( [ 1, 2, 3, 4 ] ), "1 2 3 4", "$v new Math::Vec4()" );
#is( $v = new Math::Vec4( 1, 2, 3 ), "1 2 3 0", "$v new Math::Vec4()" );

$v = new Math::Vec4( 1, 0, 0, 0 );
is( $v->normalize, "1 0 0 0", "$v new Math::Vec4()" );
$v = new Math::Vec4( 0, 1, 0, 0 );
is( $v->normalize, "0 1 0 0", "$v new Math::Vec4()" );
$v = new Math::Vec4( 0, 0, 1, 0 );
is( $v->normalize, "0 0 1 0", "$v new Math::Vec4()" );
$v = new Math::Vec4( 0, 0, 0, 1 );
is( $v->normalize, "0 0 0 1", "$v new Math::Vec4()" );

is( $v1 = new Math::Vec4( 1, 2, 3, 4 ), "1 2 3 4", "$v new Math::Vec4()" );
is( $v2 = new Math::Vec4( 2, 3, 4, 5 ), "2 3 4 5", "$v new Math::Vec4()" );
is( $v = $v1 + $v2, "3 5 7 9",     "$v new Math::Vec4()" );
is( $v = $v1 - $v2, "-1 -1 -1 -1", "$v new Math::Vec4()" );
is( $v = $v1 * $v2, "2 6 12 20",   "$v new Math::Vec4()" );
ok( $v = $v1 / $v2, "$v new Math::Vec4()" );
is( $v = $v1 . $v2, "40", "$v new Math::Vec4()" );
is( $v = $v1 x $v2, "-4 -2 0 6", "$v new Math::Vec4()" );
like( $v->length, "/^7\.4/", "$v new Math::Vec4()" );

$v->[0] = 2345;
is( $v, "2345 -2 0 6", "$v new Math::Vec4()" );

#is( $v & [ 1, -2, 1, 1 ], "2345 -2 0 6", "$v new Math::Vec4()" );

is( $v = new Math::Vec4( 1, 2, 3, 4 ), "1 2 3 4", "$v new Math::Vec4()" );
is( $v = $v & 2, "0 2 2 0", "$v &" );
is( $v = $v & [2,2,2,2], "0 2 2 0", "$v &" );

is( $v = $v | 2, "2 2 2 2", "$v &" );
is( $v = $v | [2,2,2,2], "2 2 2 2", "$v &" );

is( $v = $v ^ 2, "0 0 0 0", "$v ^" );
is( $v = $v ^ [2,2,2,2], "2 2 2 2", "$v ^" );
is( $v = ~$v, "4294967293 4294967293 4294967293 4294967293", "$v ^" );

is( $v = new Math::Vec4( 1, 2, 3, 4 ), "1 2 3 4", "$v new Math::Vec4()" );
is( $v = $v << 2, "4 8 12 16", "$v ^" );
is( $v = $v >> 2, "1 2 3 4", "$v ^" );
is( $v = $v << [2,2,2,2], "4 8 12 16", "$v ^" );
is( $v = $v >> [2,2,2,2], "1 2 3 4", "$v ^" );
__END__
