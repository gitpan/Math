package Math::Vec2;

use strict;
use warnings;

use Math ();

#use Exporter;

our $VERSION = '0.314';

=head1 NAME

Math::Vec2 - Perl class to represent 2d vectors

=head1 TREE

-+- L<Math::Vec2>

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Vec2;
	my $v = new Math::Vec2;  # Make a new Vec2

	my $v1 = new Math::Vec2(0,1);

=head1 DESCRIPTION

=head2 Default value

	0 0

=cut

use overload
  '=' => \&copy,

  #"&", "^", "|",

  '~' => sub { $_[0]->new( [ CORE::reverse @{ $_[0] } ] ) },

  '>>' => sub { $_[1] & 1 ? ~$_[0] : $_[0]->copy },
  '<<' => sub { $_[1] & 1 ? ~$_[0] : $_[0]->copy },
  '>>=' => sub { @{ $_[0] } = CORE::reverse @{ $_[0] } if $_[1] & 1; $_[0] },
  '<<=' => sub { @{ $_[0] } = CORE::reverse @{ $_[0] } if $_[1] & 1; $_[0] },

  '<'   => sub { $_[1] > $_[0]->length },
  '<='  => sub { $_[1] >= $_[0]->length },
  '>'   => sub { $_[1] < $_[0]->length },
  '>='  => sub { $_[1] <= $_[0]->length },
  '<=>' => sub { $_[1] <=> $_[0]->length },
  '=='  => sub { "$_[0]" eq $_[1] },
  '!='  => sub { "$_[0]" ne $_[1] },

  'lt'  => sub { $_[1] gt "$_[0]" },
  'le'  => sub { $_[1] ge "$_[0]" },
  'gt'  => sub { $_[1] lt "$_[0]" },
  'ge'  => sub { $_[1] le "$_[0]" },
  'cmp' => sub { $_[1] cmp "$_[0]" },
  'eq'  => sub { "$_[0]" eq $_[1] },
  'ne'  => sub { "$_[0]" ne $_[1] },

  #"!" => sub { !$_[0]->length },
  'bool' => \&length,
  '0+'   => \&length,

  'abs' => \&abs,
  'neg' => \&negate,

  '+='  => \&_add,
  '-='  => \&_subtract,
  '*='  => \&_multiply,
  '/='  => \&_divide,
  '**=' => \&__pow,
  '%='  => \&__mod,
  #".=",

  '+'  => \&add,
  '-'  => \&subtract,
  '*'  => \&multiply,
  '/'  => \&divide,
  '**' => \&_pow,
  '%'  => \&_mod,
  '.'  => \&dot,

  #"x", "x=",

  #"atan2", "cos", "sin", "exp", "log", "sqrt", "int"

  #"<>"

  #'${}', '@{}', '%{}', '&{}', '*{}'.

  #"nomethod", "fallback",

  '""' => \&toString,
  ;

=head1 OPERATORS

=head2 Summary

	'~'		=>   Returns the reverse of this vector.
	
	'>>'		=>   Performs a clockwise rotation of the components.
	'>>='		=>   Performs a clockwise rotation of the components.
	'<<'		=>   Performs a counter-clockwise rotation of the components.    
	'<<='		=>   Performs a counter-clockwise rotation of the components.    
	
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

=head2 ~

Returns the reverse of this vector.
Very similar to L<perlbuiltin/reverse>.

	my $v = new Math::Vec2(1,2);
	
	printf "2 1 = %s\n",  ~$v;  # swap components
	printf "1 2 = %s\n", ~~$v;

=head2 >>

Performs a clockwise rotation of the components.
Very similar to bitwise right-shift.

	my $v = new Math::Vec2(1,2);
	
	printf "2 1 = %s\n", $v >> 1;
	printf "1 2 = %s\n", $v >> 2;

=head2 <<

Performs a counter-clockwise rotation of the components.
Very similar to bitwise left-shift.

	my $v = new Math::Vec2(1,2);
	
	printf "2 1 = %s\n", $v << 1;
	printf "1 2 = %s\n", $v << 2;

=head2 abs()

Performs a componentwise abs.
This is used to overload the 'abs' operator.

	$v = new Math::Vec2(-4, 5);
	$v = $vec2->abs;
	$v = abs($vec2);
	printf $v;         # 4 5

