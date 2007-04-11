#!/usr/bin/perl -w
use Test::More tests => 36;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
	use_ok('Math::Vec2');
}

my ( $v, $v1, $v2 );

is( $v = new Math::Vec2(), "0 0", "$v new Math::Vec2()" );
is( $v = new Math::Vec2( 1, 2 ), "1 2", "$v new Math::Vec2()" );
is( $v = new Math::Vec2( [ 1, 2 ] ), "1 2", "$v new Math::Vec2()" );
is( $v = new Math::Vec2($v), "1 2", "$v new Math::Vec2()" );
is( "$v", "1 2", "$v ''" );

is( $v = Math::Vec2->new( 1, 2 )->getX, "1", "$v getX" );
is( $v = Math::Vec2->new( 1, 2 )->getY, "2", "$v getY" );

is( $v = Math::Vec2->new( 1, 2 )->x, "1", "$v x" );
is( $v = Math::Vec2->new( 1, 2 )->y, "2", "$v y" );

is( $v = new Math::Vec2( 1, 2 ), "1 2", "$v new Math::Vec2()" );
is( $v->x = 2, "2", "$v x" );
is( $v->y = 3, "3", "$v y" );

is( $v->[0], "2", "$v [0]" );
is( $v->[1], "3", "$v [1]" );

ok( Math::Vec2->new( 1, 2 ) eq "1 2", "$v eq" );

is( $v = new Math::Vec2( 1, 2 ), "1 2", "$v new Math::Vec2()" );

is( $v->copy, "1 2", "$v copy" );

ok( $v eq new Math::Vec2( 1, 2 ), "$v eq" );
ok( $v == new Math::Vec2( 1, 2 ), "$v ==" );
ok( $v ne new Math::Vec2( 0, 2 ), "$v ne" );
ok( $v != new Math::Vec2( 0, 2 ), "$v !=" );

is( $v1 = new Math::Vec2( 1, 2 ), "1 2", "$v1 v1" );
is( $v2 = new Math::Vec2( 2, 3 ), "2 3", "$v2 v2" );

is( $v = -$v1,      "-1 -2", "$v -" );
is( $v = $v1 + $v2, "3 5",   "$v +" );
is( $v = $v1 - $v2, "-1 -1", "$v -" );
is( $v = $v1 * 2,   "2 4",   "$v *" );
is( $v = $v1 / 2,   "0.5 1", "$v /" );
is( $v = $v1 . $v2, "8",     "$v ." );
is( $v = $v1 . [ 2, 3 ], "8", "$v ." );

is( sprintf( "%0.0f", $v = $v1->length ), "2", "$v length" );

is( $v1 += $v2, "3 5", "$v1 +=" );
is( $v1 -= $v2, "1 2", "$v1 -=" );
is( $v1 *= 2, "2 4", "$v1 *=" );
is( $v1 /= 2, "1 2", "$v1 /=" );

#use Math::Rotation;
#my $r = new Math::Rotation(2,3,4,5);
#ok( $v = $r * $v1, "$v x ");

__END__
