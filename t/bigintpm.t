#!/usr/bin/perl -w

use strict;
use Test;

BEGIN 
  {
  chdir 't' if -d 't';
  unshift @INC, '../lib';
  $| = 1;
  plan tests => 430;
  }

use Math::BigInt;

my (@args,$f,$try,$x,$y,$z,$a,$exp,$ans,$ans1,@a);

while (<DATA>) 
  {
  chop;
  if (s/^&//) 
    {
    $f = $_;
    }
  else 
    {
    @args = split(/:/,$_,99);
    $ans = pop(@args);
    $try = "\$x = Math::BigInt->new(\"$args[0]\");";
    if ($f eq "bnorm"){
      $try .= '$x+0;';
    } elsif ($f eq "bneg") {
      $try .= '-$x;';
    } elsif ($f eq "babs") {
      $try .= 'abs $x;';
    } elsif ($f eq "binc") {
      $try .= '++$x;'; 
    } elsif ($f eq "bdec") {
      $try .= '--$x;'; 
    }elsif ($f eq "bnot") {
      $try .= '~$x;';
    } else {
      $try .= "\$y = new Math::BigInt \"$args[1]\";";
      if ($f eq "bcmp"){
        $try .= '$x <=> $y;';
      }elsif ($f eq "bacmp"){
        $try .= '$x->bacmp($y);';
      }elsif ($f eq "badd"){
        $try .= "\$x + \$y;";
      }elsif ($f eq "bsub"){
        $try .= "\$x - \$y;";
      }elsif ($f eq "bmul"){
        $try .= "\$x * \$y;";
      }elsif ($f eq "bdiv"){
        $try .= "\$x / \$y;";
      }elsif ($f eq "bmod"){
        $try .= "\$x % \$y;";
      }elsif ($f eq "bgcd")
        {
        if (defined $args[2])
          {
          $try .= " \$z = new Math::BigInt \"$args[2]\"; ";
          }
        $try .= "Math::BigInt::bgcd(\$x, \$y";
        $try .= ", \$z" if (defined $args[2]);
        $try .= " );";
        }
      elsif ($f eq "blcm")
        {
        if (defined $args[2])
          {
          $try .= " \$z = new Math::BigInt \"$args[2]\"; ";
          }
        $try .= "Math::BigInt::blcm(\$x, \$y";
        $try .= ", \$z" if (defined $args[2]);
        $try .= " );";
      }elsif ($f eq "blsft"){
        $try .= "\$x << \$y;";
      }elsif ($f eq "brsft"){
        $try .= "\$x >> \$y;";
      }elsif ($f eq "band"){
        $try .= "\$x & \$y;";
      }elsif ($f eq "bior"){
        $try .= "\$x | \$y;";
      }elsif ($f eq "bxor"){
        $try .= "\$x ^ \$y;";
      }elsif ($f eq "bpow"){
        $try .= "\$x ** \$y;";
      } else { warn "Unknown op '$f'"; }
    }
    # remove leading #, thats easier than to edit all instances
    # change necc. due to bstr() dropping leading '+' now
    $ans =~ s/^\+//;
    $ans1 = eval $try;
    if ($ans eq "")
      {
      ok_undef ($ans1); 
      }
    else
      {
      print "# Tried: '$try'\n" if !ok ($ans1, $ans);
      }
    }
  } # endwhile data tests
close DATA;

# test wether constant works or not
$try = "use Math::BigInt ':constant';";
$try .= ' $x = 2**150; $x = "$x";';
$ans1 = eval $try;

ok ( $ans1, "1427247692705959881058285969449495136382746624");

# test some more
@a = ();
for (my $i = 1; $i < 10; $i++) 
  {
  push @a, $i;
  }
ok "@a", "1 2 3 4 5 6 7 8 9";

# test wether selfmultiplication works correctly (result is 2**64)
$try = '$x = new Math::BigInt "+4294967296";';
$try .= '$a = $x->bmul($x);';
$ans1 = eval $try;
print "# Tried: '$try'\n" if !ok ($ans1, Math::BigInt->new(2) ** 64);

# test wether op detroys args or not (should better not)

$x = new Math::BigInt (3);
$y = new Math::BigInt (4);
$z = $x & $y;
ok ($x,3);
ok ($y,4);
ok ($z,0);
$z = $x | $y;
ok ($x,3);
ok ($y,4);
ok ($z,7);
$x = new Math::BigInt (1);
$y = new Math::BigInt (2);
$z = $x | $y;
ok ($x,1);
ok ($y,2);
ok ($z,3);

$x = new Math::BigInt (5);
$y = new Math::BigInt (4);
$z = $x ^ $y;
ok ($x,5);
ok ($y,4);
ok ($z,1);

$x = new Math::BigInt (-5); $y = -$x;
ok ($x, -5);

$x = new Math::BigInt (-5); $y = abs($x);
ok ($x, -5);

# check wether overloading cmp works
$try = "\$x = Math::BigInt->new(0);";
$try .= "\$y = 10;";
$try .= "'false' if \$x ne \$y;";
$ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "false" ); 

