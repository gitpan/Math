package Math::ColorRGBA;

use strict;
use warnings;

our $VERSION = '0.233';

use Math ();
use Math::Color;
use base 'Math::Vec4';

use constant getDefaultValue => [ 0, 0, 0, 0 ];

=head1 NAME

Math::ColorRGBA - Perl class to represent rgba colors

=head1 TREE

-+- L<Math::Vector> -+- L<Math::Vec4> -+- L<Math::ColorRGBA>

=head1 REQUIRES

L<Math::Color>

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::ColorRGBA;
	my $c = new Math::ColorRGBA;  # Make a new Color

	my $c1 = new Math::ColorRGBA(0,1,0,0);

=head1 DESCRIPTION

=head2 Default value

	0 0 0 0

=head1 OPERATORS

=head2 Summary

=cut

use overload
  '~' => \&inverse,

  '+='  => \&_add,
  '-='  => \&_subtract,
  '*='  => \&_multiply,
  '/='  => \&_divide,
  '**=' => \&__pow,
  '%='  => \&__mod,

  '+'  => \&add,
  '-'  => \&subtract,
  '*'  => \&multiply,
  '/'  => \&divide,
  '**' => \&_pow,
  '%'  => \&_mod,
  ;

=head1 METHODS

=head2 new(r,g,b,a)

r, g, b, a are given on [0, 1].

	my $c = new Math::ColorRGBA; 					  
	my $c2 = new Math::ColorRGBA(0, 0.5, 1, 0);   
	my $c3 = new Math::ColorRGBA([0, 0.5, 1, 1]); 

=cut

=head2 copy

Makes a copy
	
	$c2 = $c1->copy;

=cut

=head2 setValue(r,g,b,a)

Sets the value of the color.
r, g, b, a are given on [0, 1].

	$c1->setValue(0, 0.2, 1, 0);

=cut

=head2 setRGB

Sets the value of the color from a 3 component array ref ie. (L<Math::Color>).

	$c4->setRGB(new Math::Color(0.1,0.2,0.3));

=cut

sub setRGB { @{ $_[0] }[ 0, 1, 2 ] = @{ $_[1] }[ 0, 1, 2 ] }

=head2 setRed(r)

Sets the first value of the color
r is given on [0, 1].

	$c1->setRed(1);

=cut

*setRed = \&Math::Vec4::setX;
*getRed = \&Math::Vec4::getX;

=head2 setGreen(g)

Sets the second value of the color.
g is given on [0, 1].

	$c1->setGreen(0.2);

=cut

*setGreen = \&Math::Vec4::setY;
*getGreen = \&Math::Vec4::getY;

=head2 setBlue(b)

Sets the third value of the color.
b is given on [0, 1].

	$c1->setZ(0.3);

=cut

*setBlue = \&Math::Vec4::setZ;
*getBlue = \&Math::Vec4::getZ;

=head2 setAlpha(alpha)

Sets the first value of the vector

	$v1->setAlpha(1);

=cut

*setAlpha = \&Math::Vec4::setW;
*getAlpha = \&Math::Vec4::getW;

=head2 getValue

Returns the value of the color (r, g, b, a) as a 4 components array.

	@v = $c1->getValue;

=cut

sub getValue { map { Math::clamp( $_, 0, 1 ) } @{ $_[0] } }

=head2 getRGB

Returns the rgb value of the color (r, g, b) as color (L<Math::Color>).

	$c = $c4->getRGB;

=cut

sub getRGB { new Math::Color( @{ $_[0] }[ 0, 1, 2 ] ) }

=head2 getRed

Returns the first value of the color.

	$r = $c1->getRed;

=cut

=head2 getGreen

Returns the second value of the color.

	$g = $c1->getGreen;

=cut

=head2 getBlue

Returns the third value of the color.

	$b = $c1->getBlue;

=cut

=head2 getAlpha

Returns the fourth value of the color.

	$a = $v1->getAlpha;

=cut

=head2 setHSV(h,s,v,a)

h is given on [0, 2 PI]. s, v are given on [0, 1].
RGB are each returned on [0, 1].

	$c->setHSV(1/12,1,1);  # 1 0.5 0
	$c->setHSV(h,s,v);
	$c->setHSV(h,s,v,a);

=cut

sub setHSV {
	my ( $this, $h, $s, $v, $a ) = @_;

	my $c = new Math::Color;
	$c->setHSV( $h, $s, $v );

	$this->setRGB($c);
	$this->setAlpha($a) if defined $a;
}

=head2 getHSV

h is in [0, 2 PI]. s, v are each returned on [0, 1].

	@hsv = $c->getHSV;

=cut

sub getHSV { ($_[0]->getRGB->getHSV, 0) }

=head2 inverse

Returns the inverse of the color.
Inverse the first three componets (r,g,b) of the color.
This is used to overload the '~' operator.

	$v = new Math::ColorRGBA(0, 0.1, 1, 0.123);
	$v = $v1->inverse;  # 1 0.9 0 0.123
	$v = ~$v1;          # 1 0.9 0 0.123

=cut

sub inverse {
	my ($a) = @_;
	return $a->new( [
			1 - $a->[0],
			1 - $a->[1],
			1 - $a->[2],
			$a->[3],
	] );
}

=head2 add(Vec3)

Adds the RGB components. Alpha is taken from the first color.

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
			$a->[3],
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

Subtracts the RGB components of the two colors. Alpha is taken from the first color.
  
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
				$a->[3],
			  ) : (
				$a->[0] - $b->[0],
				$a->[1] - $b->[1],
				$a->[2] - $b->[2],
				$a->[3],
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
Multiplies the RGB components. Alpha is left unchanged.

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
			$a->[3],
		] )
	  :
	  $a->new( [
			$a->[0] * $b,
			$a->[1] * $b,
			$a->[2] * $b,
			$a->[3],
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

Divides the RGB components. Alpha is left unchanged.
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
				$a->[3],
			  ) : (
				$a->[0] / $b->[0],
				$a->[1] / $b->[1],
				$a->[2] / $b->[2],
				$a->[3],
			  ) ] )
	  : $a->new( [
			$a->[0] / $b,
			$a->[1] / $b,
			$a->[2] / $b,
			$a->[3],
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
				$a->[3],
			  ) : (
				Math::fmod( $a->[0], $b->[0] ),
				Math::fmod( $a->[1], $b->[1] ),
				Math::fmod( $a->[2], $b->[2] ),
				$a->[3],
			  ) ] )
	  : $a->new( [
			Math::fmod( $a->[0], $b ),
			Math::fmod( $a->[1], $b ),
			Math::fmod( $a->[2], $b ),
			$a->[3],
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
			$a->[3],
	] );
}

sub __pow {
	my ( $a, $b ) = @_;
	$a->[0]**= $b;
	$a->[1]**= $b;
	$a->[2]**= $b;
	return $a;
}

=head2 toString

Returns a string representation of the color. This is used
to overload the '""' operator, so that color may be
freely interpolated in strings.

	my $c = new Math::ColorRGBA(0.1, 0.2, 0.3);
	print $c->toString; # "0.1, 0.2, 0.3"
	print "$c";         # "0.1, 0.2, 0.3"

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

