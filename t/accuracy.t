#!/usr/bin/perl -w

# test accuracy, precicion and fallback, round_mode

use strict;
use Test;

BEGIN 
  {
  $| = 1;
  chdir 't' if -d 't';
  unshift @INC, '../lib';
  plan tests => 86;
  }

use Math::BigInt;
use Math::BigFloat;

my ($x,$y,$z);

###############################################################################
# test defaults and set/get

ok_undef ($Math::BigInt::accuracy);
ok_undef ($Math::BigInt::precision);
ok ($Math::BigInt::div_scale,40);
ok (Math::BigInt::round_mode(),'even');
ok ($Math::BigInt::rnd_mode,'even');

ok_undef ($Math::BigFloat::accuracy);
ok_undef ($Math::BigFloat::precision);
ok ($Math::BigFloat::div_scale,40);
ok ($Math::BigFloat::rnd_mode,'even');

# accuracy
foreach (qw/5 42 -1 0/)
  {
  ok ($Math::BigFloat::accuracy = $_,$_);
  ok ($Math::BigInt::accuracy = $_,$_);
  }
ok_undef ($Math::BigFloat::accuracy = undef);
ok_undef ($Math::BigInt::accuracy = undef);

# precision
foreach (qw/5 42 -1 0/)
  {
  ok ($Math::BigFloat::precision = $_,$_);
  ok ($Math::BigInt::precision = $_,$_);
  }
ok_undef ($Math::BigFloat::precision = undef);
ok_undef ($Math::BigInt::precision = undef);

# fallback
foreach (qw/5 42 1/)
  {
  ok ($Math::BigFloat::div_scale = $_,$_);
  ok ($Math::BigInt::div_scale = $_,$_);
  }
# illegal values are possible for fallback due to no accessor

# round_mode
foreach (qw/odd even zero trunc +inf -inf/)
  {
  ok ($Math::BigFloat::rnd_mode = $_,$_);
  ok ($Math::BigInt::rnd_mode = $_,$_);
  }
$Math::BigFloat::rnd_mode = 4;
ok ($Math::BigFloat::rnd_mode,4);
ok ($Math::BigInt::rnd_mode,'-inf');	# from above


# local copies
$x = Math::BigFloat->new(123.456);
ok_undef ($x->accuracy());
ok ($x->accuracy(5),5);
ok_undef ($x->accuracy(undef),undef);
ok_undef ($x->precision());
ok ($x->precision(5),5);
ok_undef ($x->precision(undef),undef);

# see if MBF changes MBIs values
ok ($Math::BigInt::accuracy = 42,42);
ok ($Math::BigFloat::accuracy = 64,64);
ok ($Math::BigInt::accuracy,42);		# should be still 42
ok ($Math::BigFloat::accuracy,64);		# should be still 64

###############################################################################
# see if setting accuracy/precision actually rounds the number

$x = Math::BigFloat->new(123.456); $x->accuracy(4);   ok ($x,123.5);
$x = Math::BigFloat->new(123.456); $x->precision(-2); ok ($x,123.46);

$x = Math::BigInt->new(123456);    $x->accuracy(4);   ok ($x,123500);
$x = Math::BigInt->new(123456);    $x->precision(2);  ok ($x,123500);

###############################################################################
# test actual rounding via round()

$x = Math::BigFloat->new(123.456);
ok ($x->copy()->round(5,2),123.46);
ok ($x->copy()->round(4,2),123.5);
ok ($x->copy()->round(undef,-2),123.46);
ok ($x->copy()->round(undef,2),100);

$x = Math::BigFloat->new(123.45000);
ok ($x->copy()->round(undef,-1,'odd'),123.5);

# see if rounding is 'sticky'
$x = Math::BigFloat->new(123.4567);
$y = $x->copy()->bround();		# no-op since nowhere A or P defined

ok ($y,123.4567);			
$y = $x->copy()->round(5,2);
ok ($y->accuracy(),5);
ok_undef ($y->precision());		# A has precedence, so P still unset
$y = $x->copy()->round(undef,2);
ok ($y->precision(),2);
ok_undef ($y->accuracy());		# P has precedence, so A still unset

# does copy work?
$x = Math::BigFloat->new(123.456); $x->accuracy(4); $x->precision(2);
$z = $x->copy(); ok ($z->accuracy(),4); ok ($z->precision(),2);

###############################################################################
# test wether operations round properly afterwards
# These tests are not complete, since they do not excercise every "return"
# statement in the op's. But heh, it's better than nothing...

$x = Math::BigFloat->new(123.456);
$y = Math::BigFloat->new(654.321);
$x->{_a} = 5;		# $x->accuracy(5) would round $x straightaway
$y->{_a} = 4;		# $y->accuracy(4) would round $x straightaway

$z = $x + $y;		ok ($z,777.8);
$z = $y - $x;		ok ($z,530.9);
$z = $y * $x;		ok ($z,80780);
$z = $x ** 2;		ok ($z,15241);
$z = $x * $x;		ok ($z,15241);
# not yet: $z = -$x;		ok ($z,-123.46); ok ($x,123.456);
$x = Math::BigFloat->new(123456); $x->{_a} = 4;
$z = $x->copy; $z++;	ok ($z,123500);

$x = Math::BigInt->new(123456);
$y = Math::BigInt->new(654321);
$x->{_a} = 5;		# $x->accuracy(5) would round $x straightaway
$y->{_a} = 4;		# $y->accuracy(4) would round $x straightaway

$z = $x + $y; 		ok ($z,777800);
$z = $y - $x; 		ok ($z,530900);
$z = $y * $x;		ok ($z,80780000000);
$z = $x ** 2;		ok ($z,15241000000);
# mot yet: $z = -$x;		ok ($z,-123460); ok ($x,123456);
$z = $x->copy; $z++;	ok ($z,123460);

# all done

###############################################################################
# Perl 5.005 does not like ok ($x,undef)

sub ok_undef
  {
  my $x = shift;

  ok (1,1) and return if !defined $x;
  ok ($x,'undef');
  }
