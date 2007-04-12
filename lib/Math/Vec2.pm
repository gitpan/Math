package Math::Vec2;

use strict;
use warnings;

use Math ();

#use Exporter;

use overload
  '='    => \&copy,
  '~'    => \&reverse,
  '>>'   => \&rotate,
  '<<'   => \&rotate,
  'eq'   => \&eq,
  '=='   => \&eq,
  'ne'   => \&ne,
  '!='   => \&ne,
  'bool' => \&length,
  'abs'  => \&abs,
  'neg'  => \&negate,
  '+='   => \&_add,
  '-='   => \&_subtract,
  '*='   => \&_multiply,
  '/='   => \&_divide,
  '**='  => \&_pow,
  '+'    => \&add,
  '-'    => \&subtract,
  '*'    => \&multiply,
  '/'    => \&divide,
  '.'    => \&dot,
  '**'   => \&pow,
  '""'   => \&toString,
  ;

our $VERSION = '0.31';

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

=head2 DefaultValue

	0 0

=head1 OPERATORS

=head2 Overview

	'~'		=>   reverse 
	'>>'		=>   rotate  
	'<<'		=>   rotate  
	'eq'		=>   eq      
	'=='		=>   eq      
	'ne'		=>   ne      
	'!='		=>   ne      
	'bool'   	=>   length  
	'abs'		=>   abs 
	'neg' 		=>   negate  
	'+='		=>   add     
	'-='		=>   subtract
	'*='		=>   multiply
	'/='		=>   divide  
	'**='		=>   pow     
	'+'		=>   add     
	'-'		=>   subtract
	'*'		=>   multiply
	'/'		=>   divide  
	'**'		=>   pow     
	'.'		=>   dot     
	'""'		=>   toString

=head2 ~

Returns the reverse of this vector.

	my $v = new Math::Vec2(1,2);
	
	printf "2 1 = %s\n",  ~$v;  # swap components
	printf "1 2 = %s\n", ~~$v;

=head2 <<

Performs a counter-clockwise rotation of the components.
Very similar to bitwise left-shift.

	my $v = new Math::Vec2(1,2);
	
	printf "2 1 = %s\n", $v << 1;
	printf "1 2 = %s\n", $v << 2;

=head2 >>

Performs a clockwise rotation of the components.
Very similar to bitwise right-shift.

	my $v = new Math::Vec2(1,2);
	
	printf "2 1 = %s\n", $v >> 1;
	printf "1 2 = %s\n", $v >> 2;

=cut

use constant DefaultValue => [ 0, 0 ];

=head1 METHODS

=head2 DefaultValue

Get the default value as array ref
	
	$default = $v1->DefaultValue;
	@default = @{ Math::Vec2->DefaultValue };

	$n = @{ Math::Vec2->DefaultValue };

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
		return bless [ @{ $self->DefaultValue } ], $class;
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

sub copy {
	my $this = shift;
	return $this->new( [ $this->getValue ] );
}

=head2 setValue(x,y,z)

Sets the value of the vector

	$v1->setValue(1,2);

=cut