# we cant test for working cmpt with other objects here, we would need a dummy
# object with stringify overload for this. see Math::String tests

###############################################################################
# check shortcuts
$try = "\$x = Math::BigInt->new(1); \$x += 9;";
$try .= "'ok' if \$x == 10;";
$ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->new(1); \$x -= 9;";
$try .= "'ok' if \$x == -8;";
$ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->new(1); \$x *= 9;";
$try .= "'ok' if \$x == 9;";
$ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->new(10); \$x /= 2;";
$try .= "'ok' if \$x == 5;";
$ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

###############################################################################
# check reversed order of arguments
$try = "\$x = Math::BigInt->new(10); \$x = 2 ** \$x;";
$try .= "'ok' if \$x == 1024;"; $ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->new(10); \$x = 2 * \$x;";
$try .= "'ok' if \$x == 20;"; $ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->new(10); \$x = 2 + \$x;";
$try .= "'ok' if \$x == 12;"; $ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->new(10); \$x = 2 - \$x;";
$try .= "'ok' if \$x == -8;"; $ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->new(10); \$x = 20 / \$x;";
$try .= "'ok' if \$x == 2;"; $ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

###############################################################################
# check badd(4,5) form

$try = "\$x = Math::BigInt::badd(4,5);";
$try .= "'ok' if \$x == 9;";
$ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

$try = "\$x = Math::BigInt->badd(4,5);";
$try .= "'ok' if \$x == 9;";
$ans = eval $try;
print "# For '$try'\n" if (!ok "$ans" , "ok" ); 

###############################################################################
# check proper length of internal arrays

$x = Math::BigInt->new(99999); 
ok ($x,99999);
ok (scalar @{$x->{value}}, 1);
$x += 1;
ok ($x,100000);
ok (scalar @{$x->{value}}, 2);
$x -= 1;
ok ($x,99999);
ok (scalar @{$x->{value}}, 1);

###############################################################################
# check int-form of internal arrays (not done yet todo )

###############################################################################
# check numify

my $BASE = int(1e5);
$x = Math::BigInt->new($BASE-1);     ok ($x->numify(),$BASE-1); 
$x = Math::BigInt->new(-($BASE-1));  ok ($x->numify(),-($BASE-1)); 
$x = Math::BigInt->new($BASE);       ok ($x->numify(),$BASE); 
$x = Math::BigInt->new(-$BASE);      ok ($x->numify(),-$BASE);
$x = Math::BigInt->new( -($BASE*$BASE*1+$BASE*1+1) ); 
ok($x->numify(),-($BASE*$BASE*1+$BASE*1+1)); 

###############################################################################
# check bug in _digits with length($c[-1]) where C[-1] was "00001" instead of 1

$x = Math::BigInt->new(99998); $x++; $x++; $x++; $x++;
if ($x > 100000) { ok (1,1) } else { ok ("$x < 100000","$x > 100000"); }

$x = Math::BigInt->new(100003); $x++;
$y = Math::BigInt->new(1000000);
if ($x < 1000000) { ok (1,1) } else { ok ("$x > 1000000","$x < 1000000"); }

###############################################################################
#  bug in sub where number with at least 6 trailing zeros after any op failed

$x = Math::BigInt->new(123456); $z = Math::BigInt->new(10000); $z *= 10;
$x -= $z;
ok ($z, 100000);
ok ($x, 23456);

###############################################################################
# check what if undefs

###############################################################################
# bool

