#!/usr/bin/perl -w

use Test;
use strict;

BEGIN
  {
  unshift @INC, '../lib';
  chdir 't' if -d 't';
  plan tests => 188;
  }

use Math::BigFloat;
use Math::BigInt;

my ($x,$y);

# constructor
$x = new Math::BigFloat ('1E1');
ok ($x,10);

# Tom's bstr() bug
$x = new Math::BigFloat ('1.209E-2');
ok ($x,0.01209);

$x = new Math::BigFloat ('1.209E+2');
ok ($x,120.9);

$x = new Math::BigFloat ('.2');      ok ($x,0.2);
$x = new Math::BigFloat ('-.2');     ok ($x,-0.2);
$x = new Math::BigFloat ('+.2');     ok ($x,+0.2);

$x = new Math::BigFloat ('1.209E0'); ok ($x,1.209);

$x = new Math::BigFloat ('1.E1');    ok ($x,10);

$x = new Math::BigFloat ('0.1_2');   ok ($x,0.12);
$x = new Math::BigFloat ('0.1_2_2'); ok ($x,0.122);

$x = new Math::BigFloat ('0.1__2');  ok ($x,'NaN');
$x = new Math::BigFloat ('0._1_2');  ok ($x,'NaN');
$x = new Math::BigFloat ('0_.1_2');  ok ($x,'NaN');
$x = new Math::BigFloat ('0.1_2_');  ok ($x,'NaN');
$x = new Math::BigFloat ('_0.1_2');  ok ($x,'NaN');
$x = new Math::BigFloat ('_0.1_2_'); ok ($x,'NaN');
$x = new Math::BigFloat ('E1');      ok ($x,'NaN');
$x = new Math::BigFloat ('.');       ok ($x,'NaN');
$x = new Math::BigFloat ('.E1');     ok ($x,'NaN');
$x = new Math::BigFloat ('+.E1');    ok ($x,'NaN');
$x = new Math::BigFloat ('-E-1');    ok ($x,'NaN');


###############################################################################
# round

$x = new Math::BigFloat ('1234567E-4'); ok ($x,'123.4567');
$y = $x->copy(); $y->ffround(2);  ok ($y,100);
$y = $x->copy(); $y->ffround(-2); ok ($y,123.46);
$y = $x->copy(); $y->fround(2);   ok ($y,120);

$x = new Math::BigFloat ('123456789E-3'); ok ($x,'123456.789');
$y = $x->copy(); $y->ffround(2);  ok ($y,123500);
$y = $x->copy(); $y->ffround(-2); ok ($y,123456.79);
$y = $x->copy(); $y->fround(2);   ok ($y,120000);

$x = new Math::BigFloat ('1234567890123456789E-13');
ok ($x,'123456.7890123456789');
$y = $x->copy(); $y->ffround(0);  ok ($y,'123457');
$y = $x->copy(); $y->ffround(1);  ok ($y,123460);
$y = $x->copy(); $y->ffround(2);  ok ($y,123500);
$y = $x->copy(); $y->ffround(3);  ok ($y,123000);
$y = $x->copy(); $y->ffround(-1); ok ($y,123456.8);
$y = $x->copy(); $y->ffround(-2); ok ($y,123456.79);
$y = $x->copy(); $y->ffround(-3); ok ($y,123456.789);
$y = $x->copy(); $y->fround(0);   ok ($y,'123456.7890123456789');
$y = $x->copy(); $y->fround(1);   ok ($y,100000);
$y = $x->copy(); $y->fround(2);   ok ($y,120000);
$y = $x->copy(); $y->fround(3);   ok ($y,123000);
$y = $x->copy(); $y->fround(4);   ok ($y,123500);
$y = $x->copy(); $y->fround(5);   ok ($y,123460);
$y = $x->copy(); $y->fround(6);   ok ($y,123457);
$y = $x->copy(); $y->fround(7);   ok ($y,123456.8);
$y = $x->copy(); $y->fround(20);  ok ($y,'123456.7890123456789');

