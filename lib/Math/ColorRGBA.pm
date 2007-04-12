package Math::ColorRGBA;

use strict;
use warnings;

our $VERSION = '0.208';

use base 'Math::Color';

use constant DefaultValue => [ 0, 0, 0, 0 ];

=head1 NAME

Math::ColorRGBA - Perl class to represent rgba colors

=head1 TREE

-+- L<Math::ColorRGBA>

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::ColorRGBA;
	my $c = new Math::ColorRGBA;  # Make a new Color

	my $c1 = new Math::ColorRGBA(0,1,0,0);

=head1 DESCRIPTION

=head2 DefaultValue

	0 0 0 0

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

=head2 setRed(r)

Sets the first value of the color
r is given on [0, 1].

	$c1->setRed(1);

	$c1->red = 1;
	$c1->r   = 1;
	$c1->[0] = 1;

=cut

=head2 setGreen(g)

Sets the second value of the color.
g is given on [0, 1].

	$c1->setGreen(0.2);

	$c1->green = 0.2;
	$c1->g   = 0.2;
	$c1->[1] = 0.2;

=cut

=head2 setBlue(b)

Sets the third value of the color.
b is given on [0, 1].

	$c1->setZ(0.3);

	$c1->z   = 0.3;
	$c1->[2] = 0.3;

=cut

=head2 setAlpha(alpha)

Sets the first value of the vector

	$v1->setAlpha(1);

	$v1->alpha = 1;
	$v1->[3] = 1;

=cut

sub setAlpha { $_[0]->[3] = $_[1] }

=head2 getValue

Returns the value of the color (r, g, b, a) as a 4 components array.

	@v = $c1->getValue;

=cut

=head2 getRed

Returns the first value of the color.

	$r = $c1->getRed;
	$r = $c1->red;
	$r = $c1->r;
	$r = $c1->[0];

=cut

=head2 getGreen

Returns the second value of the color.

	$g = $c1->getGreen;
	$g = $c1->green;
	$g = $c1->g;
	$g = $c1->[1];

=cut

=head2 alpha

=cut

=head2 getBlue

Returns the third value of the color.

	$b = $c1->getBlue;
	$b = $c1->blue;
	$b = $c1->b;
	$b = $c1->[2];

=cut

=head2 alpha

=cut

=head2 getAlpha

Returns the fourth value of the color.

	$a = $v1->getAlpha;
	$a = $v1->alpha;
	$a = $v1->[3];

=cut

sub alpha    { $_[0]->[3] }
sub getAlpha { $_[0]->[3] }

=head2 setHSV(h,s,v)

h, s, v are given on [0, 1].
RGB are each returned on [0, 1].

	$c->setHSV(1/12,1,1);  # 1 0.5 0

=cut

=head2 getHSV

h, s, v are each returned on [0, 1].

	@hsv = $c->getHSV;

=cut

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

