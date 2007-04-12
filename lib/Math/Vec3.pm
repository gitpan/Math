package Math::Vec3;

use strict;
use warnings;

#use Exporter;

use base 'Math::Vec2';

use overload
  #  '='    => \&copy,
  #  '~'    => \&reverse,
  '>>' => \&rotate,
  '<<' => sub { $_[0]->rotate( -$_[1] ) },
  #  'eq'   => \&eq,
  #  '=='   => \&eq,
  #  'ne'   => \&ne,
  #  '!='   => \&ne,
  'bool' => \&length,
  #  'abs'  => \&abs,
  'neg' => \&negate,
  '+='  => \&_add,
  '-='  => \&_subtract,
  '*='  => \&_multiply,
  '/='  => \&_divide,
  '**=' => \&_pow,
  'x='  => \&_cross,
  '+'   => \&add,
  '-'   => \&subtract,
  '*'   => \&multiply,
  '/'   => \&divide,
  '**'  => \&pow,
  '.'   => \&dot,
  'x'   => \&cross,
  #  '""'   => \&toString,
  ;

our $VERSION = '0.31';

use constant DefaultValue => [ 0, 0, 0 ];

=head1 NAME

Math::Vec3 - Perl class to represent 3d vectors

=head1 TREE

-+- L<Math::Vec2> -+- L<Math::Vec3>

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Vec3;
	my $v = new Math::Vec3;  # Make a new vec3

	my $v1 = new Math::Vec3(0,1,0);

=head1 DESCRIPTION

3D vector class used to store 3D vectors and points.

=head2 DefaultValue

	0 0 0

=head1 OPERATORS

=head2 Overview

	'~'		=> reverse
	'>>'		=> rotate
	'<<'		=> rotate
	'eq'		=> eq
	'=='		=> eq
	'ne'		=> ne
	'!='		=> ne
	'bool'		=> length
	'abs'		=> abs 
	'neg' 		=> negate
	'+='		=> add
	'-='		=> subtract
	'*='		=> multiply
	'/='		=> divide
	'**='		=> pow     
	'x='		=> cross
	'+'		=> add
	'-'		=> subtract
	'*'		=> multiply
	'/'		=> divide
	'**'		=> pow     
	'.'		=> dot
	'x'		=> cross
	'""'		=> toString

=head2 ~

Returns the reverse of this vector.

	my $v = new Math::Vec3(1,2,3);
	
	printf "3 2 1 = %s\n",  ~$v;
	printf "1 2 3 = %s\n", ~~$v;

=head2 <<

Performs a counter-clockwise rotation of the components.
Very similar to bitwise left-shift.

	my $v = new Math::Vec3(1,2,3);
	
	printf "2 3 1= %s\n", $v << 1;
	printf "3 1 2 = %s\n", $v << 2;

=head2 >>

Performs a clockwise rotation of the components.
Very similar to bitwise right-shift.

	my $v = new Math::Vec3(1,2,3);
	
	printf "3 1 2 = %s\n", $v >> 1;
	printf "2 3 1 = %s\n", $v >> 2;

	$v x= [1, 2, 3];

	$v x= ~$v x [1, 2, 3] >> 2;

=cut

=head1 METHODS

=head2 new

Derived from L<Math::Vec2/new>.

	my $v  = new Math::Vec3; 					  
	my $v2 = new Math::Vec3(1,2,3);
	my @v3 = @$v; 
	
If you call new() with a reference to an array, it will be used as reference.

	my $v3 = new Math::Vec3([1,2,3]); 

I=cut

=head2 copy

Makes a copy
	
	$v2 = $v1->copy;

=cut

=head2 setValue(x,y,z)

Sets the value of the vector

	$v1->setValue(1,2,3);

=cut

=head2 setX(x)

Sets the first value of the vector

	$v1->setX(1);

	$v1->x   = 1;
	$v1->[0] = 1;

=cut

=head2 setY(y)

Sets the second value of the vector

	$v1->setY(2);

	$v1->y   = 2;
	$v1->[1] = 2;

=cut

=head2 setZ(z)

Sets the third value of the vector

	$v1->setZ(3);

	$v1->z   = 3;
	$v1->[2] = 3;

=cut

sub setZ { $_[0]->[2] = $_[1] }

# sub getClosestAxis {
#
#   SbVec3f closest(0.0f, 0.0f, 0.0f);
#
#   float xabs = abs(this->vec[0]);
#   float yabs = abs(this->vec[1]);
#   float zabs = abs(this->vec[2]);
#
#   if (xabs>=yabs && xabs>=zabs) closest[0] = (this->vec[0] > 0.0f) ? 1.0f : -1.0f;
#   else if (yabs>=zabs) closest[1] = (this->vec[1] > 0.0f) ? 1.0f : -1.0f;
#   else closest[2] = (this->vec[2] > 0.0f) ? 1.0f : -1.0f;
#
#   return closest;
# }

=head2 getValue

Returns the value of the vector (x, y, z) as a 3 components array.

	@v = $v1->getValue;

=cut

=head2 x

=cut

=head2 getX

Returns the first value of the vector.

	$x = $v1->getX;
	$x = $v1->x;
	$x = $v1->[0];

