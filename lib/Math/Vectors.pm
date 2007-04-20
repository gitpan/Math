package Math::Vectors;

use strict;
use warnings;

our $VERSION = '0.0041';

use Math::Color;
use Math::ColorRGBA;
use Math::Image;
use Math::Rotation;
use Math::Vec2;
use Math::Vec3;
use Math::Vec4;

=head1 NAME

Math::Color - Perl class to represent colors

=head1 TREE

-+- L<Math::Vector> -+- L<Math::Vec3> -+- L<Math::Color>

=head1 SEE ALSO

L<PDL> for scientific and bulk numeric data processing and display

L<Math>

L<Math::Vectors>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Vectors;

	new Math::Color;
	new Math::ColorRGBA;
	new Math::Image;
	new Math::Rotation;
	new Math::Vec2;
	new Math::Vec3;
	new Math::Vec4;

=head1 BUGS & SUGGESTIONS

If you run into a miscalculation or need some sort of feature please drop the author a note.

=head1 ARRANGED BY

Holger Seelig  holger.seelig@yahoo.de

=head1 COPYRIGHT

This is free software; you can redistribute it and/or modify it
under the same terms as L<Perl|perl> itself.

=cut

1;
__END__
