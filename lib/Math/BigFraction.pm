#!/usr/bin/perl -w

# experimental Math::BigFloat package, based upon Math::BigInt and using
# internally a/b representation to achive infinite precision.

# 2000-11-26 v0.0.1 Tels
# 2001-03-30 v0.0.2 Tels
 
# The following hash values are used:
#   a and b, two bigints representing the floating point number by a/b.
#   sign: the sign of the number (a and b are absolute)

package Math::BigFraction;
my $class = "Math::BigFraction";

$VERSION = 1 / 100; 	# ;)

use Exporter;
use Math::BigInt qw/objectify/;
@ISA =       qw( Exporter Math::BigInt);
@EXPORT_OK = qw( 
                  is_zero is_one sign
	       );
#bneg babs bcmp badd bmul bdiv bmod bnorm bsub
#                 bgcd blcm 
#                 blsft brsft band bior bxor bnot bpow bnan bzero 
#                 bacmp bstr binc bdec bint
#                 is_odd is_even 
#               ); 

@EXPORT = qw( );
use strict;

# no overload yet

# are NaNs ok?
my $NaNOK=1;
# set to 1 for tracing
my $trace = 0;
# constant for easier life
my $nan = 'NaN'; 
my $precision = 12;

##############################################################################
# constructors

sub new 
  {
  # create a new BigFraction object from a string or another object. 

  trace (@_);
  my $class = shift;
  my $self = {};
 
  my ($wa,$wb) = @_;
  # avoid numify call by not using || here
  return $class->bzero() if !defined $wa;      # default to 0
  $wb = 1 if !defined $wb;
  $wa = 0 if !defined $wa;
  $wa = Math::BigInt->new($wa) unless ref($wa); 
  $wb = Math::BigInt->new($wb) unless ref($wb);  # objectify
  $self->{sign} = '+'; $self->{sign} = '-' if $wa->sign() ne $wb->{sign};
  $self->{a} = $wa->babs(); $self->{a}->{sign} = $self->{sign}; 
  $self->{b} = $wb->babs(); 
  bless $self, $class;

  return $self->_reduce();
  }

sub bnan
  {
  # create a bigint 'NaN', if given a BigInt, set it to 'NaN'
  my $self = shift;
  $self = $class if !defined $self;
  if (!ref($self))
    {
    my $c = $self; $self = {}; bless $self, $c;
    }
  $self->{a} = Math::BigInt->bzero();
  $self->{b} = Math::BigInt->bzero();
  $self->{sign} = $nan;
  trace('NaN');
  return $self;
  }

sub bzero
  {
  # create a bigint '+0', if given a BigInt, set it to 0
  my $self = shift;
  $self = $class if !defined $self;
  if (!ref($self))
    {
    my $c = $self; $self = {}; bless $self, $c;
    }
  $self->{a} = Math::BigInt->bzero();
  $self->{b} = Math::BigInt->_one();
  $self->{sign} = '+';
  trace('0');
  return $self;
  }

##############################################################################
# string conversation

sub bstr 
  {
  # (ref to BINT or num_str ) return num_str
  # Convert number from internal format to string format.
  # internal format is always normalized (no leading zeros, "-0" => "+0")
  # second parameter is number of digits after '.'
  trace(@_);
  my $p = $_[2]; (defined $p) ? (pop @_) : ($p = $precision);
  my ($self,$x) = objectify(1,@_);
  
  # not done yet
  return $x->{a}->bstr() . ' / ' . $x->{b}->bstr();
  }

sub numify 
  {
  # Make a number from a BigFloat object
  # simple return string and let Perl's atoi() handle the rest
  trace (@_);
  my ($self,$x) = objectify(1,@_);
  return $x->{a}->numify() / $x->{b}->numify(); 
  }

sub _reduce
  {
  # reduce a/b to lowest a and b, by finding g = gcd (a,b) and the a/g and b/g
  # we could cache wether a/b is already reduced or not
  my ($self,$x) = objectify(1,@_);

  # don't do anything for NaNs  
  $x->bnan() if $x->{b}->{sign} eq $nan;
  return if $x->{a}->{sign} eq $nan;

  my $g = Math::BigInt::bgcd ($x->{a},$x->{b});
  $x->{a}->bdiv($g);
  $x->{b}->bdiv($g);
  $x;
  }

