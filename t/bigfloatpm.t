#!/usr/bin/perl -w

use Test;
use strict;

BEGIN
  {
  unshift @INC, '../lib';
  chdir 't' if -d 't';
  plan tests => 21;
  }

use Math::BigFloat;

# constructor
my $x = new Math::BigFloat ('1E1');

# sign
ok ($x->sign(),'+');
ok ($x->is_one(),'');
ok ($x,10);
ok ($x->bsstr(),'1E1');

$x = new Math::BigFloat ('13E0');
ok ($x,13);
ok ($x->bsstr(),'13E0');

$x = new Math::BigFloat ('1234E-3');
ok ($x,1.234);
ok ($x->bsstr(),'1234E-3');

$x = new Math::BigFloat ('1.234');
ok ($x,1.234);
ok ($x->bsstr(),'1234E-3');

$x = $x + '1.23';
ok ($x,2.464);
ok ($x->bsstr(),'2464E-3');

###############################################################################
# cmp

$x = new Math::BigFloat ('1E1');
ok ($x == 10,1);

###############################################################################
# add

$x = new Math::BigFloat ('1E1'); $x += new Math::BigFloat ('2E1');
ok ($x,"30");
$x = new Math::BigFloat ('1E0'); $x += new Math::BigFloat ('2E1');
ok ($x,21);

###############################################################################
# mul

$x = new Math::BigFloat ('1E1'); $x *= new Math::BigFloat ('2E1');
ok ($x,"200");
$x = new Math::BigFloat ('1E0'); $x *= new Math::BigFloat ('2E1');
ok ($x,"20");
$x = new Math::BigFloat ('-1E0'); $x *= new Math::BigFloat ('2E1');
ok ($x,"-20");
$x = Math::BigFloat->new ('-1E0'); $x *= Math::BigFloat->new ('-2E1');
ok ($x,"20");

###############################################################################
# test AUTOLOAD

my $try = '$x = Math::BigFloat->new ("3E0"); $x->fadd(5); $x->fadd(5); "$x";';
my $ans = eval $try;
ok ($ans,13);

$try = '$x = new Math::BigFloat ("3E0"); $x->fadd(5); "$x";';
$ans = eval $try;
ok ($ans,8);

# all done

