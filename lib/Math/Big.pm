#!/usr/bin/perl -w

#############################################################################
# Math/Big.pm -- usefull routines with Big numbers (BigInt/BigFloat)
#
# Copyright (C) 2001 by Tels. All rights reserved.
#############################################################################

package Math::Big;
use vars qw($VERSION);
$VERSION = 1.03;    # Current version of this package
require  5.005;     # requires this Perl version or later

use Math::BigInt;
use Math::BigFloat;
use Exporter;
@ISA = qw( Exporter );
@EXPORT_OK = qw( primes fibonacci base hailstone factorial
               );
#@EXPORT = qw( );
use strict;

sub primes
  {
  my $amount = shift; $amount = 1000 if !defined $amount;
  $amount = Math::BigInt->new($amount) unless ref $amount;

  return (Math::BigInt->new(2)) if $amount < 3;
  
  $amount++;  

  # any not defined number is prime, 0,1 are not, but 2 is
  my @primes = (1,1,0); 
  my $prime = Math::BigInt->new (3);      # start
  my $r = 0; my $a = $amount->numify();
  for (my $i = 3; $i < $a; $i++)             # int version
    {
    $primes[$i] = $r; $r = 1-$r;
    }
  my ($cur,$add);
  # find primes
  OUTER:
  while ($prime <= $amount)
    {
    # find first unmarked, it is the next prime
    $cur = $prime;
    while ($primes[$cur])
      {
      $cur += 2; last OUTER if $cur >= $amount;   # no more to do
      }
    # $cur is now new prime
    # now strike out all multiples of $cur
    $add = $cur*2;
    $prime = $cur + 2;                    # next round start two higher
    $cur += $add;
    while ($cur <= $amount)
      {
      $primes[$cur] = 1; $cur += $add;
      }
    }
  my @real_primes; my $i = 0;
  while ($i < scalar @primes)
    {
    push @real_primes, Math::BigInt->new($i) if $primes[$i] == 0;
    $i ++;
    }
  return @real_primes;
  }
  
sub fibonacci
  {
  my $n = shift;
  $n = Math::BigInt->new($n) unless ref $n;

  return if $n->is_nan();
  return if $n->sign() eq '-';		# < 0
  #####################
  # list context
  if (wantarray)
    {
    my @fib = (Math::BigInt->new(1),Math::BigInt->new(1));	# 0 = 1, 1 = 1
    my $i = 2;							# no BigInt
    while ($i <= $n)
      {
      $fib[$i] = $fib[$i-1]+$fib[$i-2]; $i++;
      }
    return @fib;
    }
  #####################
  # scalar context
  my $x = Math::BigInt->new(1);
  return $x if $n < 2;
  my $t = $x; my $y = $x;
  my $i = Math::BigInt->new(2);
  while ($i <= $n)
    {
    $t = $x + $y; $x = $y; $y = $t; $i++;
    }
  return $t;
  }

sub base
  {
  my ($number,$base) = @_;

  $number = Math::BigInt->new($number) unless ref $number;
  $base = Math::BigInt->new($base) unless ref $base;

  return if $number < $base;
  my $n = Math::BigInt->new(0);
  my $trial = $base;
  # 9 = 2**3 + 1
  while ($trial < $number)
    {
    $trial *= $base; $n++;
    }
  $trial /= $base; $a = $number - $trial;
  return ($n,$a);
  }

sub hailstone
  {
  # return in list context the hailstone sequence, in scalar context the
  # number of steps to reach 1

  my ($n) = @_;

  $n = Math::BigInt->new($n) unless ref $n;
 
  return if $n->is_nan() || $n < 0;

  my $one = Math::BigInt->new(1);
  if (wantarray)
    {
    my @seq;
    while ($n != $one)
      {
      push @seq, $n;
      ($n->is_odd()) ? ($n = $n * 3 + 1) : ($n = $n / 2);
      }
    push @seq, Math::BigInt->new(1);
    return @seq;
    }
  else
    {
    my $i = Math::BigInt->new(1);
    while ($n != $one)
      {
      $i++;
      ($n->is_odd()) ? ($n = $n * 3 + 1) : ($n = $n / 2);
      }
    return $i;
    }
  }

