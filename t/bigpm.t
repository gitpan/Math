#!/usr/bin/perl -w

use strict;
use Test;

BEGIN 
  {
  chdir 't' if -d 't';
  unshift @INC, '../lib';
  plan tests => 70;
  }

use Math::BigInt;
use Math::Big;

my (@args,$ref,$func,$argnum,$try,$x,$y,$z,$ans,@ans,$ans1);
$| = 1;
while (my $line = <DATA>) 
  {
  chop $line;
  if ($line =~ s/^&//) 
    {
    # format: '&subroutine:number_of_arguments
    ($func,$argnum) = split /:/,$line;
    $ref = 0; $ref = 1 if $func =~ s/_ref$//;
    }
  else 
    {
    @args = split(/:/,$line,99);

    #print "try @args\n";
    $try = '@ans = (); ';
    if ((@args == 2) || ($ref != 0))
      {
      $try .= '$ans[0]';
      }
    else
      {
      $try .= '@ans';
      }
    $try .= " = Math::Big::$func (";
    for (my $i = 0; $i < $argnum; $i++)
      {
      $try .= "'$args[$i]',";
      }
    $try .= ");"; 
    eval $try;
    splice @args,0,$argnum;
    $ans1 = ""; foreach (@args) { $ans1 .= " $_" }
    $ans = ""; 
    foreach my $c (@ans)
      {
      # functions that return an array ref
      if (ref($c) eq 'ARRAY')
        { 
        foreach my $h (@$c)
          {
          $ans .= " $h";
          }
        }
      else
        {
        $ans .= " $c";
        } 
      }
    print "# Tried: '$try'\n" if !ok ($ans,$ans1);
    }
  } # endwhile data tests
close DATA;

# all done

__END__
&fibonacci:1
0:1
1:1
2:2
3:3
4:5
5:8
3:1:1:2:3
4:1:1:2:3:5
5:1:1:2:3:5:8
6:1:1:2:3:5:8:13
7:1:1:2:3:5:8:13:21
8:1:1:2:3:5:8:13:21:34
9:55
10:89
11:144
12:233
13:377
14:610
&hailstone:1
1:1
2:2
4:3
8:4
5:6
5:5:16:8:4:2:1
6:9
6:6:3:10:5:16:8:4:2:1
&base:2
3:2:1:1
5:2:2:1
9:2:3:1
10:2:3:2
11:2:3:3
17:2:4:1
18:2:4:2
&factors:2
1:1:1
2:1:2
3:1:3
0:1:0
9:1:3:3
18:1:2:3:3
1:2:1
2:2:2
3:2:3
0:2:0
9:2:3:3
18:2:2:3:3
1:3:1
2:3:2
3:3:3
0:3:0
9:3:3:3
18:3:2:3:3
1:4:1
2:4:2
3:4:3
0:4:0
9:4:3:3
18:4:2:3:3
&wheel_ref:1
1:2:1
2:2:3:1:5
3:2:3:5:1:7:11:13:17:19:23:29
4:2:3:5:7:1:11:13:17:19:23:29:31:37:41:43:47:53:59:61:67:71:73:79:83:89:97:101:103:107:109:113:121:127:131:137:139:143:149:151:157:163:167:169:173:179:181:187:191:193:197:199:209
&primes:1
4:2:3
5:2:3:5
10:2:3:5:7
20:2:3:5:7:11:13:17:19
&factorial:1
1:1
2:2
3:6
10:3628800
13:6227020800
