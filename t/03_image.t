#!/usr/bin/perl -w
use Test::More tests => 4;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
	use_ok('Math::Image');
}

my ( $v, $v1, $v2 );

is( $v = new Math::Image(), "0 0 0", "$v new Math::Image()" );
is( $v = new Math::Image( 2, 2, 4, [ 0xABCDEFAB, 0xABCDEFAB, 0xABCDEABF, 0xABCDABEF ] ), "2 2 4
0xabcdefab 0xabcdefab
0xabcdeabf 0xabcdabef", "new Math::Image()" );
printf "%s\n", $v;
is( $v->copy, "2 2 4
0xabcdefab 0xabcdefab
0xabcdeabf 0xabcdabef", "new Math::Image()" );

__END__