##############################################################################
# public stuff (usually prefixed with "b")

sub bneg
  {
  trace(@_);
  my ($self,$x) = objectify(1,@_);
  $x->{sign} =~ tr/+-/-+/;
  $x;
  }

sub babs
  {
  trace(@_);
  my ($self,$x) = objectify(1,@_);
  $x->{sign} = s/-/+/;
  $x;
  }

sub bcmp 
  {
  # Compares 2 values.  Returns one of undef, <0, =0, >0. (suitable for sort)
  # (BINT or num_str, BINT or num_str) return cond_code
  my ($self,$x,$y) = objectify(2,@_);
  return undef if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));

  return $x->{a}->bcmp($y->{a}) && $x->{a}->bcmp($y->{b});
  }

sub bacmp 
  {
  # Compares 2 values, ignoring their signs. 
  # Returns one of undef, <0, =0, >0. (suitable for sort)
  # (BINT, BINT) return cond_code
  my ($self,$x,$y) = objectify(2,@_);
  return undef if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));
  return $x->{a}->bacmp($y->{a}) && $x->{a}->bacmp($y->{b});
  }

sub badd 
  {
  # add second arg (BINT or string) to first (BINT) (modifies first)
  # return result as BINT
  trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  return $x->bnan() if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));
 
  # xa/xb + ya/yb => xa*yb+ya*xb / xb*yb
 
  $x->{a}->bmul($y->{b});
  $x->{a}->badd( $y->{a} * $x->{b} );
  $x->{b}->bmul($y->{b});
  return $x->_reduce();
  }

sub bsub 
  {
  # (BINT or num_str, BINT or num_str) return num_str
  # subtract second arg from first, modify first
  my ($self,$x,$y) = objectify(2,@_);

  trace(@_);
  &badd($x,$y->bneg()); # badd does not leave internal zeros
  $y->bneg();           # refix y, assumes no one reads $y in between
  return $x;   
  }

sub binc
  {
  # increment arg by one
  my ($self,$x) = objectify(1,@_);
  trace(@_);
  $x->badd($self->_one());
  }

sub bdec
  {
  # decrement arg by one
  my ($self,$x) = objectify(1,@_);
  trace(@_);
  $x->badd($self->_one('-'));
  } 

sub bmod 
  {
  # modulus
  # (BINT or num_str, BINT or num_str) return BINT
  (&bdiv(@_))[1];
  }

sub bnot 
  {
  # (num_str or BINT) return BINT
  # represent ~x as twos-complement number
  my ($self,$x) = objectify(1,@_);
  $x->bneg(); $x->bdec(); # was: bsub(-1,$x);, time it someday
  $x;
  }

sub is_zero
  {
  # return true if arg (BINT or num_str) is zero (array '+', '0')
  my ($self,$x) = objectify(1,@_);
  trace(@_);
  return $x->{a}->is_zero();
  }

sub is_one
  {
  # return true if arg (BINT or num_str) is +1 (array '+', '1')
  # or -1 if signis given
  my $sign = $_[2]; (defined $sign) ? (pop @_) : ($sign = '+');
  my ($self,$x) = objectify(1,@_); 
  return 1 if $x->{a}->is_one($sign) && $x->{b}->is_one();
  return undef;
  }

# not ready yet
sub is_odd
  {
  # return true when arg (BINT or num_str) is odd, false for even
  my ($self,$x) = objectify(1,@_);
  return (($x->{sign} ne $nan) && ($x->{value}->[0] & 1));
  }

sub is_even
  {
  # return true when arg (BINT or num_str) is even, false for odd
  my ($self,$x) = objectify(1,@_);
  return (($x->{sign} ne $nan) && (!($x->{value}->[0] & 1)));
  }

