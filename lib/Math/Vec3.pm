package Math::Vec3;

use strict;
use warnings;

#use Exporter;

use base 'Math::Vec2';

use overload
  #  '='    => \&copy,
  'bool' => \&length,
  'neg'  => \&negate,
  '+='   => \&_add,
  '-='   => \&_subtract,
  '*='   => \&_multiply,
  '/='   => \&_divide,
  '+'    => \&add,
  '-'    => \&subtract,
  '*'    => \&multiply,
  '/'    => \&divide,
  '.'    => \&dot,
  'x'    => \&cross,
  #  'eq'   => \&eq,
  #  '=='   => \&eq,
  #  'ne'   => \&ne,
  #  '!='   => \&ne,
  #  '""'   => \&toString,
  ;

our $VERSION = '0.283';

use constant DefaultValue => [0, 0, 0];

=head1 NAME

Math::Vec3 - Perl class to represent 3d vectors

=head1 TREE

-+- L<Math::Vec2> -+- L<Math::Vec3>

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Vec3;
	my $v = new Math::Vec3;  # Make a new vec3

	my $v1 = new Math::Vec3(0,1,0);

=head1 DESCRIPTION

=head2 DefaultValue

	0 0 0

=head1 METHODS

=head2 new

Derived from L<Math::Vec2/new>.

=cut

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
	return ref $b ?
	  $a->new(
		$a->[1] * $b->[2] - $a->[2] * $b->[1],
		$a->[2] * $b->[0] - $a->[0] * $b->[2],
		$a->[0] * $b->[1] - $a->[1] * $b->[0]
	  )
	  : $a->toString x $b
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
		  $a->[1] * $a->[1] +
		  $a->[2] * $a->[2]
	);
}

=head2 normalize

	$v = $v1->normalize;

=cut

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

L<Math::Color>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

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

