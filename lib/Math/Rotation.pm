package Math::Rotation;

use strict;
use warnings;

use Math::Quaternion;

#use Exporter;

use overload
  '='    => \&copy,
  'neg'  => \&inverse,
  '~'    => \&inverse,
  'bool' => sub { abs( $_[0]->{quaternion}->[0] ) < 1 },    # ! $_[0]->{quaternion}->[0]->isreal
  '+'    => \&multVec,
  '*'    => \&multVec,
  'eq'   => \&eq,
  '=='   => \&eq,
  'ne'   => \&ne,
  '!='   => \&ne,
  '""'   => \&toString,
  ;

our $VERSION = '0.314';

=head1 NAME

Math::Rotation - Perl class to represent rotations

=head1 VERSION

=head1 TREE

-+- L<Math::Rotation>

=head1 REQUIRES

L<Math::Quaternion>

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Rotation;
	my $r = new Math::Rotation; # Make a new unit rotation

	# Make a rotation about the axis (0,1,0)
	my $r2 = new Math::Rotation([0,1,0], 0.1);
	my $r3 = new Math::Rotation(1, 2, 3, 4);

	my $fromVector = [1,2,3];
	my $toVector = [2,3,4];
	my $r4 = new Math::Rotation($fromVector, $toVector);

	my $r5 = $r2 + $r3;
	my $r6 = -$r5;
	
	~-$r2 == $r2;

=head1 DESCRIPTION

=head2 Default value

	0 0 1 0

=head1 METHODS

=head2 new

	# Make a new unit rotation.
	my $r = new Math::Rotation;

	my $r1 = new Math::Rotation([1,2,3],[1,2,3]); # (fromVector, toVector)

	my $r2 = new Math::Rotation(1,2,3,4);         # (x,y,z, angle)
	my $r3 = new Math::Rotation([1,2,3],4);       # (axis, angle)

=cut

sub new {
	my $self  = shift;
	my $class = ref($self) || $self;
	my $this  = bless {}, $class;

	if ( 0 == @_ ) {
		# No arguments, default to standard rotation.
		$this->{axis}       = [ 0, 0, 1 ];
		$this->{angle}      = 0;
		$this->{quaternion} = new Math::Quaternion();
	} elsif ( 2 == @_ ) {

		my $arg1    = shift;
		my $reftype = ref($arg1);

		if ( $reftype =~ /ARRAY/o ) {
			my $arg2    = shift;
			my $reftype = ref($arg2);

			if ( !$reftype ) {    # vec1, angle

				$this->setValue( @$arg1, $arg2 );

			} elsif ( $reftype =~ /ARRAY/o ) {    # vec1, vec2
				$this->private::setQuaternion( eval { Math::Quaternion::rotation( $arg1, $arg2 ) }
					  || new Math::Quaternion() );
			} else {
				warn("Don't understand arguments passed to new()");
			}
		} else {
			warn("Don't understand arguments passed to new()");
		}
	} elsif ( 4 == @_ ) {    # x,y,z,angle
		$this->setValue(@_);
	} else {
		warn("Don't understand arguments passed to new()");
	}

	return $this;
}

=head2 new_from_quaternion(new L<Math::Quaternion>)

	$r5 = new_from_quaternion Math::Rotation(new Math::Quaternion);

=cut

sub new_from_quaternion {
	return $_[0]->private::new_from_quaternion( new Math::Quaternion( $_[1] ) );
}

sub private::new_from_quaternion {
	my $self  = shift;
	my $class = ref($self) || $self;
	my $this  = bless {}, $class;

	$this->private::setQuaternion(shift);

	return $this;
}

=head2 copy

Makes a copy
	
	$r2 = $r1->copy;

=cut

sub copy {
	my $this = shift;
	return $this->private::new_from_quaternion( $this->{quaternion} );
}

=head2 setValue(x,y,z, angle)

Sets value of rotation from axis angle.

	$r->setValue(1,2,3,4);

=cut