sub bmul 
  { 
  # multiply two numbers -- stolen from Knuth Vol 2 pg 233
  # (BINT or num_str, BINT or num_str) return BINT
  my ($self,$x,$y) = objectify(2,@_);
  trace(@_);
  return $x->bnan() if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));

  # a/b * c/d = a*c / b*d
 
  $x->{a}->bmul($y->{a});
  $x->{b}->bmul($y->{b});
  $x->_reduce();
  }

sub bdiv 
  {
  # (dividend: BINT or num_str, divisor: BINT or num_str) return 
  # (BINT,BINT) (quo,rem) or BINT (only rem)
  # returns only quotient
  trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  # a/b / c/d = a/b * d/c => a*d / b*c
  
  $x->{a}->bmul($y->{b});
  $x->{b}->bmul($y->{a});
  $x->_reduce();
  }

sub bpow 
  {
  # (BINT or num_str, BINT or num_str) return BINT
  # compute power of two numbers -- stolen from Knuth Vol 2 pg 233
  # modifies first argument

  my ($self,$x,$y) = objectify(2,@_);

  # a/b ** c/d = a**c/d / b**c/d
  # a**c/d =>

  # not ready yet
  return $x;
  }

##############################################################################
# private stuff (internal use only)

sub trace
  {
  # print out a number without using bstr (avoid deep recurse) for trace/debug
  return unless $trace;

  my ($package,$file,$line,$sub) = caller(1); 
  print "'$sub' called from '$package' line $line:\n ";

  foreach my $x (@_)
    {
    if (!defined $x) 
      {
      print "undef, "; next;
      }
    if (!ref($x)) 
      {
      print "'$x' "; next;
      }
    next if (ref($x) ne "HASH");
    print "$x->{sign} ";
    foreach (@{$x->{value}})
      {
      print "$_ ";
      }
    print ", ";
    }
  print "\n";
  }

sub _one
  {
  # test: internal speedup, creata a +/- 1
  my $class = shift;
  my $x = {}; bless $x,$class;
  $x->{b} = Math::BigInt::->_one(); 
  $x->{a} = Math::BigInt::->bzero(); 
  $x->{sign} = shift || '+'; # a & b are always '+'
  $x;
  }

sub import 
  {
  my $self = shift;
  return unless @_; # do nothing for empty import lists 
  # any non :constant stuff is handled by our parent, Exporter
  return $self->export_to_level(1,$self,@_) 
   unless @_ == 1 and $_[0] eq ':constant';
  # the rest causes overlord er load to step in
  overload::constant integer => sub { $self->new(@_) };
  }

1;
__END__

=head1 NAME

Math::BigFraction - Arbitrary size floating point fractions

=head1 SYNOPSIS

  use Math::BigFraction;

  # Number creation	
  $x = Math::BigFraction->new($str);	# from string, like "-0.3333333333"
  $x = Math::BigFraction->new($u,$v);	# from $u / $v, like 1/3, if $v 
					# is missing, +1 is assumed
  $nan  = Math::BigFraction->bnan(); 	# create a NotANumber
  $zero = Math::BigFraction->bzero();	# create a "+0"

  # Testing
  $x->is_zero();		# return wether arg is zero or not
  $x->is_one();			# return true if arg is +1
  $x->is_one('-');		# return true if arg is -1
  #$x->is_odd();		# return true if odd, false for even
  #$x->is_even();		# return true if even, false for odd
  $x->bcmp($y);			# compare numbers (undef,<0,=0,>0)
  $x->bacmp($y);		# compare absolutely (undef,<0,=0,>0)
  $x->sign();			# return the sign, either +,- or NaN

	# rest not ready yet
  # The following all modify their first argument:

  # set 
  $x->bzero();			# set $i to 0
  $x->bnan();			# set $i to NaN

  $x->bneg();			# negation
  $x->babs();			# absolute value
  $x->bnorm();			# normalize (no-op)
  $x->bnot();			# two's complement (bit wise not)
  $x->binc();			# increment x by 1
  $x->bdec();			# decrement x by 1
  
  $x->badd($y);			# addition (add $y to $x)
  $x->bsub($y);			# subtraction (subtract $y from $x)
  $x->bmul($y);			# multiplication (multiply $x by $y)
  $x->bdiv($y);			# divide, set $i to quotient
				# return (quo,rem) or quo if scalar

  $x->bmod($y);			# modulus
  $x->bpow($y);			# power of arguments (a**b)
  $x->blsft($y);		# left shift
  $x->brsft($y);		# right shift 
				# return (quo,rem) or quo if scalar
  
  $x->band($y);			# bit-wise and
  $x->bior($y);			# bit-wise inclusive or
  $x->bxor($y);			# bit-wise exclusive or
  $x->bnot();			# bit-wise not (two's complement)
  
  # The following do not modify their arguments:

  bgcd(@values);		# greatest common divisor
  blcm(@values);		# lowest common multiplicator
  
  $x->bstr($precision);		# return $precision digits after . (default
				# is $Math::BigFloat::precision

