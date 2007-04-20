package Math::Vec3;

use strict;
use warnings;

use Math ();

#use Exporter;

our $VERSION = '0.334';

use base 'Math::Vector';

=head1 NAME

Math::Vec3 - Perl class to represent 3d vectors

=head1 TREE

-+- L<Math::Vector> -+- L<Math::Vec3>

=head1 SEE ALSO

L<PDL> for scientific and bulk numeric data processing and display

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Vec3;
	my $v = new Math::Vec3;  # Make a new Vec3

	my $v1 = new Math::Vec3(1,2,3);

=head1 DESCRIPTION

=head2 Default value

	0 0 0

=head1 OPERATORS

=head2 Summary

	'!'		=>   Returns true if the length of this vector is 0
	
	'<'		=>   Numerical gt. Compares the length of this vector with a vector or a scalar value.
	'<='		=>   Numerical le. Compares the length of this vector with a vector or a scalar value.
	'>'		=>   Numerical lt. Compares the length of this vector with a vector or a scalar value.
	'>='		=>   Numerical ge. Compares the length of this vector with a vector or a scalar value.
	'<=>'		=>   Numerical cmp. Compares the length of this vector with a vector or a scalar value.
	'=='		=>   Numerical eq. Performs a componentwise equation.
	'!='		=>   Numerical ne. Performs a componentwise equation.
	
	'lt'		=>   Stringwise lt
	'le'		=>   Stringwise le
	'gt'		=>   Stringwise gt
	'ge'		=>   Stringwise ge
	'cmp'		=>   Stringwise cmp
	'eq'		=>   Stringwise eq
	'ne'		=>   Stringwise ne
	
	'bool'   	=>   Returns true if the length of this vector is not 0
	'0+'		=>   Numeric conversion operator. Returns the length of this vector.
	
	'abs'		=>   Performs a componentwise abs.
	'neg' 		=>   Performs a componentwise negation.  
	
	'++'		=>   Increment components     
	'--'		=>   Decrement components     
	'+='		=>   Add a vector
	'-='		=>   Subtract a vector
	'*='		=>   Multiply with a vector or a scalar value.
	'/='		=>   Divide with a vector or a scalar value.
	'**='		=>   Power
	'%='		=>   Modulo fmod
	
	'+'		=>   Add two vectors
	'-'		=>   Subtract vectors
	'*'		=>   Multiply this vector with a vector or a scalar value.
	'/'		=>   Divide this vector with a vector or a scalar value.
	'**'		=>   Returns a power of this vector.
	'%'		=>   Modulo fmod
	'.'		=>   Returns the dot product of two vectors.
	
	'""'		=>   Returns a string representation of the vector.

=cut

use overload
  #"&", "^", "|",

  #'>>=' => sub { @{ $_[0] } = CORE::reverse @{ $_[0] } if $_[1] & 1; $_[0] },
  #'<<=' => sub { @{ $_[0] } = CORE::reverse @{ $_[0] } if $_[1] & 1; $_[0] },

  #"!" => sub { !$_[0]->length },
  'bool' => \&length,
  '0+'   => \&length,

  'neg' => \&negate,

  '+='  => \&_add,
  '-='  => \&_subtract,
  '*='  => \&_multiply,
  '/='  => \&_divide,
  '**=' => \&__pow,
  '%='  => \&__mod,
  #".=", # not posible
  "x=" => \&_cross,

  '+'  => \&add,
  '-'  => \&subtract,
  '*'  => \&multiply,
  '/'  => \&divide,
  '**' => \&_pow,
  '%'  => \&_mod,
  '.'  => \&dot,
  "x"  => \&cross,

  #"atan2", "cos", "sin", "exp", "log", "sqrt", "int"

  #"<>"

  #'${}', '@{}', '%{}', '&{}', '*{}'.

  #"nomethod", "fallback",
  ;

=head1 METHODS

=head2 getDefaultValue

Get the default value as array ref
	
	$default = $v1->getDefaultValue;
	@default = @{ Math::Vec3->getDefaultValue };

	$n = @{ Math::Vec3->getDefaultValue };

=cut

use constant getDefaultValue => [ 0, 0, 0 ];

=head2 setX(x)

Sets the first value of the vector

	$v1->setX(1);

	$v1->[0] = 1;

=cut

sub setX { $_[0]->[0] = $_[1]; return }

=head2 setY(y)