$x = new Math::BigFloat ('0.01234567');
ok ($x,'0.01234567');
$y = $x->copy(); $y->ffround(2);   ok ($y,0);
$y = $x->copy(); $y->ffround(1);   ok ($y,0);
$y = $x->copy(); $y->ffround(0);   ok ($y,0);
$y = $x->copy(); $y->ffround(-2);  ok ($y,0.01);
$y = $x->copy(); $y->ffround(-3);  ok ($y,0.012);
$y = $x->copy(); $y->ffround(-4);  ok ($y,0.0123);
$y = $x->copy(); $y->ffround(-5);  ok ($y,0.01235);
$y = $x->copy(); $y->ffround(-6);  ok ($y,0.012346);
$y = $x->copy(); $y->ffround(-7);  ok ($y,0.0123457);
$y = $x->copy(); $y->ffround(-8);  ok ($y,0.01234567);
$y = $x->copy(); $y->ffround(-12); ok ($y,0.01234567);
$y = $x->copy(); $y->fround(0);   ok ($y,0.01234567);
$y = $x->copy(); $y->fround(1);   ok ($y,0.01);
$y = $x->copy(); $y->fround(2);   ok ($y,0.012);
$y = $x->copy(); $y->fround(3);   ok ($y,0.0123);

$x = new Math::BigFloat ('0.51'); ok ($x,'0.51');
$y = $x->copy(); $y->ffround(0);   ok ($y,1);

$x = new Math::BigFloat ('0.49'); ok ($x,'0.49');
$y = $x->copy(); $y->ffround(0);   ok ($y,0);

$x = new Math::BigFloat ('0.0001234567');
ok ($x,'0.0001234567');
$y = $x->copy(); $y->ffround(2);   ok ($y,0);
$y = $x->copy(); $y->ffround(1);   ok ($y,0);
$y = $x->copy(); $y->ffround(0);   ok ($y,0);

$x = new Math::BigFloat ('0.5'); ok ($x,'0.5');
$y = $x->copy(); $y->ffround(0,'even');   ok ($y,0);
$y = $x->copy(); $y->ffround(0,'odd');   ok ($y,1);

$x = new Math::BigFloat ('0.5000001'); ok ($x,'0.5000001');
$y = $x->copy(); $y->ffround(0,'even');   ok ($y,1);
$y = $x->copy(); $y->ffround(0,'odd');   ok ($y,1);

###############################################################################
# round_mode

foreach (qw/+inf -inf trunc zero odd even/)
   {
   ok (Math::BigFloat->round_mode($_),$_);
   ok (Math::BigFloat::round_mode($_),$_);
   Math::BigFloat::round_mode($_);
   ok ($Math::BigFloat::rnd_mode,$_);
   ok (Math::BigFloat::round_mode(),$_);
   }

###############################################################################
# sign & bsstr

$x = new Math::BigFloat ('1E1');
ok ($x->sign(),'+');
ok ($x->is_one(),'');
ok ($x,10);
ok ($x->bsstr(),'1e+1');

$x = new Math::BigFloat ('13E0');
ok ($x,13);
ok ($x->bsstr(),'13e+0');

$x = new Math::BigFloat ('1234E-3');
ok ($x,1.234);
ok ($x->bsstr(),'1234e-3');

$x = new Math::BigFloat ('1.234');
ok ($x,1.234);
ok ($x->bsstr(),'1234e-3');

$x = $x + '1.23';
ok ($x,2.464);
ok ($x->bsstr(),'2464e-3');

$x = new Math::BigFloat ('0.001');
ok ($x,'0.001');

$x = new Math::BigFloat ('-0.001');
ok ($x,'-0.001');

###############################################################################
# parts

$x = new Math::BigFloat ('-0.001');
ok ($x->exponent(),'-3');
ok ($x->mantissa(),'-1');

$x = new Math::BigFloat ('-0.0');
ok ($x,0);
ok ($x->exponent(),'1');
ok ($x->mantissa(),'0');

$x = new Math::BigFloat ('10');
ok ($x->exponent(),'1');
ok ($x->mantissa(),'1');

$x = new Math::BigFloat ('100');
ok ($x->exponent(),'2');
ok ($x->mantissa(),'1');

$x = new Math::BigFloat ('-100');
ok ($x->exponent(),'2');
ok ($x->mantissa(),'-1');

$x = new Math::BigFloat ('-100.345');
ok ($x->exponent(),'-3');
ok ($x->mantissa(),'-100345');

$x = new Math::BigFloat ('-100.345');
ok (ref $x->exponent(),'Math::BigInt');
ok (ref $x->mantissa(),'Math::BigInt');
my ($m,$e) = $x->parts();
ok (ref $m,'Math::BigInt');
ok (ref $e,'Math::BigInt');