=head2 **

	$v = $v1 * $v1 * $v1;
	$v = $v1 ** 3;

=cut

sub abs { $_[0]->new( [ map { CORE::abs($_) } @{ $_[0] } ] ) }

=head1 METHODS

=head2 getDefaultValue

Get the default value as array ref
	
	$default = $v1->getDefaultValue;
	@default = @{ Math::Vec2->getDefaultValue };

	$n = @{ Math::Vec2->getDefaultValue };

=cut

use constant getDefaultValue => [ 0, 0 ];

=head2 new

	my $v = new Math::Vec2; 					  
	my $v2 = new Math::Vec2(1,2);
	my @v3 = @$v; 
	
If you call new() with a reference to an array, it will be used as reference.

	my $v3 = new Math::Vec2([1,2]); 

=cut

sub new {
	my $self = shift;
	my $class = ref($self) || $self;

	if ( 0 == @_ ) {
		# No arguments, default to standard
		return bless [ @{ $self->getDefaultValue } ], $class;
	} elsif ( 1 == @_ ) {

		if ( ref( $_[0] ) eq 'ARRAY' ) {    # [0,1]
			return bless shift(), $class;
		} else {
			warn("Don't understand arguments passed to new()");
		}

	} elsif ( @_ > 1 ) {    # x,y
		my $this = bless [], $class;
		$this->setValue(@_);
		return $this;
	} else {
		warn("Don't understand arguments passed to new()");
	}

	return;
}

=head2 copy

Makes a copy
	
	$v2 = $v1->copy;

=cut

sub copy { $_[0]->new( [ $_[0]->getValue ] ) }

=head2 setValue(x,y,z)

Sets the value of the vector

	$v1->setValue(1,2);

=cut

sub setValue {
	my $this = shift;

	@$this = map {

		defined $_[$_] ? $_[$_] : $this->getDefaultValue->[$_]

	  } 0 .. Math::minmax( $#_, $#{ $this->getDefaultValue }, $#{ $this->getDefaultValue } )
}

=head2 setX(x)

Sets the first value of the vector

	$v1->setX(1);

	$v1->x   = 1;
	$v1->[0] = 1;

=cut

sub setX { $_[0]->[0] = $_[1] }

=head2 setY(y)

Sets the second value of the vector

	$v1->setY(2);

	$v1->y   = 2;
	$v1->[1] = 2;

=cut

sub setY { $_[0]->[1] = $_[1] }

=head2 getValue

Returns the value of the vector (x, y) as a 2 components array.

	@v = $v1->getValue;

=cut

sub getValue { @{ $_[0] } }

=head2 x

=head2 getX

Returns the first value of the vector.

	$x = $v1->getX;
	$x = $v1->x;
	$x = $v1->[0];

=cut

sub x    { $_[0]->[0] }
sub getX { $_[0]->[0] }

=head2 y

=head2 getY

Returns the second value of the vector.

	$y = $v1->getY;
	$y = $v1->y;
	$y = $v1->[1];

=cut

sub y    { $_[0]->[1] }
sub getY { $_[0]->[1] }

=head2 negate

	$v = $v1->negate;
	$v = -$v1;

=cut

sub negate {
	my ($a) = @_;
	return $a->new( [
			-$a->[0],
			-$a->[1],
	] );
}

=head2 add(vec2)

	$v = $v1->add($v2);
	$v = $v1 + $v2;
	$v = [8, 2] + $v1;
	$v1 += $v2;

=cut

sub add {
	my ( $a, $b ) = @_;
	return $a->new( [
			$a->[0] + $b->[0],
			$a->[1] + $b->[1],
	] );
}

sub _add {
	my ( $a, $b ) = @_;
	$a->[0] += $b->[0];
	$a->[1] += $b->[1];
	return $a;
}

=head2 subtract(vec2)

	$v = $v1->subtract($v2);
	$v = $v1 - $v2;
	$v = [8, 2] - $v1;
	$v1 -= $v2;

=cut

sub subtract {
	my ( $a, $b, $r ) = @_;
	return $a->new( [
			$r ? (
				$b->[0] - $a->[0],
				$b->[1] - $a->[1],
			  ) : (
				$a->[0] - $b->[0],
				$a->[1] - $b->[1],
			  ) ] )
	  ;
}

sub _subtract {
	my ( $a, $b ) = @_;
	$a->[0] -= $b->[0];
	$a->[1] -= $b->[1];
	return $a;
}

=head2 multiply(vec2 or scalar)

This is used to overload the '*' operator.

	$v = $v1 * 2;
	$v = $v1 * [3, 5];
	$v = [8, 2] * $v1;
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
		] )
	  :
	  $a->new( [
			$a->[0] * $b,
			$a->[1] * $b,
	  ] );
}

