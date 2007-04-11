package Math;
use strict;
use warnings;

our @POSIX = qw(
  acos
  asin
  atan
  ceil
  floor
  round
  log10
);

use POSIX @POSIX;

use base Exporter::;

our @CONSTANTS = qw(
  E
  LN10
  LN2
  PI
  PI1_4
  PI1_2
  PI2
  SQRT1_2
  SQRT2
);

our @FUNCTIONS = qw(
  max
  min
  minmax
  random
  pro
  sum
  even
  odd
  sig
);

our @EXPORT = ( @CONSTANTS, @FUNCTIONS, @POSIX );

=head1 NAME

Math - constants and functions

=head1 SYNOPSIS

	use Math;

	printf "2.71828182845905 = %s\n", E;
	printf "1.5707963267949  = %s\n", PI1_2;
	
	printf "1 = %s\n", round(0.5);
	printf "1 = %s\n", ceil(0.5);
	printf "0 = %s\n", floor(0.5);

	or 

	use Math ();

	printf "%s\n", Math::PI;
	printf "%s\n", Math::round(0.5);

=head1 SEE ALSO

L<perlfunc>

L<POSIX>

L<Math::Complex>, L<Math::Trig>, L<Math::Quaternion>

L<Math::Color>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 Constants

=head2 E

	Euler's constant, e, approximately 2.718

=head2 LN10

	Natural logarithm of 10, approximately 2.302

=head2 LN2

	Natural logarithm of 2, approximately 0.693

=head2 PI

	Ratio of the circumference of a circle to its diameter, approximately 3.1415

=head2 PI1_4

	L</PI> * 1/4

=head2 PI1_2

	L</PI> * 1/2

=head2 PI2

	L</PI> * 2

=head2 SQRT1_2

	square root of 1/2, approximately 0.707

=head2 SQRT2

	square root of 2, approximately 1.414

=cut

use constant E       => 2**( 1 / log(2) );
use constant LN10    => log(10);
use constant LN2     => log(2);
use constant PI      => 4 * CORE::atan2( 1, 1 );
use constant PI1_4   => PI * 1 / 4;
use constant PI1_2   => PI * 1 / 2;
use constant PI2     => PI * 2;
use constant SQRT1_2 => sqrt( 1 / 2 );
use constant SQRT2   => sqrt(2);

=head1 Functions

Note number, number1, number2, base, and exponent indicate any expression with a scalar value.

=head2 abs(number)

	Returns the absolute value of number

=head2 acos(number)

	Returns the arc cosine (in radians) of number

=head2 asin(number)

	Returns the arc sine (in radians) of number

=head2 atan(number)

	Returns the arc tangent (in radians) of number

=head2 ceil(number)

	Returns the least integer greater than or equal to number

=head2 cos(number)

	Returns the cosine of number where number is expressed in radians

=head2 exp(number)

	Returns e, to the power of number (i.e. enumber)

=head2 even(number)

	Returns 1 if number is even otherwise 0

=head2 floor(number)

	Returns the greatest integer less than or equal to its argument

=head2 log(number)

	Returns the natural logarithm (base e) of number

=head2 log10(number)

	Returns the logarithm (base 10) of number

=head2 min(number1, number2)

	Returns the lesser of number1 and number2

=head2 max(number1, number2)

	Returns the greater of number1 and number2

=head2 minmax(min, number, max)

=head2 minmax(number, min, max)

	Returns number between or equal min and max

=head2 odd(number)

	Returns 1 if number is odd otherwise 0

=head2 pow(base, exponent)

	Returns base to the exponent power (i.e. base exponent)
	
	$base ** $exponent == pow($base, $exponent);

=head2 pro(number, number1, number2, ...)

	Returns the product of its arguments

	pro(1,2,3) == 1 * 2 * 3;
	my $product = pro(@array);

=head2 random()

	Returns a pseudo-random number between 0 and 1.

=head2 random(number)

	Returns a pseudo-random number between 0 and number.

=head2 random(number1, number2)

	Returns a pseudo-random number between number1 and number2.

=head2 round(number)

	Returns the value of number rounded to the nearest integer

=head2 round(number1, digits)

	round(0.123456, 2) == 0.12;

	round(50, -2)   == 100;
	round(5, -1)    == 10;
	round(0.5)      == 1;
	round(0.05, 1)  == 0.1;
	round(0.005, 2) == 0.01;

=head2 sig(number)

	Returns 1 if number is greater 0 otherwise -1

=head2 sin(number)

	Returns the sine of number where number is expressed in radians

=head2 sqrt(number)

	Returns the square root of its argument

=head2 sum(number, number1, number2, ...)

	Returns the sum of its arguments

	sum(1..3) == 1 + 2 + 3;
	my $sum = sum(@array);

=head2 tan(number)

	Returns the tangent of number, where number is expressed in radians

=cut

sub abs { CORE::abs(@_) }
sub cos { CORE::cos(@_) }
sub exp { CORE::exp(@_) }

sub log { POSIX::log(@_) }

sub min {
	@_ = sort { $a <=> $b } @_;
	shift;
}

sub max {
	@_ = sort { $a <=> $b } @_;
	pop;
}

sub minmax { min( max( $_[0], $_[1] ), $_[2] ) }

sub pro {
	my $pro = 1;
	$pro *= $_ foreach @_;
	return @_ ? $pro : 0;
}

sub random {
	@_ = sort { $a <=> $b } @_;
	return $_[0] + rand( $_[1] - $_[0] ) if @_ == 2;
	return rand(@_);
}

sub round {
	return int( $_[0] + ( $_[0] < 0 ? -0.5 : 0.5 ) ) if @_ == 1 || $_[1] == 0;
	return sprintf "%.$_[1]f", $_[0] if $_[1] >= 0;

	my $f = 10**-$_[1];
	return round( $_[0] / $f ) * $f;
}

sub sum {
	my $sum = 0;
	$sum += $_ foreach @_;
	return $sum;
}

sub sin  { CORE::sin(@_) }
sub sqrt { CORE::sqrt(@_) }

sub even { $_[0] & 1 ? 0 : 1 }
sub odd { $_[0] & 1 }
sub sig { $_[0] < 0 ? -1 : 1 }

1;

=head1 SEE ALSO

L<perlfunc>

L<POSIX>

L<Math::Complex>, L<Math::Trig>, L<Math::Quaternion>

L<Math::Color>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 BUGS & SUGGESTIONS

If you run into a miscalculation, need some sort of feature or an additional
L<holiday|Date::Holidays::AT>, or if you know of any new changes to the funky math, 
please drop the author a note.

=head1 ARRANGED BY

	Holger Seelig  E<holger.seelig@yahoo.de>

=head1 COPYRIGHT

This is free software; you can redistribute it and/or modify it
under the same terms as L<Perl|perl> itself.

=cut