=cut

=head2 y

=cut

=head2 getY

Returns the second value of the vector.

	$y = $v1->getY;
	$y = $v1->y;
	$y = $v1->[1];

=cut

=head2 z

=cut

=head2 getZ

Returns the third value of the vector

	$z = $v1->getZ;
	$z = $v1->z;
	$z = $v1->[2];

=cut

sub z    { $_[0]->[2] }
sub getZ { $_[0]->[2] }

=head2 eq(vec3)

	my $bool = $v1->eq($v2);
	my $bool = $v1 eq $v2;
	my $bool = $v1 == $v2;

=cut

=head2 ne(vec3)

	my $bool = $v1->ne($v2);
	my $bool = $v1 ne $v2;
	my $bool = $v1 != $v2;

=cut

=head2 negate

	$v = $v1->negate;
	$v = -$v1;

=cut

sub negate {
	my ($a) = @_;
	return $a->new(
		-$a->[0],
		-$a->[1],
		-$a->[2]
	);
}

=head2 add(vec3)

	$v = $v1->add($v2);
	$v = $v1 + $v2;
	$v1 += $v2;

=cut

sub add {
	my ( $a, $b ) = @_;
	return $a->new(
		$a->[0] + $b->[0],
		$a->[1] + $b->[1],
		$a->[2] + $b->[2]
	);
}

sub _add {
	my ( $a, $b ) = @_;
	$a->[0] += $b->[0];
	$a->[1] += $b->[1];
	$a->[2] += $b->[2];
	return $a;
}

=head2 subtract(vec3)

	$v = $v1->subtract($v2);
	$v = $v1 - $v2;
	$v1 -= $v2;

=cut

sub subtract {
	my ( $a, $b ) = @_;
	return $a->new(
		$a->[0] - $b->[0],
		$a->[1] - $b->[1],
		$a->[2] - $b->[2]
	);
}

sub _subtract {
	my ( $a, $b ) = @_;
	$a->[0] -= $b->[0];
	$a->[1] -= $b->[1];
	$a->[2] -= $b->[2];
	return $a;
}

=head2 multiply(scalar)

=cut

=head2 multiply(vec3)

	$v = $v1->multiply($v2);

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
		$a->[2] * $b->[2]
	  )
	  :
	  $a->new(
		$a->[0] * $b,
		$a->[1] * $b,
		$a->[2] * $b
	  );
}

sub _multiply {
	my ( $a, $b ) = @_;
	$a->[0] *= $b;
	$a->[1] *= $b;
	$a->[2] *= $b;
	return $a;
}

=head2 divide(scalar)

=cut

=head2 divide(vec3)

	$v = $v1->divide($v2);

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
		$a->[2] / $b->[2]
	  )
	  : $a->new(
		$a->[0] / $b,
		$a->[1] / $b,
		$a->[2] / $b
	  );
}

sub _divide {
	my ( $a, $b ) = @_;
	$a->[0] /= $b;
	$a->[1] /= $b;
	$a->[2] /= $b;
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
		$a->[1]**$b,
		$a->[2]**$b,
	);
}

sub _pow {
	my ( $a, $b ) = @_;
	$a->[0]**= $b;
	$a->[1]**= $b;
	$a->[2]**= $b;
	return $a;
}

=head2 dot(vec3)

	$s = $v1->dot($v2);
	$s = $v1 . $v2;
	$s = $v1 . [ 2, 3, 4 ];

=cut

sub dot {
	my ( $a, $b ) = @_;
	return ref $b ?
	  $a->[0] * $b->[0] +
	  $a->[1] * $b->[1] +
	  $a->[2] * $b->[2]
	  : $a->toString . $b
	  ;
}

=head2 cross(vec3)

	$v = $v1->cross($v2);
	$v = $v1 x $v2;
	$v = $v1 x [ 2, 3, 4 ];

=cut

sub cross {
	my ( $a, $b ) = @_;

	my ( $a0, $a1, $a2 ) = @$a;
	my ( $b0, $b1, $b2 ) = @$b;

	return $a->new(
		$a1 * $b2 - $a2 * $b1,
		$a2 * $b0 - $a0 * $b2,
		$a0 * $b1 - $a1 * $b0
	  )
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

=head2 reverse()

Returns the reverse of this vector.
This is used to overload the '~' operator.

	$v = $vec3->reverse;

=cut

=head2 rotate(n)

Performs a componentwise rotation.
This is used to overload the '>>' and '<<' operator.

	$v = $vec->rotate(1);
	$v = $vec->rotate(-2);

=cut

sub rotate {
	my $n = -$_[1] % @{ $_[0]->DefaultValue };

	if ($n) {
		my $vec = [ $_[0]->getValue ];
		splice @$vec, @{ $_[0]->DefaultValue } - $n, $n, splice( @$vec, 0, $n );
		return $_[0]->new($vec);
	}

	return $_[0]->copy;
}

=head2 toString()

Returns a string representation of the vector. This is used
to overload the '""' operator, so that vector may be
freely interpolated in strings.

	my $v = new Math::Vec3(1,2,3,4);
	print $v->toString;                # "1 2 3"
	print "$v";                        # "1 2 3"

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

