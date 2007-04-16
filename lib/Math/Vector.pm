package Math::Vector;

use strict;
use warnings;

our $VERSION = '1.708';

use Math ();

=head1 NAME

Math::Vector - Abstract base class for vector classes

=head1 TREE

-+- L<Math::Vector>

=head1 SEE ALSO

L<Math>

L<Math::Color>, L<Math::ColorRGBA>, L<Math::Image>, L<Math::Vec2>, L<Math::Vec3>, L<Math::Rotation>

=head1 SYNOPSIS
	
	package Math::VecX;
	use base 'Math::Vector';
	use constant getDefaultValue => [ 0, 0 ];
	1;

=head1 DESCRIPTION

=head1 OPERATORS

=head2 Summary
	
	'!'		=>   Returns true if the length of this vector is 0
	
	'<'		=>   Numerical gt. Compares the length of this vector with a vector or a scalar value.
	'<='		=>   Numerical le. Compares the length of this vector with a vector or a scalar value.
	'>'		=>   Numerical lt. Compares the length of this vector with a vector or a scalar value.
	'>='		=>   Numerical ge. Compares the length of this vector with a vector or a scalar value.
	'<=>'		=>   Numerical cmp. Compares the length of this vector with a vector or a scalar value.
	'=='		=>   Numerical eq. Performs a componentwise equation.
	'!='		=>   Numerical ne. Performs a componentwise equation.
	
	'lt'		=>   Stringwise lt
	'le'		=>   Stringwise le
	'gt'		=>   Stringwise gt
	'ge'		=>   Stringwise ge
	'cmp'		=>   Stringwise cmp
	'eq'		=>   Stringwise eq
	'ne'		=>   Stringwise ne
	
	'abs'		=>   Performs a componentwise abs.
	
	'""'		=>   Returns a string representation of the vector.

=cut

use overload
  '=' => \&copy,

  #'>>' => \&rotate,
  #'<<' => sub { $_[0]->rotate( -$_[1] ) },

  #'~' => sub { $_[0]->new( [ CORE::reverse @{ $_[0] } ] ) },

  '<'   => sub { $_[1] > $_[0]->length },
  '<='  => sub { $_[1] >= $_[0]->length },
  '>'   => sub { $_[1] < $_[0]->length },
  '>='  => sub { $_[1] <= $_[0]->length },
  '<=>' => sub { $_[1] <=> $_[0]->length },
  '=='  => sub { "$_[0]" eq $_[1] },
  '!='  => sub { "$_[0]" ne $_[1] },

  'lt'  => sub { $_[1] gt "$_[0]" },
  'le'  => sub { $_[1] ge "$_[0]" },
  'gt'  => sub { $_[1] lt "$_[0]" },
  'ge'  => sub { $_[1] le "$_[0]" },
  'cmp' => sub { $_[1] cmp "$_[0]" },
  'eq'  => sub { "$_[0]" eq $_[1] },
  'ne'  => sub { "$_[0]" ne $_[1] },

  'abs' => \&abs,

  '""' => \&toString,
  ;

=head1 METHODS

=head2 new

	my $v = new Math::VecX; 					  
	my $v2 = new Math::VecX(1,2);
	my @v3 = @$v; 
	
If you call new() with a reference to an array, it will be used as reference.

	my $v3 = new Math::VecX([1,2]); 

=cut

sub new {
	my $self = shift;
	my $class = ref($self) || $self;

	if ( 0 == @_ ) {
		# No arguments, default to standard
		return bless [ @{ $self->getDefaultValue } ], $class;
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

sub copy { $_[0]->new( [ $_[0]->getValue ] ) }

=head2 getArray

Returns the reference to the array.

	$a = $v1->getArray;

=cut

sub getArray { $_[0] }

=head2 setValue(x,y,z)

Sets the value of the vector

	$v1->setValue(1,2);

=cut

=head2 getValue

Returns the value of the vector (x, y) as a 2 components array.

	@v = $v1->getValue;

=cut

sub getValue { @{ $_[0] } }

=head2 setValue(x,y,z)

Sets the value of the vector

	$v1->setValue(1,2);

=cut

sub setValue {
	my $this = shift;

	@$this = map {

		exists $_[$_] ? $_[$_] : $this->getDefaultValue->[$_]

	} 0 .. $#{ $this->getDefaultValue };

	return;
}

=head2 abs()

Performs a componentwise abs.
This is used to overload the 'abs' operator.

=cut

sub abs { $_[0]->new( [ map { CORE::abs($_) } @{ $_[0] } ] ) }

=head2 rotate(n)

Performs a componentwise rotation.

	$v = $vec->rotate(1);
	$v = $vec->rotate(-2);

=cut

sub rotate {
	my $n = -$_[1] % @{ $_[0]->getDefaultValue };

	if ($n) {
		my $vec = [ $_[0]->getValue ];
		splice @$vec, @{ $_[0]->getDefaultValue } - $n, $n, splice( @$vec, 0, $n );
		return $_[0]->new($vec);
	}

	return $_[0]->copy;
}

=head2 sig

Performs a componentwise sig.

	$v = new Math::VecX(-4, 5);
	$v = $VecX->sig;
	printf $v;         # -1 1

=cut

#sub sig { $_[0]->new( [ map { Math::sig($_) } @{ $_[0] } ] ) }
sub sig { $_[0]->new( [ map { $_ ? ( $_ < 0 ? -1 : 1 ) : 0 } @{ $_[0] } ] ) }

=head2 sum

Returns the sum of the components.

	$v = new Math::VecX(-8, 2);
	$s = $VecX->sum;
	printf $s;         # -6

=cut

sub sum {
	my $sum = 0;
	$sum += $_ foreach @{ $_[0] };
	return $sum;
}

=head2 normalize

	$v = $v1->normalize;

=cut

sub normalize { $_[0] / $_[0]->length }

=head2 toString

Returns a string representation of the vector. This is used
to overload the '""' operator, so that vector may be
freely interpolated in strings.

	my $q = new Math::VecX(1,2);
	print $q->toString;                # "1 2"
	print "$q";                        # "1 2"

=cut

sub toString {
	return join " ", $_[0]->getValue;
}

=head1 BUGS & SUGGESTIONS

If you run into a miscalculation please drop the author a note.

=head1 ARRANGED BY

Holger Seelig  holger.seelig@yahoo.de

=head1 COPYRIGHT

This is free software; you can redistribute it and/or modify it
under the same terms as L<Perl|perl> itself.

=cut

1;
__END__
