#!/usr/bin/perl -w
use Test::More tests => 78;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
	use_ok('Math::ColorRGBA');
}

use Math::Trig qw(pi);

my ( $v, $v1, $v2 );

is( $v = new Math::ColorRGBA(), "0 0 0 0", "$v new Math::ColorRGBA()" );
is( $v = new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );
is( $v = new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );
is( $v = new Math::ColorRGBA( [ 0.1, 0.2, 0.3, 0 ] ), "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );
is( $v = new Math::ColorRGBA( [ 0.1, 0.2, 0.3, 0.0 ] ), "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );
is( $v = $v->copy, "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );
is( "$v", "0.1 0.2 0.3 0", "$v ''" );

is( $v = Math::ColorRGBA->new( 0.1, 0.2, 0.3, 0 )->getX, "0.1", "$v getX" );
is( $v = Math::ColorRGBA->new( 0.1, 0.2, 0.3, 0 )->getY, "0.2", "$v getY" );
is( $v = Math::ColorRGBA->new( 0.1, 0.2, 0.3, 0 )->getZ, "0.3", "$v getZ" );

is( $v = Math::ColorRGBA->new( 0.1, 0.2, 0.3, 0 )->x, "0.1", "$v x" );
is( $v = Math::ColorRGBA->new( 0.1, 0.2, 0.3, 0 )->y, "0.2", "$v y" );
is( $v = Math::ColorRGBA->new( 0.1, 0.2, 0.3, 0 )->z, "0.3", "$v z" );

is( $v = new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );
is( $v->setRed(2),   "2", "$v x" );
is( $v->setGreen(3), "3", "$v y" );
is( $v->setBlue(4),  "4", "$v z" );

ok( $v->x == $v->getRed, "$v x" );
ok( $v->x == $v->red,    "$v x" );
ok( $v->x == $v->r,      "$v x" );

ok( $v->y == $v->getGreen, "$v y" );
ok( $v->y == $v->green,    "$v y" );
ok( $v->y == $v->g,        "$v y" );

ok( $v->z == $v->getBlue, "$v z" );
ok( $v->z == $v->blue,    "$v z" );
ok( $v->z == $v->b,       "$v z" );

is( $v->[0], "2", "$v [0]" );
is( $v->[1], "3", "$v [1]" );
is( $v->[2], "4", "$v [2]" );

ok( Math::ColorRGBA->new( 0.1, 0.2, 0.3, 0 ) eq "0.1 0.2 0.3 0", "$v eq" );

is( $v = new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );

is( $v->copy, "0.1 0.2 0.3 0", "$v copy" );

ok( $v eq new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "$v eq" );
ok( $v == new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "$v ==" );
ok( $v ne new Math::ColorRGBA( 0, 2, 3, 0 ), "$v ne" );
ok( $v != new Math::ColorRGBA( 0, 2, 3, 0 ), "$v !=" );

is( $v1 = new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "0.1 0.2 0.3 0", "$v1 v1" );
is( $v = $v1 + [ 0.1, 0.2, 0.3 ], "0.2 0.4 0.6 0", "$v +" );
is( $v = $v1 - [ 0.1, 0.2, 0.3, 0 ], "0 0 0 0",  "$v -" );

is( $v2 = new Math::ColorRGBA( 0.2, 0.3, 0.4, 0 ), "0.2 0.3 0.4 0", "$v2 v2" );

is( $v = -$v1,      "0 0 0 0",         "$v -" );
is( $v = $v1 + $v2, "0.3 0.5 0.7 0",   "$v +" );
is( $v = $v1 - $v2, "0 0 0 0",         "$v -" );
is( $v = $v1 * 2,   "0.2 0.4 0.6 0",   "$v *" );
is( $v = $v1 / 2,   "0.05 0.1 0.15 0", "$v /" );
is( $v = $v1 . $v2, "0.2",             "$v ." );
is( $v = $v1 x $v2, "0 0.02 0 0",      "$v x" );
is( $v = $v1 . [ 2, 3, 4 ], "2",         "$v ." );
is( $v = $v1 x [ 2, 3, 4 ], "0 0.2 0 0", "$v x" );
is( $v = $v1 x 2, "0.1 0.2 0.3 00.1 0.2 0.3 0", "$v x" );

is( sprintf( "%0.0f", $v = $v1->length ), "0", "$v length" );

is( $v1 += $v2, "0.3 0.5 0.7 0", "$v1 +=" );
is( $v1 -= $v2, "0.1 0.2 0.3 0", "$v1 -=" );
is( $v1 *= 2, "0.2 0.4 0.6 0", "$v1 *=" );
is( $v1 /= 2, "0.1 0.2 0.3 0", "$v1 /=" );

$v1->setHSV( 0 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 0 0 0", "$v1 setHSV" );

$v1->setHSV( 1 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 1 0 0", "$v1 setHSV" );

$v1->setHSV( 2 / 6 * 2 * pi, 1, 1 );
is( $v1, "0 1 0 0", "$v1 setHSV" );

$v1->setHSV( 3 / 6 * 2 * pi, 1, 1 );
is( $v1, "0 1 1 0", "$v1 setHSV" );

$v1->setHSV( 4 / 6 * 2 * pi, 1, 1 );
is( $v1, "0 0 1 0", "$v1 setHSV" );

$v1->setHSV( 5 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 0 1 0", "$v1 setHSV" );

$v1->setHSV( 6 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 0 0 0", "$v1 setHSV" );

is( $v = new Math::ColorRGBA( 0.1, 0.2, 0.3, 0 ), "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );
is( $v, "0.1 0.2 0.3 0", "$v new Math::ColorRGBA()" );

$v1->setHSV( 1 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "1 0.5 0 0", "$v1 setHSV" );

$v1->setHSV( 3 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0.5 1 0 0", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 5 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0 1 0.5 0", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 7 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0 0.5 1 0", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 9 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0.5 0 1 0", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 11 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "1 0 0.5 0", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setValue( 1, 2, 3, 4, 0 );
is( $v1, "1 1 1 1", "$v1 setValue" );

$v1->setAlpha(-4);
is( $v1, "1 1 1 0", "$v1 setValue" );

#use Math::Rotation;
#my $r = new Math::Rotation(2,3,4,5);
#ok( $v = $r * $v1, "$v x ");

__END__
