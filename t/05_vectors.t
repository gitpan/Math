#!/usr/bin/perl -w
use Test::More tests => 8;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
	use_ok('Math::Vectors');
}

is (new Math::Color, "0 0 0");
is (new Math::ColorRGBA, "0 0 0 0");
is (new Math::Image, "0 0 0");
is (new Math::Rotation, "0 0 1 0");
is (new Math::Vec2, "0 0");
is (new Math::Vec3, "0 0 0");
is (new Math::Vec4, "0 0 0 0");

1;
__END__
