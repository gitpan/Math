#!/usr/bin/perl -w

use Test;
use strict;

BEGIN
  {
  unshift @INC, '../lib';
  chdir 't' if -d 't';
  plan tests => 5;
  }

use Math::BigFloat;

# constructor
my $x = new Math::BigFloat ('1E1');

# sign
ok ($x->sign(),'+');
ok ($x->is_one(),'');
ok ($x,1E1);
# ok ($x == 10,1);	# does not work yet

# add
$x = new Math::BigFloat ('1E1'); $x += new Math::BigFloat ('2E1');
ok ($x,"3E1");
$x = new Math::BigFloat ('1E0'); $x += new Math::BigFloat ('2E1');
ok ($x,21);

exit;
# mul (does not work since cmp/acmp is not done yet)
$x = new Math::BigFloat ('1E1'); $x *= new Math::BigFloat ('2E1');
ok ($x,"2E2");
$x = new Math::BigFloat ('1E0'); $x *= new Math::BigFloat ('2E1');
ok ($x,"2E1");
$x = new Math::BigFloat ('-1E0'); $x *= new Math::BigFloat ('2E1');
ok ($x,"-2E1");
$x = new Math::BigFloat ('-1E0'); $x *= new Math::BigFloat ('-2E1');
ok ($x,"+2E1");