$x = Math::BigInt->new(1); if ($x) { ok (1,1); } else { ok($x,'to be true') }
$x = Math::BigInt->new(0); if (!$x) { ok (1,1); } else { ok($x,'to be false') }

###############################################################################
# objectify()

@args = Math::BigInt::objectify(2,4,5);
ok (scalar @args,3);		# 'Math::BigInt', 4, 5
ok ($args[0],'Math::BigInt');
ok ($args[1],4);
ok ($args[2],5);

@args = Math::BigInt::objectify(0,4,5);
ok (scalar @args,3);		# 'Math::BigInt', 4, 5
ok ($args[0],'Math::BigInt');
ok ($args[1],4);
ok ($args[2],5);

@args = Math::BigInt::objectify(2,4,5);
ok (scalar @args,3);		# 'Math::BigInt', 4, 5
ok ($args[0],'Math::BigInt');
ok ($args[1],4);
ok ($args[2],5);

###############################################################################
# test for flaoting-point input

$y = '1050000000000000';
$x = Math::BigInt->new($y);
ok ($x,$y);

$z = 1050000000000000;          # may pass on systems with 64bit regardless?
$x = Math::BigInt->new($z);
ok ($x,$y);

$y = "1.01E2";   $x = Math::BigInt->new($y);
ok ($x,101);

$y = "1010E-1";  $x = Math::BigInt->new($y);
ok ($x,101);

$y = "-1010E0";  $x = Math::BigInt->new($y);
ok ($x,-1010);

$y = "-1010E1";  $x = Math::BigInt->new($y);
ok ($x,-10100);

$y = "-1010E-2"; $x = Math::BigInt->new($y);    # cant strip that many zeros
ok ($x,'NaN');

$y = "-1.01E+1"; $x = Math::BigInt->new($y);    # e not high enough
ok ($x,'NaN');

$y = "-1.01E-1"; $x = Math::BigInt->new($y);    # uh-oh, fract AND negative e
ok ($x,'NaN');
 
###############################################################################
# prime number tests, also test for **= and length()
# found on: http://www.utm.edu/research/primes/notes/by_year.html

# ((2^148)-1)/17
$x = Math::BigInt->new(2); $x **= 148; $x++; $x = $x / 17;
ok ($x,"20988936657440586486151264256610222593863921");
ok ($x->length(),length "20988936657440586486151264256610222593863921");

# MM7 = 2^127-1
$x = Math::BigInt->new(2); $x **= 127; $x--;
ok ($x,"170141183460469231731687303715884105727");

# I am afraid the following is not yet possible due to slowness
# Also, testing for 2 meg output is a bit hard ;)
#$x = new Math::BigInt(2); $x **= 6972593; $x--;

# 593573509*2^332162+1 has exactly 100.000 digits
# takes over 16 mins and still not complete, so can not be done yet ;)
#$x = Math::BigInt->new(2); $x **= 332162; $x *= "593573509"; $x++;
#ok ($x->digits(),100000);

###############################################################################
# all done

###############################################################################
# Perl 5.005 does not like ok ($x,undef)

sub ok_undef
  {
  my $x = shift;

  ok (1,1) and return if !defined $x;
  ok ($x,'undef');
  }

__END__
&bnorm
:NaN
abc:NaN
   1 a:NaN