sub setValue {
	my $this = shift;
	if ( $_[0] + $_[1] + $_[2] ) {
		$this->{axis}       = [ @_[ 0, 1, 2 ] ];
		$this->{angle}      = $_[3];
		$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
	} else {
		$this->{axis}       = [ 0, 0, 1 ];
		$this->{angle}      = 0;
		$this->{quaternion} = new Math::Quaternion();
	}
}

=head2 setX(x)

Sets the first value of the axis vector

	$r->setX(1);

=cut

sub setX {
	my $this = shift;
	$this->{axis}->[0] = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=head2 setY(y)

Sets the second value of the axis vector

	$r->setY(2);

=cut

sub setY {
	my $this = shift;
	$this->{axis}->[1] = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=head2 setZ(z)

Sets the third value of the axis vector

	$r->setZ(3);

=cut

sub setZ {
	my $this = shift;
	$this->{axis}->[2] = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=head2 setAxis(x,y,z)


=cut

=head2 setAxis([x,y,z])

Sets axis of rotation from a 3 components array.

	$r->setAxis(1,2,3);
	$r->setAxis([1,2,3]);

=cut

sub setAxis {
	my $this = shift;
	@{ $this->{axis} } = ref( $_[0] ) =~ /ARRAY/o ? @{ $_[0] } : @_;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=head2 setAngle(angle)

Sets angle of rotation in L<radiants|http://en.wikipedia.org/wiki/Radian>.

	$r->setAngle(4);

=cut

sub setAngle {
	my $this = shift;
	$this->{angle} = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=head2 setQuaternion(L<quaternion|Math::Quaternion>)

Sets value of rotation from a quaternion.

	$r->setQuaternion(new Math::Quaternion(1,2,3,4));

=cut

sub setQuaternion {
	my $this = shift;
	$this->private::setQuaternion( eval { new Math::Quaternion(shift) } || new Math::Quaternion() );
}

sub private::setQuaternion {
	my $this = shift;
	my $q    = shift;
	$this->{quaternion} = $q;
	@{ $this->{axis} } = $q->rotation_axis;
	$this->{angle} = $q->rotation_angle;
}

=head2 getValue

Returns corresponding 3D rotation (x, y, z, angle) as a 4 components array.

	($x, $y, $z, $angle) = $r->getValue;
	
	$v4 = [ $r->getValue ];

=cut

sub getValue {
	my $this = shift;

	$this->private::setQuaternion( $this->{quaternion} );

	return (
		$this->getAxis,
		$this->getAngle
	);
}

=head2 x

=cut

=head2 getX

Returns the first value of the axis vector.

	$x = $r->x
	$x = $r->getX;

=cut

sub x    { $_[0]->{axis}->[0] }
sub getX { $_[0]->{axis}->[0] }

=head2 y

=cut

=head2 getY

Returns the second value of the axis vector.

	$y = $r->y;
	$y = $r->getY;

=cut

sub y    { $_[0]->{axis}->[1] }
sub getY { $_[0]->{axis}->[1] }

=head2 z

=cut

=head2 getZ

Returns the third value of the axis vector

	$z = $r->z;
	$z = $r->getZ;

=cut

sub z    { $_[0]->{axis}->[2] }
sub getZ { $_[0]->{axis}->[2] }

=head2 axis

Returns the axis of rotation as an $array.
This function is experimental

	$axis = $r->axis;

=cut

sub axis { $_[0]->{axis} }

=head2 getAxis

Returns the axis of rotation as an @array.

	@axis = $r->getAxis;

=cut

sub getAxis { @{ $_[0]->{axis} } }

=head2 angle

=cut

=head2 getAngle

Returns corresponding 3D rotation angle in L<radiants|http://en.wikipedia.org/wiki/Radian>.

	$angle = $r->angle;
	$angle = $r->getAngle;

=cut

sub angle    { $_[0]->{angle} }
sub getAngle { $_[0]->{angle} }

=head2 quaternion

Returns corresponding L<quaternion|Math::Quaternion>.
This function is experimental

=cut

sub quaternion { $_[0]->{quaternion} }

=head2 getQuaternion

Returns a copy of the corresponding L<quaternion|Math::Quaternion>.
	
	$q = $r->getQuaternion;

=cut

sub getQuaternion { new Math::Quaternion( $_[0]->{quaternion} ) }

=head2 inverse

Returns a Math::Rotation object whose value is the inverse of this object's rotation.
	
	$i = $r->inverse;
	$i = -$r;
	$i = ~$r;

=cut

# (1,2,3, 4) -> (1,2,3, -4)
sub inverse { $_[0]->private::new_from_quaternion( $_[0]->{quaternion}->inverse ) }

=head2 multiply(rotation)

Returns an Math::Rotation whose value is the object multiplied by the passed Math::Rotation.
	
	$r = $r1->multiply($r2);
	$r = $r1 * $r2;

	$r1 *= $r1;

	$r = $r1 + $r2;

=cut

sub multiply { $_[0]->private::new_from_quaternion( $_[1]->{quaternion}->multiply( $_[0]->{quaternion} ) ) }

=head2 multVec(x,y,z)

=cut

=head2 multVec([x,y,z])

Returns an array whose value is the 3D vector [x,y,z] multiplied by the matrix corresponding to this object's rotation.

	$v = $r->multVec([1,2,3]);
	@v = $r->multVec(1,2,3);

	$v = $r1 * [1,2,3];
	$v = $r1 * Math::Vec3->new(1,2,3);

	$v = $r->multVec(new Math::Vec3(1,2,3));
	ref($v) eq "Math::Vec3";

=cut

sub multVec {
	my $this = shift;
	if ( @_ < 3 ) {
		my $ref = ref( $_[0] );
		if ( $ref =~ /ARRAY/o || $ref->isa("Math::Vec3") ) {
			my @v = $this->{quaternion}->rotate_vector( @{ $_[0] } );
			return ref( $_[0] ) eq "ARRAY" ? [@v] : $_[0]->new(@v);
		} else {
			return $this->multiply( $_[0] );
		}
	} elsif ( @_ < 4 ) {
		return $this->{quaternion}->rotate_vector(@_);
	} else {
		return $this->multiply( $this->new(@_) );
	}
}

=head2 slerp(destRotation, t)

Returns a Math::Rotation object whose value is the spherical linear interpolation between this object's
rotation and destRotation at value 0 <= t <= 1. For t = 0, the value is this object's rotation.
For t = 1, the value is destRotation.

	$r = $r1->slerp($r2, $_) foreach map {$_/10} (1..10);

=cut

sub slerp { $_[0]->private::new_from_quaternion( $_[0]->{quaternion}->slerp( $_[1]->{quaternion}, $_[2] ) ) }

=head2 neq(rotation)

	my $bool = $r1 == $r2;

=cut

sub neq {
	my ( $a, $b ) = @_;
	return $a eq $b;
}

=head2 eq(rotation)

	my $bool = $r1 eq $r2;

=cut

sub eq {
	my ( $a, $b ) = @_;
	return "$a" eq $b;
}

=head2 nne(rotation)

	my $bool = $r1 != $r2;

=cut

sub nne {
	my ( $a, $b ) = @_;
	return $a ne $b;
}

=head2 ne(rotation)

	my $bool = $r1 ne $r2;

=cut

sub ne {
	my ( $a, $b ) = @_;
	return "$a" ne $b;
}

=head2 toString

Returns a string representation of the rotation. This is used
to overload the '""' operator, so that rotations may be
freely interpolated in strings.

	my $q = new Math::Rotation(1,2,3,4);
	print $q->toString;                # "1 2 3 4"
	print "$q";                        # "1 2 3 4"

=cut

sub toString {
	my $this = shift;
	return join " ", $this->getValue;
}

1;

=head1 SEE ALSO

L<Math>

L<Math::Quaternion>

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
