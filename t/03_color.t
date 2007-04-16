#!/usr/bin/perl -w
use Test::More tests => 71;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
	use_ok('Math::Vec3');
	use_ok('Math::Color');
}

use Math::Trig qw(pi);

my ( $v, $v1, $v2 );

is( $v = new Math::Color(), "0 0 0", "$v new Math::Color()" );
is( $v = ref $v, "Math::Color", "$v ref" );
is( $v = new Math::Color( 0.1, 0.2, 0.3 ), "0.1 0.2 0.3", "$v new Math::Color()" );
is( $v = new Math::Color( [ 0.1, 0.2, 0.3 ] ), "0.1 0.2 0.3", "$v new Math::Color()" );
is( $v = $v->copy, "0.1 0.2 0.3", "$v new Math::Color()" );
is( "$v", "0.1 0.2 0.3", "$v ''" );

is( $v = @{ Math::Color->getDefaultValue }, 3, "$v getDefaultValue" );

is( $v = Math::Color->new( 0.1, 0.2, 0.3 )->getX, "0.1", "$v getX" );
is( $v = Math::Color->new( 0.1, 0.2, 0.3 )->getY, "0.2", "$v getY" );
is( $v = Math::Color->new( 0.1, 0.2, 0.3 )->getZ, "0.3", "$v getZ" );

is( $v = Math::Color->new( 0.1, 0.2, 0.3 )->getX, "0.1", "$v x" );
is( $v = Math::Color->new( 0.1, 0.2, 0.3 )->getY, "0.2", "$v y" );
is( $v = Math::Color->new( 0.1, 0.2, 0.3 )->getZ, "0.3", "$v z" );

is( $v = new Math::Color( 0.1, 0.2, 0.3 ), "0.1 0.2 0.3", "$v new Math::Color()" );
$v->setRed(2);
$v->setGreen(3);
$v->setBlue(4);

ok( $v->getX == $v->getRed, "$v x" );
ok( $v->getX == $v->getRed, "$v x" );
ok( $v->getX == $v->getRed, "$v x" );

ok( $v->getY == $v->getGreen, "$v y" );
ok( $v->getY == $v->getGreen, "$v y" );
ok( $v->getY == $v->getGreen, "$v y" );

ok( $v->getZ == $v->getBlue, "$v z" );
ok( $v->getZ == $v->getBlue, "$v z" );
ok( $v->getZ == $v->getBlue, "$v z" );

is( $v->[0], "2", "$v [0]" );
is( $v->[1], "3", "$v [1]" );
is( $v->[2], "4", "$v [2]" );

ok( Math::Color->new( 0.1, 0.2, 0.3 ) eq "0.1 0.2 0.3", "$v eq" );

is( $v = new Math::Color( 0.1, 0.2, 0.3 ), "0.1 0.2 0.3", "$v new Math::Color()" );

is( $v->copy, "0.1 0.2 0.3", "$v copy" );

ok( $v eq new Math::Color( 0.1, 0.2, 0.3 ), "$v eq" );
ok( $v == new Math::Color( 0.1, 0.2, 0.3 ), "$v ==" );
ok( $v ne new Math::Color( 0, 0.2, 0.3 ), "$v ne" );
ok( $v != new Math::Color( 0, 0.2, 0.3 ), "$v !=" );

is( $v1 = new Math::Color( 0.1, 0.2, 0.3 ), "0.1 0.2 0.3", "$v1 v1" );
is( $v2 = new Math::Color( 0.2, 0.3, 0.4 ), "0.2 0.3 0.4", "$v2 v2" );

is( $v = ~$v1,      "0.9 0.8 0.7",         "$v ~" );
is( $v = $v1 + $v2, "0.3 0.5 0.7",   "$v +" );
is( $v = $v1 - $v2, "0 0 0",         "$v -" );
is( $v = $v1 * 2,   "0.2 0.4 0.6",   "$v *" );
is( $v = $v1 / 2,   "0.05 0.1 0.15", "$v /" );
is( $v = $v1 . $v2, "0.2",           "$v ." );
is( $v = $v1 x $v2, "0 0.02 0",      "$v x" );
is( $v = $v1 . [ 2, 3, 4 ], "2",       "$v ." );
is( $v = $v1 x [ 2, 3, 4 ], "0 0.2 0", "$v x" );

is( sprintf( "%0.0f", $v = $v1->length ), "0", "$v length" );

is( $v1 += $v2, "0.3 0.5 0.7", "$v1 +=" );
is( $v1 -= $v2, "0.1 0.2 0.3", "$v1 -=" );
is( $v1 *= 2, "0.2 0.4 0.6", "$v1 *=" );
is( $v1 /= 2, "0.1 0.2 0.3", "$v1 /=" );

$v1->setHSV( 0 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 0 0", "$v1 setHSV" );

$v1->setHSV( 1 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 1 0", "$v1 setHSV" );

$v1->setHSV( 2 / 6 * 2 * pi, 1, 1 );
is( $v1, "0 1 0", "$v1 setHSV" );

$v1->setHSV( 3 / 6 * 2 * pi, 1, 1 );
is( $v1, "0 1 1", "$v1 setHSV" );

$v1->setHSV( 4 / 6 * 2 * pi, 1, 1 );
is( $v1, "0 0 1", "$v1 setHSV" );

$v1->setHSV( 5 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 0 1", "$v1 setHSV" );

$v1->setHSV( 6 / 6 * 2 * pi, 1, 1 );
is( $v1, "1 0 0", "$v1 setHSV" );

is( $v = new Math::Color( 0.1, 0.2, 0.3 ), "0.1 0.2 0.3", "$v new Math::Color()" );
is( $v, "0.1 0.2 0.3", "$v new Math::Color()" );

$v1->setHSV( 1 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "1 0.5 0", "$v1 setHSV" );

$v1->setHSV( 3 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0.5 1 0", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 5 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0 1 0.5", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 7 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0 0.5 1", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 9 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "0.5 0 1", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

$v1->setHSV( 11 / 12 * 2 * pi, 1, 1 ); $v->setHSV( $v1->getHSV );
is( $v1, "1 0 0.5", "$v1 setHSV" );
ok( $v eq $v1, "$v getHSV" );

#use Math::Rotation;
#my $r = new Math::Rotation(2,3,4,5);
#ok( $v = $r * $v1, "$v x ");

__END__