1bcd2:NaN
11111b:NaN
+1z:NaN
-1z:NaN
0:+0
+0:+0
+00:+0
+0 0 0:+0
000000  0000000   00000:+0
-0:+0
-0000:+0
+1:+1
+01:+1
+001:+1
+00000100000:+100000
123456789:+123456789
-1:-1
-01:-1
-001:-1
-123456789:-123456789
-00000100000:-100000
&bneg
abd:NaN
+0:+0
+1:-1
-1:+1
+123456789:-123456789
-123456789:+123456789
&babs
abc:NaN
+0:+0
+1:+1
-1:+1
+123456789:+123456789
-123456789:+123456789
&bcmp
abc:abc:
abc:+0:
+0:abc:
+0:+0:0
-1:+0:-1
+0:-1:1
+1:+0:1
+0:+1:-1
-1:+1:-1
+1:-1:1
-1:-1:0
+1:+1:0
+123:+123:0
+123:+12:1
+12:+123:-1
-123:-123:0
-123:-12:-1
-12:-123:1
+123:+124:-1
+124:+123:1
-123:-124:1
-124:-123:-1
+100:+5:1
-123456789:+987654321:-1
+123456789:-987654321:1
-987654321:+123456789:-1
&bacmp
+0:-0:0
+0:+1:-1
-1:+1:0
+1:-1:0
-1:+2:-1
+2:-1:1
-123456789:+987654321:-1
+123456789:-987654321:-1
-987654321:+123456789:1
&binc
abc:NaN
+0:+1
+1:+2
-1:+0
&bdec
abc:NaN
+0:-1
+1:+0
-1:-2
&badd
abc:abc:NaN
abc:+0:NaN
+0:abc:NaN
+0:+0:+0
+1:+0:+1
+0:+1:+1
+1:+1:+2
-1:+0:-1
+0:-1:-1
-1:-1:-2
-1:+1:+0
+1:-1:+0
+9:+1:+10
+99:+1:+100
+999:+1:+1000
+9999:+1:+10000
+99999:+1:+100000
+999999:+1:+1000000
+9999999:+1:+10000000
+99999999:+1:+100000000
+999999999:+1:+1000000000
+9999999999:+1:+10000000000
+99999999999:+1:+100000000000
+10:-1:+9
+100:-1:+99
+1000:-1:+999
+10000:-1:+9999
+100000:-1:+99999
+1000000:-1:+999999
+10000000:-1:+9999999
+100000000:-1:+99999999
+1000000000:-1:+999999999
+10000000000:-1:+9999999999
+123456789:+987654321:+1111111110
-123456789:+987654321:+864197532
-123456789:-987654321:-1111111110
+123456789:-987654321:-864197532
&bsub
abc:abc:NaN
abc:+0:NaN
+0:abc:NaN
+0:+0:+0
+1:+0:+1
+0:+1:-1
+1:+1:+0
-1:+0:-1
+0:-1:+1
-1:-1:+0
-1:+1:-2
+1:-1:+2
+9:+1:+8
+99:+1:+98
+999:+1:+998
+9999:+1:+9998
+99999:+1:+99998
+999999:+1:+999998
+9999999:+1:+9999998
+99999999:+1:+99999998
+999999999:+1:+999999998
+9999999999:+1:+9999999998
+99999999999:+1:+99999999998
+10:-1:+11
+100:-1:+101
+1000:-1:+1001
+10000:-1:+10001
+100000:-1:+100001
+1000000:-1:+1000001
+10000000:-1:+10000001
+100000000:-1:+100000001
+1000000000:-1:+1000000001
+10000000000:-1:+10000000001
+123456789:+987654321:-864197532
-123456789:+987654321:-1111111110
-123456789:-987654321:+864197532
+123456789:-987654321:+1111111110
&bmul
abc:abc:NaN
abc:+0:NaN
+0:abc:NaN
+0:+0:+0
+0:+1:+0
+1:+0:+0
+0:-1:+0
-1:+0:+0
+123456789123456789:+0:+0
+0:+123456789123456789:+0
-1:-1:+1
-1:+1:-1
+1:-1:-1
+1:+1:+1
+2:+3:+6
-2:+3:-6
+2:-3:-6
-2:-3:+6
+111:+111:+12321
+10101:+10101:+102030201
+1001001:+1001001:+1002003002001
+100010001:+100010001:+10002000300020001
+10000100001:+10000100001:+100002000030000200001
+11111111111:+9:+99999999999
+22222222222:+9:+199999999998
+33333333333:+9:+299999999997
+44444444444:+9:+399999999996
+55555555555:+9:+499999999995
+66666666666:+9:+599999999994
+77777777777:+9:+699999999993
+88888888888:+9:+799999999992
+99999999999:+9:+899999999991
+25:+25:+625
+12345:+12345:+152399025
+99999:+11111:+1111088889
&bdiv
abc:abc:NaN
abc:+1:abc:NaN
+1:abc:NaN
+0:+0:NaN
+0:+1:+0
+1:+0:NaN
+0:-1:+0
-1:+0:NaN
+1:+1:+1
-1:-1:+1
+1:-1:-1
-1:+1:-1
+1:+2:+0
+2:+1:+2
+1:+26:+0
+1000000000:+9:+111111111
+2000000000:+9:+222222222
+3000000000:+9:+333333333
+4000000000:+9:+444444444
+5000000000:+9:+555555555
+6000000000:+9:+666666666
+7000000000:+9:+777777777
+8000000000:+9:+888888888
+9000000000:+9:+1000000000
+35500000:+113:+314159
+71000000:+226:+314159
+106500000:+339:+314159
+1000000000:+3:+333333333
+10:+5:+2
+100:+4:+25
+1000:+8:+125
+10000:+16:+625
+999999999999:+9:+111111111111
+999999999999:+99:+10101010101
+999999999999:+999:+1001001001
+999999999999:+9999:+100010001
+999999999999999:+99999:+10000100001
+1111088889:+99999:+11111
-5:-3:1
4:3:1
1:3:0
-2:-3:0
-2:3:-1
1:-3:-1
-5:3:-2
4:-3:-2
&bmod
abc:abc:NaN
abc:+1:abc:NaN
+1:abc:NaN
+0:+0:NaN
+0:+1:+0
+1:+0:NaN
+0:-1:+0
-1:+0:NaN
+1:+1:+0
-1:-1:+0
+1:-1:+0
-1:+1:+0
+1:+2:+1
+2:+1:+0
+1000000000:+9:+1
+2000000000:+9:+2
+3000000000:+9:+3
+4000000000:+9:+4
+5000000000:+9:+5
+6000000000:+9:+6
+7000000000:+9:+7
+8000000000:+9:+8
+9000000000:+9:+0
+35500000:+113:+33
+71000000:+226:+66
+106500000:+339:+99
+1000000000:+3:+1
+10:+5:+0
+100:+4:+0
+1000:+8:+0
+10000:+16:+0
+999999999999:+9:+0
+999999999999:+99:+0
+999999999999:+999:+0
+999999999999:+9999:+0
+999999999999999:+99999:+0
-9:+5:+1
+9:-5:-1
-9:-5:-4
-5:3:1
-2:3:1
4:3:1
1:3:1
-5:-3:-2
-2:-3:-2
4:-3:-2
1:-3:-2
&bgcd
abc:abc:NaN
abc:+0:NaN
+0:abc:NaN
+0:+0:+0
+0:+1:+1
+1:+0:+1
+1:+1:+1
+2:+3:+1
+3:+2:+1
-3:+2:+1
+100:+625:+25
+4096:+81:+1
+1034:+804:+2
+27:+90:+56:+1
+27:+90:+54:+9
&blcm
abc:abc:NaN
abc:+0:NaN
+0:abc:NaN
+0:+0:NaN
+1:+0:+0
+0:+1:+0
+27:+90:+270
+1034:+804:+415668
&blsft
abc:abc:NaN
+2:+2:+8
+1:+32:+4294967296
+1:+48:+281474976710656
+8:-2:NaN
&brsft
abc:abc:NaN
+8:+2:+2
+4294967296:+32:+1
+281474976710656:+48:+1
+2:-2:NaN
&band
abc:abc:NaN
+8:+2:+0
+281474976710656:+0:+0
+281474976710656:+1:+0
+281474976710656:+281474976710656:+281474976710656
&bior
abc:abc:NaN
+8:+2:+10
+281474976710656:+0:+281474976710656
+281474976710656:+1:+281474976710657
+281474976710656:+281474976710656:+281474976710656
&bxor
abc:abc:NaN
+8:+2:+10
+281474976710656:+0:+281474976710656
+281474976710656:+1:+281474976710657
+281474976710656:+281474976710656:+0
&bnot
abc:NaN
+0:-1
+8:-9
+281474976710656:-281474976710657
&bpow
0:+0:+1
0:+1:+0
0:+2:+0
0:-1:NaN
+1:0:+1
+1:+2:+1
+1:+3:+1
+1:-1:+1
2:0:+1
2:1:+2
2:2:+4
2:3:+8
3:3:+27
2:-1:NaN
-1:+2:+1
-1:+3:-1
-1:+4:+1
-1:+5:-1
10:2:+100
10:3:+1000
10:4:+10000
10:5:+100000
10:6:+1000000
10:7:+10000000
10:8:+100000000
10:9:+1000000000
10:20:+100000000000000000000
