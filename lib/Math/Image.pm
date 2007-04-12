package Math::Image;

use strict;
use warnings;

our $VERSION = '0.032';

=head1 NAME

Math::Image - Perl class to represent an image

=head1 TREE

-+- L<Math::Image>

=head1 REQUIRES

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Image;
	my $i = new Math::Image;  # Make a new Image

	my $i = new Math::Image(1,2,3);

=head1 DESCRIPTION

=head2 DefaultValue

	0 0 0 []

=head1 METHODS

=head2 new

=cut

=head2 copy

=cut

=head2 setValue(width, height, components, array)

=cut

=head2 getValue

Returns the @value of the image  (width, height, components, array) as a 4 components array.

	($width, $height, $components, $array) = $i->getValue;
	@i = $i->getValue;

=cut

=head2 toString

Returns a string representation of the image. This is used
to overload the '""' operator, so that image may be
freely interpolated in strings.

	my $i = new Math::Image(0, 0, 0);
	print $c->toString; # "0 0 0"
	print "$c";         # "0 0 0"

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