###############################################################################
# test wether parts are equal when BigInt is equal to BigFloat 

foreach (qw/ 1 -1 100 123 -123 0 100000000 abc/)
  {
  $x = new Math::BigFloat ($_); $y = new Math::BigInt ($_);
  my ($mx,$ex) = $x->parts();
  my ($my,$ey) = $x->parts();
  ok ($mx,$my);
  ok ($ex,$ey);
  }

###############################################################################
# length

$x = new Math::BigFloat ('1E1');
ok ($x->length(),2);
my ($l,$f) = $x->length();
ok ($l,2); ok ($f,0);

$x = new Math::BigFloat ('1E2');
ok ($x->length(),3);
($l,$f) = $x->length();
ok ($l,3); ok ($f,0);

$x = new Math::BigFloat ('12345E-2');
ok ($x->length(),5);
($l,$f) = $x->length();
ok ($l,5); ok ($f,2);

$x = new Math::BigFloat ('12345');
ok ($x->length(),5);
($l,$f) = $x->length();
ok ($l,5); ok ($f,0);

###############################################################################
# as_number

$x = new Math::BigFloat ('1E1'); $y = $x->as_number();
ok ($x,10); ok ($y,10); ok (ref($y),'Math::BigInt');
$x = new Math::BigFloat ('123'); $y = $x->as_number();
ok ($x,123); ok ($y,123); ok (ref($y),'Math::BigInt');
$x = new Math::BigFloat ('12345E-2'); $y = $x->as_number();
ok ($x,123.45); ok ($y,123); ok (ref($y),'Math::BigInt');

###############################################################################
# cmp

$x = new Math::BigFloat ('1E1');
ok ($x == 10,1);

$m = $x->mantissa();
$e = $x->exponent();
$y = $m * ( 10 ** $e );
# ok ($x == $y,1); # does not work yet
        
##############################################################################
# add/sub

$x = new Math::BigFloat ('1E1'); $x += new Math::BigFloat ('2E1');
ok ($x,"30");
$x = new Math::BigFloat ('1E0'); $x += new Math::BigFloat ('2E1');
ok ($x,21);

$x = new Math::BigFloat ('8'); $x -= 5; ok ($x,3);
$x = new Math::BigFloat ('1234567890'); $x -= 1234567891; ok ($x,-1);
$x = new Math::BigFloat ('123'); $x += -120; ok ($x,3);

$x = new Math::BigFloat ('123'); $x++; ok ($x,124); $x--; ok ($x,123);

###############################################################################
# div

$x = new Math::BigFloat ('1'); $x /= 1;	  ok ($x,1);
$x = new Math::BigFloat ('-1'); $x /= 1;  ok ($x,-1); 
$x = new Math::BigFloat ('1'); $x /= -1;  ok ($x,-1);
$x = new Math::BigFloat ('-1'); $x /= -1; ok ($x,1);

$x = new Math::BigFloat ('100'); $x /= 500; ok ($x,0.2);

$x = new Math::BigFloat ('2'); $x /= 1.25; ok ($x,1.6);
#$x = new Math::BigFloat ('963'); $x->bdiv(1212.37848,10); ok ($x,0.7943064641);

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

###############################################################################
# sqrt

#$x = Math::BigFloat->new(144); ok ($x->fsqrt(20),12);
#$x = Math::BigFloat->new(2); ok ($x->fsqrt(20),1.4142);
#exit;

#$x = Math::BigFloat->new(123456)*123456; ok ($x->fsqrt(120),123456);
#$x = Math::BigFloat->new(0.5); ok ($x->fsqrt(45),'0.7071067811865475244008443621048490392848');
#$x = Math::BigFloat->new(0.25); ok ($x->fsqrt(4),'0.5');

###############################################################################
# version, :constant

# test whether constant works or not
#$try = "use Math::BigFloat (1.10,'badd',':constant');";
#$try .= ' $x = 1.0 * 123456789012345678901234567890.0; $x = "$x".".0";';
#$x = eval $try;
#ok ( $x, "123456789012345678901234567890.0"); 

#$try = "use Math::BigFloat (1.10,'badd');";
#$try .= ' $x = badd(-1.0,2.0);';
#$x = eval $try;
#ok ($x,1.0);

# all done