sub wheel
  {
  # calculate a prime-wheel of order $o
  my $o = abs(shift || 1);              # >= 1

  # some primitive wheels as shortcut:
  return [ Math::BigInt->new(2), Math::BigInt->new(1) ] if $o == 1;

  my @primes = primes($o*5);            # initial primes (get more, roughly)

  my $mul = Math::BigInt->new(1); my @wheel;
  for (my $i = 0; $i < $o; $i++)
    {
    #print "$primes[$i]\n";
    $mul *= $primes[$i]; push @wheel,$primes[$i];
    }
  #print "Mul $mul\n";
  my $last = $wheel[-1];                        # get biggest initial
  #print "last is $last\n";
  # now sieve any number that is a multiply of one of the inital ones
  @primes = ();                                 # undef => leftover
  foreach (@wheel)
    {
    next if $_ == 2;                            # dont mark these, we skip 'em
    my $i = $_; my $add = $i;
    while ($i < $mul)
      {
      $primes[$i] = 1; $i += $add;
      }
    }
  push @wheel, Math::BigInt->new(1);
  my $i = $last;
  while ($i < $mul)
    {
    push @wheel,$i if !defined $primes[$i]; $i += 2;    # skip even ones
    }
  return \@wheel;
  }
 
sub transform_wheel
  {
  # from a given prime-wheel, calculate a increment table that can be used
  # to step trough numbers
  # input:  ref to array with prime wheel
  # output: ($restart,$ref_to_add_table);

  my (@wheel,$we);
  my $add = shift; shift @$add;         # remove the first 2 from wheel

  if (@$add == 1)                       # order 1
    {
    my $two = Math::BigInt->new(2);
    # (2,2) or (2,2,2,2,2,2) etc would do, too
    @wheel = ($two->copy(),$two->copy(),$two->copy(),$two->copy());
    return (1,\@wheel);
    }
  # from the list of divisors above create a add-table which we can take to
  # increment from 3 onwards. The tabe consists of two parts, the second part
  # will be repeatedly used
  my $last = -1; my $mod = 2; my $i = 0;
  # create the increment part for the initial primes (3,5, or 3,5,7 etc)
  while ($add->[$i] != 1)
    {
    $mod *= $add->[$i];
    push @wheel, $add->[$i] - $last if $last != -1;     # skip the first
    #print $wheel[-1],"\n" if $last != -1;
    $last = $add->[$i]; $i++;
    }
  #print "mod $mod\n";
  my $border = $i-1;                                    # account for ++
  my $length = scalar @$add-$i;
  my $ws = $border+$length;                             # remember this
  #print "border: $border length $length $mod\n";

  # now we add two arrays in a row, both are equal except the first element
  # which is in case A a step from the last inital prime to the second in list
  # and in case B a step from '1' to the second in list

  #print "add[border+1]: ",$add->[$border+1]," add[border] $add->[$border]\n";
  $wheel[$border] = $add->[$border+2]-$add->[$border];
  $wheel[$border+$length] = $add->[$border+2]-1;
  # and last add a wrap-around around $mod
  #print "last: ",$add->[-1],"\n";
  $wheel[$border+$length-1] = 1+$mod-$add->[-1];
  $wheel[$border+$length*2-1] = $wheel[$border+$length-1];
 
  $i = $border + 1;
  # now fill in the rest
  while ($i < $length+$border-1)
    {
    $wheel[$i] = $add->[$i+2]-$add->[$i+1];
    $wheel[$i+$length] = $wheel[$i];
    $i++;
    }
  return ($ws,\@wheel);
  }

sub factors
  {
  my $n = shift;
  my $o = abs(shift || 1);

  $n = Math::BigInt->new($n) unless ref $n;
  my $two = Math::BigInt->new(2);
  my $three = Math::BigInt->new(3);

  my @factors = ();
  my $x = $n->copy();

  return ($x) if $x < 4;
  my ($i,$y,$w,$div,$rem);

  #print "Using a wheel of order $o, length ";
  my $wheel = wheel($o);
  #print scalar @$wheel,":\n";
  my ($ws,$add) = transform_wheel($wheel); undef $wheel;
  my $we = scalar @$add - 1;

  # reduce to odd number (after that, no odd left-over divisior will ocur)
  while (($x->is_even) && (!$x->is_zero))
    {
    push @factors, $two->copy();
    #print "factoring $x (",$x->length(),")\n";
    #print "2\n";
    $x /= $two;
    }
  # 8 => 6 => 3, 7, 6 => 3, 5, 4 => 2 => 1, 3, 2 => 1, are all prime
  # so the first number interesting for us is 9
  my $op = 0;
 OUTER:
  while ($x > 8)
    {
    #print "factoring $x (",$x->length(),")\n";
    $i = $three; $w = 0;
    while ($i < $x)             # should be sqrt()
      {
      # $steps++;
      # $op = 0, print "$i\r" if $op++ == 1024;
      $y = $x->copy();
      ($div,$rem) = $y->bdiv($i);
      if ($rem == 0)
        {
        #print "$i\n";
        push @factors,$i;
        $x = $div; next OUTER;
        }
      #print "$i + ",$add->[$w]," ($w)\n";
      #$i += 2;                                   # trial div by odd numbers
      $i += $add->[$w];
      #print "restart $w $ws\n" if $w == $we;  # wheel of 2,3,5,7...
      $w = $ws if $w++ == $we;                  # wheel of 2,3,5,7...
      #exit if $i > 100000;
      }
    last;
    }
  push @factors,$x if $x != 1 || $n == 1;
  return @factors;
  }