Sets the second value of the vector

	$v1->setY(2);

	$v1->[1] = 2;

=cut

sub setY { $_[0]->[1] = $_[1]; return }

=head2 setZ(z)

Sets the third value of the vector

	$v1->setZ(2);

	$v1->[2] = 2;

=cut

sub setZ { $_[0]->[2] = $_[1]; return }

=head2 getX

Returns the first value of the vector.

	$x = $v1->getX;
	$x = $v1->[0];

=cut

sub getX { $_[0]->[0] }

=head2 getY

Returns the second value of the vector.

	$y = $v1->getY;
	$y = $v1->[1];

=cut

sub getY { $_[0]->[1] }

=head2 getZ

Returns the third value of the vector.

	$y = $v1->getZ;
	$y = $v1->[2];

=cut

sub getZ { $_[0]->[2] }

=head2 negate

This is used to overload the 'neg' operator.

	$v = $v1->negate;
	$v = -$v1;

=cut

sub negate {
	my ($a) = @_;
	return $a->new( [
			-$a->[0],
			-$a->[1],
			-$a->[2],
	] );
}

=head2 add(Vec3)

This is used to overload the '+' operator.

	$v = $v1->add($v2);
	$v = $v1 + $v2;
	$v = [8, 2, 4] + $v1;
	$v1 += $v2;

=cut

sub add {
	my ( $a, $b ) = @_;
	return $a->new( [
			$a->[0] + $b->[0],
			$a->[1] + $b->[1],
			$a->[2] + $b->[2],
	] );
}

sub _add {
	my ( $a, $b ) = @_;
	$a->[0] += $b->[0];
	$a->[1] += $b->[1];
	$a->[2] += $b->[2];
	return $a;
}

=head2 subtract(Vec3)

This is used to overload the '-' operator.

	$v = $v1->subtract($v2);
	$v = $v1 - $v2;
	$v = [8, 2, 4] - $v1;
	$v1 -= $v2;

=cut

sub subtract {
	my ( $a, $b, $r ) = @_;
	return $a->new( [
			$r ? (
				$b->[0] - $a->[0],
				$b->[1] - $a->[1],
				$b->[2] - $a->[2],
			  ) : (
				$a->[0] - $b->[0],
				$a->[1] - $b->[1],
				$a->[2] - $b->[2],
			  ) ] )
	  ;
}

sub _subtract {
	my ( $a, $b ) = @_;
	$a->[0] -= $b->[0];
	$a->[1] -= $b->[1];
	$a->[2] -= $b->[2];
	return $a;
}

=head2 multiply(Vec3 or scalar)

This is used to overload the '*' operator.

	$v = $v1 * 2;
	$v = $v1 * [3, 5, 4];
	$v = [8, 2, 4] * $v1;
	$v = $v1 * $v1;
	$v1 *= 2;
	
	$v = $v1->multiply(2);

=cut

sub multiply {
	my ( $a, $b ) = @_;
	return ref $b ?
	  $a->new( [
			$a->[0] * $b->[0],
			$a->[1] * $b->[1],
			$a->[2] * $b->[2],
		] )
	  :
	  $a->new( [
			$a->[0] * $b,
			$a->[1] * $b,
			$a->[2] * $b,
	  ] );
}

sub _multiply {
	my ( $a, $b ) = @_;
	if ( ref $b ) {
		$a->[0] *= $b->[0];
		$a->[1] *= $b->[1];
		$a->[2] *= $b->[2];
	} else {
		$a->[0] *= $b;
		$a->[1] *= $b;
		$a->[2] *= $b;
	}
	return $a;
}

=head2 divide(Vec3 or scalar)

This is used to overload the '/' operator.

	$v = $v1 / 2;
	$v1 /= 2;
	$v = $v1 / [3, 7, 4];
	$v = [8, 2, 4] / $v1;
	$v = $v1 / $v1;	# unit vector
	
	$v = $v1->divide(2);

=cut

sub divide {
	my ( $a, $b, $r ) = @_;
	return ref $b ?
	  $a->new( [
			$r ? (
				$b->[0] / $a->[0],
				$b->[1] / $a->[1],
				$b->[2] / $a->[2],
			  ) : (
				$a->[0] / $b->[0],
				$a->[1] / $b->[1],
				$a->[2] / $b->[2],
			  ) ] )
	  : $a->new( [
			$a->[0] / $b,
			$a->[1] / $b,
			$a->[2] / $b,
	  ] );
}