sub setValue {
	my $this = shift;

	@$this = map {

		defined $_[$_] ? $_[$_] : $this->DefaultValue->[$_]

	  } 0 .. Math::minmax( $#_, $#{ $this->DefaultValue }, $#{ $this->DefaultValue } )
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

=cut

=head2 getX

Returns the first value of the vector.

	$x = $v1->getX;
	$x = $v1->x;
	$x = $v1->[0];

=cut

sub x    { $_[0]->[0] }
sub getX { $_[0]->[0] }

=head2 y

=cut

=head2 getY

Returns the second value of the vector.

	$y = $v1->getY;
	$y = $v1->y;
	$y = $v1->[1];

=cut

sub y    { $_[0]->[1] }
sub getY { $_[0]->[1] }

=head2 eq(vec2)

	my $bool = $v1->eq($v2);
	my $bool = $v1 eq $v2;
	my $bool = $v1 == $v2;

=cut

sub eq {
	my ( $a, $b ) = @_;
	return "$a" eq $b;
}

=head2 ne(vec2)

	my $bool = $v1->ne($v2);
	my $bool = $v1 ne $v2;
	my $bool = $v1 != $v2;

=cut

sub ne {
	my ( $a, $b ) = @_;
	return "$a" ne $b;
}

=head2 negate

	$v = $v1->negate;
	$v = -$v1;

=cut

sub negate {
	my ($a) = @_;
	return $a->new(
		-$a->[0],
		-$a->[1],
	);
}

=head2 add(vec2)

	$v = $v1->add($v2);
	$v = $v1 + $v2;
	$v1 += $v2;

=cut

sub add {
	my ( $a, $b ) = @_;
	return $a->new(
		$a->[0] + $b->[0],
		$a->[1] + $b->[1],
	);
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
	$v1 -= $v2;

=cut

sub subtract {
	my ( $a, $b ) = @_;
	return $a->new(
		$a->[0] - $b->[0],
		$a->[1] - $b->[1],
	);
}

sub _subtract {
	my ( $a, $b ) = @_;
	$a->[0] -= $b->[0];
	$a->[1] -= $b->[1];
	return $a;
}

=head2 multiply(scalar)

=cut

=head2 multiply(vec2)

	$v = $v1->multiply(2);
	$v = $v1 * 2;
	$v1 *= 2;

=cut

sub multiply {
	my ( $a, $b ) = @_;
	return ref $b ?
	  $a->new(
		$a->[0] * $b->[0],
		$a->[1] * $b->[1],
	  )
	  :
	  $a->new(
		$a->[0] * $b,
		$a->[1] * $b,
	  );
}

sub _multiply {
	my ( $a, $b ) = @_;
	$a->[0] *= $b;
	$a->[1] *= $b;
	return $a;
}

=head2 divide(scalar)

=cut

=head2 divide(vec2)

	$v = $v1->divide(2);
	$v = $v1 / 2;
	$v1 /= 2;

=cut

sub divide {
	my ( $a, $b ) = @_;
	return ref $b ?
	  $a->new(
		$a->[0] / $b->[0],
		$a->[1] / $b->[1],
	  )
	  : $a->new(
		$a->[0] / $b,
		$a->[1] / $b,
	  );
}

sub _divide {
	my ( $a, $b ) = @_;
	$a->[0] /= $b;
	$a->[1] /= $b;
	return $a;
}

=head2 pow(scalar)

This is used to overload the '**' operator.

	$v = $v1->pow(3);
	$v = $v1 * $v1 * $v1;

	$v = $v1 ** 3;

=cut

sub pow {
	my ( $a, $b ) = @_;
	return $a->new(
		$a->[0]**$b,
		$a->[1]**$b
	);
}

sub _pow {
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
	my ( $a, $b ) = @_;
	return ref $b ?
	  $a->[0] * $b->[0] +
	  $a->[1] * $b->[1]
	  : $a->toString . $b
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

sub normalize {
	my ($a) = @_;
	return $a->divide( $a->length );
}

=head2 abs()

Performs a componentwise abs.
This is used to overload the 'abs' operator.

	$v = $vec2->abs;

=cut

sub abs {
	return $_[0]->new( map { CORE::abs($_) } @{ $_[0] } );
}

=head2 reverse()

Returns the reverse of this vector.
This is used to overload the '~' operator.

	$v = $vec2->reverse;

=cut

sub reverse {
	return $_[0]->new( CORE::reverse @{ $_[0] } );
}

=head2 rotate(n)

Performs a componentwise rotation.
This is used to overload the '>>' and '<<' operator.

	$v = $vec2->rotate(1);  # swap
	$v = $vec2->rotate(2);  # eq

=cut

sub rotate {

	return

	  Math::odd( $_[1] ) ?

	  $_[0]->reverse

	  :

	  $_[0]->copy;
}

=head2 toString

Returns a string representation of the vector. This is used
to overload the '""' operator, so that vector may be
freely interpolated in strings.

	my $q = new Math::Vec2(1,2);
	print $q->toString;                # "1 2"
	print "$q";                        # "1 2"

=cut

sub toString {
	my $this = shift;
	return join " ", $this->getValue;
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