=head1 DESCRIPTION

All operators (inlcuding basic math operations) are overloaded if you
declare your big fractions as

  $i = Math::BigFraction->new('123456789','1234567');

Operations with overloaded operators preserve the arguments which is
exactly what you expect.

=over 2

=item Canonical notation

Big integer values are strings of the form C</^[+-]\d+$/> with leading
zeros suppressed.

   '-0'                            canonical value '-0', normalized '+0'
   '   -123 123 123'               canonical value '-123123123'
   '1 23 456 7890'                 canonical value '+1234567890'

=item Input

Input values to these routines may be either Math::BigInt objects or 
strings of the form C</^\s*[+-]?[\d\s]+$/>.

Math::BigInt::new() defaults to 0, while Mah::BigInt::new('') results
in 'NaN'.

bnorm() on a BigInt object is effectively a no-op, since the numbers 
are always stored in normalized form. On a string, it creates a BigInt 
object.

=item Output

Output values are BigInt objects (normalized), except for bstr(), which
returns a string in normalized form.
Some routines (C<is_odd()>, C<is_even()>, C<is_zero()>, C<is_one()>)
return true or false, while others (C<bcmp()>, C<bacmp()>) return either 
undef, <0, 0 or >0 and are suited for sort.

=back

Actual math is done in an internal format consisting of two Math::BigInts,
named 'a' and 'b'. 'a' and 'b' are always the smallest possible numbers.

=head1 EXAMPLES
 
  use Math::BigFraction;
  $x = new Math::BigFraction 1,3;	# 1/3
  $x *= 3;				# 1/1
  $x /= 5;				# 1/5
  $x += new Math::BigFraction 3,-7;	# -22/35
  $x->bneg();				# 22/35
  $x++;					# 47/35

=head1 Autocreating constants

After C<use Math::BigInt ':constant'> all the integer decimal constants
in the given scope are converted to C<Math::BigInt>. This conversion
happens at compile time.

In particular

  perl -MMath::BigInt=:constant -e 'print 2**100,"\n"'

prints the integer value of C<2**100>.  Note that without conversion of 
constants the expression 2**100 will be calculated as floating point 
number.

=head1 SPEED

Greatly enhanced ;o) 
SectionNotReadyYet.

=head1 PERFORMANCE

SectionNotReadyYet.

=head1 BUGS

None known yet.

=head1 PITFALLS

=over 1

=item bdiv

The following will probably not do what you expect:

	print $c->bdiv(10000),"\n";

It prints both quotient and reminder since print works in list context. Also,
bdiv() will modify $c, so be carefull. You probably want to use
	
	print $c / 10000,"\n";
	print scalar $c->bdiv(10000),"\n";  # or if you want to modify $c

instead.

=item bpow

C<bpow()> now modifies the first argument, unlike the old code which left
it alone and only returned the result. This is to be consistent with
C<badd()> etc. The first will modify $x, the second one won't:

	print bpow($x,$i),"\n"; # modify $x
	print $x ** $i,"\n";	# leave $x alone 

=back

=head1 AUTHORS

(c) Copyright by Tels http://bloodgate.com in late 2000, 2001.

=cut