sub factorial
  {
  # calculate n!, n is limited to a Perl floating point number
  # not a problem since n = 1e5 already takes too long...
  my ($n,$i) = shift;

  my $res = Math::BigInt->new(1);

  return $res if $n < 1;
  for ($i = 2; $i <= $n; $i++)
    {
    $res *= $i;
    }
  return $res;
  }
 
#############################################################################

=head1 NAME

Math::Big - usefull routines with Big numbers (BigInt/BigFloat)

=head1 SYNOPSIS

    use Math::Big qw/primes fibonacci hailstone factors wheel/;

    @primes	= primes(100);		# first 100 primes
    $prime	= primes(100);		# 100th prime
    @fib	= fibonacci (100);	# first 100 fibonacci numbers
    $fib_1000	= fibonacci (1000);	# 1000th fibonacci number
    $hailstone	= hailstone (1000);	# length of sequence
    @hailstone	= hailstone (127);	# the entire sequence
    
    $wheel	= wheel (4);		# prime number wheel of 2,3,5,7

    print $wheel->[0],$wheel->[1],$wheel->[2],$wheel->[3],"\n";

    # factor 19*71*59*3 into it's factors using a wheel of order 3
    @factors	= factors (19*71*59*3,3); 
    $fak        = fak(1000);		# faktorial 1000! 

=head1 REQUIRES

perl5.005, Exporter, Math::BigInt, Math::BigFloat

=head1 EXPORTS

Exports nothing on default, but can export C<primes()>, C<fibonacci()>,
C<hailstone()> and C<factorial>.

=head1 DESCRIPTION

This module contains some routines that may come in handy when you want to
do some math with really really big numbers. These are primarily examples.

=head1 METHODS

=head2 B<primes()>

	@primes = primes($n);
	$prime  = primes($n);

Calculates the first N primes and returns them as array.
In scalar context returns the Nth prime.
  
This uses an optimzes version of the B<Sieve of Eratosthenes>, which takes
half of the time and half of the space, but is still O(N).

=head2 B<fibonacci()>

	@fib = fibonacci($n);
	$fib = fibonacci($n);

Calculates the first N fibonacci numbers and returns them as array.
In scalar context returns the Nth number of the serie.

=head2 B<hailstone()>

	@hail = hailstone($n);		# sequence
	$hail = hailstone($n);		# length of sequence

Calculates the Hailstone sequence for the number N. This sequence is defined 
as follows:

	while (N != 0)
	  {
          if (N is even)
	    {
            N is N /2
   	    }
          else
	    {
            N = N * 3 +1
	    }
          }

It is not yet proven whether for every N the sequence reaches 1, but it
apparently does so. The number of steps is somewhat chaotically.

=head2 B<base()>

	($n,$a) = base($number,$base);

Reduces a number to $base to the $nth power plus $a. Example:

	use Math::BigInt :constant;
	use Math::Big qw/base/;

	print base ( 2 ** 150 + 42,2);

This will print 150 and 42.

=head2 B<wheel()>

	$wheel = wheel($o);

Returns a reference to a prime wheel of order $o. This is used for factoring
numbers into prime factors, see L<factors()> for a detailed description.

=head2 B<factors()>

Factor a number into it's prime factors and return a list of factors.

=head2 B<factorial()>

	$n = factorial($number,$factorial);

Calculate n! for n >= 1 and returns the result.

=head1 BUGS

=over 2

=item *

Primes and the Fibonacci serie use an array of size N and will not be able
to calculate big sequences due to memory constraints.

The exception is fibonacci in scalar context, this is able to calculate
arbitrarily big numbers in O(N) time:

	use Math::Big;
	use Math::BigInt qw/:constant/;

	$fib = Math::Big::fibonacci( 2 ** 320 );

=back

=head1 LICENSE

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

If you use this module in one of your projects, then please email me. I want
to hear about how my code helps you ;)

Quite a lot of ideas from other people, especially D. E. Knuth, have been used,
thank you!

Tels http://bloodgate.com 2001.

=cut

1;