sub _divide {
	my ( $a, $b ) = @_;
	if ( ref $b ) {
		$a->[0] /= $b->[0];
		$a->[1] /= $b->[1];
		$a->[2] /= $b->[2];
	} else {
		$a->[0] /= $b;
		$a->[1] /= $b;
		$a->[2] /= $b;
	}
	return $a;
}

#mod
#cut
sub _mod {
	my ( $a, $b, $r ) = @_;
	return ref $b ?
	  $a->new( [
			$r ? (
				Math::fmod( $b->[0], $a->[0] ),
				Math::fmod( $b->[1], $a->[1] ),
				Math::fmod( $b->[2], $a->[2] ),
			  ) : (
				Math::fmod( $a->[0], $b->[0] ),
				Math::fmod( $a->[1], $b->[1] ),
				Math::fmod( $a->[2], $b->[2] ),
			  ) ] )
	  : $a->new( [
			Math::fmod( $a->[0], $b ),
			Math::fmod( $a->[1], $b ),
			Math::fmod( $a->[2], $b ),
	  ] );
}

sub __mod {
	my ( $a, $b ) = @_;
	if ( ref $b ) {
		$a->[0] = Math::fmod( $a->[0], $b->[0] );
		$a->[1] = Math::fmod( $a->[1], $b->[1] );
		$a->[2] = Math::fmod( $a->[2], $b->[2] );
	} else {
		$a->[0] = Math::fmod( $a->[0], $b );
		$a->[1] = Math::fmod( $a->[1], $b );
		$a->[2] = Math::fmod( $a->[2], $b );
	}
	return $a;
}

sub _pow {
	my ( $a, $b ) = @_;
	return $a->new( [
			$a->[0]**$b,
			$a->[1]**$b,
			$a->[2]**$b,
	] );
}

sub __pow {
	my ( $a, $b ) = @_;
	$a->[0]**= $b;
	$a->[1]**= $b;
	$a->[2]**= $b;
	return $a;
}

=head2 dot(Vec3)

This is used to overload the '.' operator.

	$s = $v1->dot($v2);
	$s = $v1 . $v2;
	$s = $v1 . [ 2, 3, 4 ];

=cut

sub dot {
	my ( $a, $b, $r ) = @_;
	return ref $b ?
	  $a->[0] * $b->[0] +
	  $a->[1] * $b->[1] +
	  $a->[2] * $b->[2]
	  : ( $r ? $b . "$a" : "$a" . "$b" )
	  ;
}

=head2 cross(vec3)

This is used to overload the 'x' operator.

	$v = $v1->cross($v2);
	$v = $v1 x $v2;
	$v = $v1 x [ 2, 3, 4 ];

=cut

sub cross {
	my ( $a, $b ) = @_;

	my ( $a0, $a1, $a2 ) = @$a;
	my ( $b0, $b1, $b2 ) = @$b;

	return $a->new( [
			$a1 * $b2 - $a2 * $b1,
			$a2 * $b0 - $a0 * $b2,
			$a0 * $b1 - $a1 * $b0
	] );
}

sub _cross {
	my ( $a, $b ) = @_;

	my ( $a0, $a1, $a2 ) = @$a;
	my ( $b0, $b1, $b2 ) = @$b;

	$a->[0] = $a1 * $b2 - $a2 * $b1;
	$a->[1] = $a2 * $b0 - $a0 * $b2;
	$a->[2] = $a0 * $b1 - $a1 * $b0;

	return $a;
}

=head2 length

Returns the length of the vector
This is used to overload the '0+' operator.

	$l = $v1->length;

=cut

sub length {
	my ($a) = @_;
	return sqrt(
		$a->[0] * $a->[0] +
		  $a->[1] * $a->[1] +
		  $a->[2] * $a->[2]
	);
}

=head2 normalize

	$v = $v1->normalize;

=cut

1;

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 BUGS & SUGGESTIONS

If you run into a miscalculation, need some sort of feature or an additional
L<holiday|Date::Holidays::AT>, or if you know of any new changes to the funky math, 
please drop the author a note.

=head1 ARRANGED BY

Holger Seelig  holger.seelig@yahoo.de

=head1 COPYRIGHT

This is free software; you can redistribute it and/or modify it
under the same terms as L<Perl|perl> itself.

=cut

