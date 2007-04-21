package Math::Image;

use strict;
use warnings;

our $VERSION = '0.017';

#use PDL;

#use constant getDefaultValue => [ 0, 0, 0 ];

=head1 NAME

Math::Image - Perl class to represent an image

=head1 TREE

-+- L<Math::Image>

=head1 REQUIRES

=head1 SEE ALSO

L<PDL> for scientific and bulk numeric data processing and display

L<Math>

L<Math::Vectors>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	use Math::Image;
	my $i = new Math::Image;  # Make a new Image

	my $i = new Math::Image(1,2,3);

=head1 DESCRIPTION

=head2 Default value

	0 0 0

=head1 OPERATORS

=head2 Summary

	'""'		=>   Returns a string representation of the vector.

=cut

use overload
  #  '=' => \&copy,
  '""' => \&toString,
  ;

=head1 METHODS

=head2 new(w, h, components, array)

w is the width of the image. h is height of the image.
comp is the number of components of the image, 1 for greyscale, 2 for greyscale+alpha, 3 for rgb, 4 for rgb+alpha).
All these values are scalar. Array is an array ref containing the w*h values for the pixels of the image.

Format of each pixel:


	Comp.   byte[0]    byte[1]     byte[2]    byte[3]
	------- ---------- ---------- ----------- -----------
	   1    intensity1 intensity2  intensity3  intensity4
	   2    intensity1   alpha1    intensity2   alpha2 
	   3       red1      green1      blue1       red2
	   4       red1      green1      blue1      alpha1



Examples:

	$v = new Math::Image();
	$v = new Math::Image( 2, 2, 4, [ 0xABCDEFAB, 0xABCDEFAB, 0xABCDEABF, 0xABCDABEF ] );

=cut

sub new {
	my $self  = shift;
	my $class = ref($self) || $self;
	my $this  = bless {}, $class;

	if ( 0 == @_ ) {
		$this->setValue( 0, 0, 0, [] );
		return $this;
	} elsif ( 3 == @_ ) {
		$this->setValue( @_, [] );
		return $this;
	} elsif ( 4 == @_ ) {
		$this->setValue(@_);
		return $this;
	} else {
		warn("Don't understand arguments passed to new()");
	}

	return;
}

=head2 copy

Not implemented yet.

=cut

sub copy { $_[0]->new( $_[0]->getValue ) }

=head2 setValue(width, height, components, array)

=cut

sub setValue {
	my ( $this, $width, $height, $components, $array ) = @_;

	$this->{width}      = $width;
	$this->{height}     = $height;
	$this->{components} = $components;
	$this->{array}      = $array;

	return;
}

=head2 setWidth(width)

Not implemented yet.

=cut

=head2 setHeight(height)

Not implemented yet.

=cut

=head2 setComponents(comp)

Not implemented yet.

=cut

=head2 setArray(array)

Not implemented yet.

=cut

=head2 getValue

Returns the value of the image  (width, height, components, array) as a 4 components array.

	($width, $height, $components, $array) = $i->getValue;
	@i = $i->getValue;

=cut

sub getValue {
	my ($this) = @_;
	return (
		$this->{width},
		$this->{height},
		$this->{components},
		[ @{ $this->{array} } ] );
}

=head2 getWidth

Not implemented yet.

=cut

=head2 getHeight

Not implemented yet.

=cut

=head2 getComponents

Not implemented yet.

=cut

=head2 getArray

Not implemented yet.

=cut

=head2 toString

Returns a string representation of the image. This is used
to overload the '""' operator, so that image may be
freely interpolated in strings.

	my $i = new Math::Image(0, 0, 0);
	print $c->toString; # "0 0 0"
	print "$c";         # "0 0 0"

=cut

sub toString {
	my $this = shift;

	return "0 0 0" unless $this->{width} * $this->{height};

	my $format;

	$format = "0x%x " x $this->{width};
	$format = substr $format, 0, -1;
	$format = $format . "\n";
	$format x= $this->{height};
	$format = substr $format, 0, -length "\n";

	$format = "%s %s %s" . "\n" . $format;

	my $string .= sprintf $format,
	  $this->{width},
	  $this->{height},
	  $this->{components},
	  @{ $this->{array} };

	return $string;
}

1;

=head1 SEE ALSO

L<PDL> for scientific and bulk numeric data processing and display

L<Math>

L<Math::Vectors>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 BUGS & SUGGESTIONS

If you run into a miscalculation please drop the author a note.

=head1 ARRANGED BY

Holger Seelig  holger.seelig@yahoo.de

=head1 COPYRIGHT

This is free software; you can redistribute it and/or modify it
under the same terms as L<Perl|perl> itself.

=cut

