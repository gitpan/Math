package Math::Vec2;

use strict;
use warnings;

use Carp;

#use Exporter;

use overload
  '='    => \&copy,
  'bool' => sub { 1 },     # So we can do if ($foo=Math::Vec2->new) { .. }
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
  'eq'   => \&eq,
  '=='   => \&eq,
  'ne'   => \&ne,
  '!='   => \&ne,
  '""'   => \&toString,
  ;

our $VERSION = '0.01';

=head1 NAME

Math::Vec2 - Perl class to represent 2d vectors

=head1 HIERARCHY

-+- L<Math::Vec2>

=head1 SEE ALSO

L<Math::Color>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>
L<Math::Quaternion>

=head1 SYNOPSIS
	
	use Math::Vec2;
	my $v = new Math::Vec2;  # Make a new Vec2

	my $v1 = new Math::Vec2(0,1);

=head1 DESCRIPTION

=head1 METHODS

=head2 new

	my $v = new Math::Vec2; 					  
	my $v1 = new Math::Vec2($v);   
	my $v2 = new Math::Vec2(1,2);   
	my $v3 = new Math::Vec2([1,2]); 

=cut

sub new {
	my $self  = shift;
	my $class = ref($self) || $self;
	my $this  = bless [], $class;

	if ( 0 == @_ ) {
		# No arguments, default to standard
		$this->setValue( 0, 0 );
	} elsif ( 1 == @_ ) {

		my $arg1 = shift;
		my $ref  = ref($arg1);

		if ( $ref =~ /ARRAY/o ) {
			$this->setValue(@$arg1);
		} elsif ( $ref->isa("Math::Vec2") ) {
			$this->setValue(@$arg1);
		} else {
			croak("Don't understand arguments passed to new()");
		}
	} elsif ( 2 == @_ ) {    # x,y
		$this->setValue(@_);
	} else {
		croak("Don't understand arguments passed to new()");
	}

	return $this;
}

=head2 copy

Makes a copy
	
	$v2 = $v1->copy;
	$v2 = new Math::Vec2($v1);

=cut

sub copy {
	my $this = shift;
	return $this->new($this);
}

=head2 setValue(x,y,z)

Sets the value of the vector

	$v1->setValue(1,2);

=cut

sub setValue { @{ $_[0] } = @_[ 1, 2 ] }

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

Returns the @value of the vector

	@v = $v1->getValue;

=cut

sub getValue { @{ $_[0] } }

=head2 x

=cut

=head2 getX

Returns the first value of the vector.

	$y = $v1->getX;
	$y = $v1->x;
	$y = $v1->[0];

=cut

sub x : lvalue { $_[0]->[0] }
sub getX       { $_[0]->[0] }

=head2 y

=cut

=head2 getY

Returns the second value of the vector.

	$y = $v1->getY;
	$y = $v1->y;
	$y = $v1->[1];

=cut

sub y : lvalue { $_[0]->[1] }
sub getY       { $_[0]->[1] }

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
