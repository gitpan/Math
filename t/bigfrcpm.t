#!/usr/bin/perl -w

use Test;
use strict;

BEGIN
  {
  $| = 1;
  unshift @INC, '../lib';
  chdir 't' if -d 't';
  plan tests => 6;
  }

use Math::BigFraction;

# constructor
my $x = Math::BigFraction->new (1,1);
ok ($x, "1 / 1");

# sign
ok ($x->sign(),'+');
ok ($x->is_one(),1);

$x = Math::BigFraction->new (0);
ok ($x, "0 / 1");

$x = Math::BigFraction->new (1,3);
ok_undef ($x->is_one());
$x *= Math::BigFraction->new(5,7);
ok ($x,"5 / 21");

###############################################################################
# Perl 5.005 does not like ok ($x,undef)

sub ok_undef
  {
  my $x = shift;

  ok (1,1) and return if !defined $x;
  ok ($x,'undef');
  }