sub _multiply {
	my ( $a, $b ) = @_;
	if ( ref $b ) {
		$a->[0] *= $b->[0];
		$a->[1] *= $b->[1];
	} else {
		$a->[0] *= $b;
		$a->[1] *= $b;
	}
	return $a;
}

=head2 divide(vec2 or scalar)

This is used to overload the '/' operator.

	$v = $v1 / 2;
	$v1 /= 2;
	$v = $v1 / [3, 7];
	$v = [8, 2] / $v1;
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
			  ) : (
				$a->[0] / $b->[0],
				$a->[1] / $b->[1],
			  ) ] )
	  : $a->new( [
			$a->[0] / $b,
			$a->[1] / $b,
	  ] );
}

sub _divide {
	my ( $a, $b ) = @_;
	if ( ref $b ) {
		$a->[0] /= $b->[0];
		$a->[1] /= $b->[1];
	} else {
		$a->[0] /= $b;
		$a->[1] /= $b;
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
			  ) : (
				Math::fmod( $a->[0], $b->[0] ),
				Math::fmod( $a->[1], $b->[1] ),
			  ) ] )
	  : $a->new( [
			Math::fmod( $a->[0], $b ),
			Math::fmod( $a->[1], $b ),
	  ] );
}

sub __mod {
	my ( $a, $b ) = @_;
	if ( ref $b ) {
		$a->[0] = Math::fmod( $a->[0], $b->[0] );
		$a->[1] = Math::fmod( $a->[1], $b->[1] );
	} else {
		$a->[0] = Math::fmod( $a->[0], $b );
		$a->[1] = Math::fmod( $a->[1], $b );
	}
	return $a;
}

sub _pow {
	my ( $a, $b ) = @_;
	return $a->new( [
			$a->[0]**$b,
			$a->[1]**$b
	] );
}

sub __pow {
	my ( $a, $b ) = @_;
	$a->[0]**= $b;
	$a->[1]**= $b;
	return $a;
}

=head2 dot(vec2)

	$s = $v1->dot($v2);
	$s = $v1 . $v2;
	$s = $v1 . [ 2, 3 ];

=cut

sub dot {
	my ( $a, $b, $r ) = @_;
	return ref $b ?
	  $a->[0] * $b->[0] +
	  $a->[1] * $b->[1]
	  : ( $r ? $b . "$a" : "$a" . "$b" )
	  ;
}

=head2 length

Returns the length of the vector

	$l = $v1->length;

=cut

sub length {
	my ($a) = @_;
	return sqrt(
		$a->[0] * $a->[0] +
		  $a->[1] * $a->[1]
	);
}

=head2 normalize

	$v = $v1->normalize;

=cut

sub normalize { $_[0] / $_[0]->length }

=head2 sig

Performs a componentwise sig.

	$v = new Math::Vec2(-4, 5);
	$v = $vec2->sig;
	printf $v;         # -1 1

=cut

#sub sig { $_[0]->new( [ map { Math::sig($_) } @{ $_[0] } ] ) }
sub sig { $_[0]->new( [ map { $_ ? ( $_ < 0 ? -1 : 1 ) : 0 } @{ $_[0] } ] ) }

=head2 sum

Returns the sum of the components.

	$v = new Math::Vec2(-8, 2);
	$s = $vec2->sum;
	printf $s;         # -6

=cut

sub sum { $_[0]->[0] + $_[0]->[1] }

=head2 toString

Returns a string representation of the vector. This is used
to overload the '""' operator, so that vector may be
freely interpolated in strings.

	my $q = new Math::Vec2(1,2);
	print $q->toString;                # "1 2"
	print "$q";                        # "1 2"

=cut

sub toString {
	return join " ", $_[0]->getValue;
}

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

