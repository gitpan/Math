#!/usr/bin/perl -w

#############################################################################
# Math/Big.pm -- usefull routines with Big numbers (BigInt/BigFloat)
#
# Copyright (C) 2001 by Tels. All rights reserved.
#############################################################################

package Math::Big;
use vars qw($VERSION);
$VERSION = 1.01;    # Current version of this package
require  5.005;     # requires this Perl version or later

use Math::BigInt;
use Math::BigFloat;
use Exporter;
@ISA = qw( Exporter );
@EXPORT_OK = qw( primes fibonacci base hailstone
               );
#@EXPORT = qw( );
use strict;

sub primes
  {
  # sieve of eratosthenes
  my $n = shift;
  $n = Math::BigInt->new($n) unless ref $n;
  
  return if $n < 2;			# lowest prime is 2
 
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

#############################################################################

=head1 NAME

Math::Big - usefull routines with Big numbers (BigInt/BigFloat)

=head1 SYNOPSIS

    use Math::Big qw/primes fibonacci hailstone/;

    @primes	= primes(100);		# first 100 primes
    $prime	= primes(100);		# 100th prime
    @fib	= fibonacci (100);	# first 100 fibonacci numbers
    $fib_1000	= fibonacci (1000);	# 1000th fibonacci number
    $hailstone	= hailstone (1000);	# length of sequence
    @hailstone	= hailstone (127);	# the entire sequence
	
=head1 REQUIRES

perl5.005, Exporter, Math::BigInt, Math::BigFloat

=head1 EXPORTS

Exports nothing on default, but can export C<primes()>, C<fibonacci()>,
C<hailstone()>.

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

It is not yet proven wether for every N the sequence reaches 1, but it
apparently does so. The number of steps is somewhat chaotically.

=head2 B<base()>

	($n,$a) = base($number,$base);

Reduces a number to $base to the $nth power plus $a. Example:

	use Math::BigInt :constant;
	use Math::Big qw/base/;

	print base ( 2 ** 150 + 42,2);

This will print 150 and 42.

=head1 BUGS

=over 2

=item *

C<primes()> not implemented yet.

=item *

Primes and Fibonacci serie take an array of size N and will not be able
to calculate big sequences due to memory constraints.

The exception is fibonacci in scalar context, this is able to calculate
arbitrarily big numbers in O(N) time:

	use Math::Big;
	use Math::BigInt;

	$fib = Math::Big::fibonacci( Math::BigInt->new(2) ** 150 );

=back

=head1 AUTHOR

If you use this module in one of your projects, then please email me. I want
to hear about how my code helps you ;)

This module is (C) Tels http://bloodgate.com 2001.

=cut

1;
