#!/usr/bin/perl -w

# mark.biggar@TrustedSysLabs.com

# 2001-03-25 v1.02 Tels
 
# todo:
# * anything

# The following hash values are used:
#   _e: exponent (BigInt)
#   _m: mantissa (BigInt)
#   sign : +,-,"NaN" if not a number

package Math::BigFloat;
my $class = "Math::BigFloat";

$VERSION = 1.02;
require 5.005;
use Exporter;
use Math::BigInt qw/trace objectify/;
@ISA =       qw( Exporter Math::BigInt);
@EXPORT_OK = qw( 
		bneg babs bcmp badd bmul bdiv bmod bnorm bsub
		bgcd blcm 
		bpow bnan bzero 
		bacmp bstr binc bdec bint
		is_odd is_even is_nan
		is_zero is_one sign
               ); 

#@EXPORT = qw( );
use strict;

use overload
'='     =>      \&clone,
'+'	=>	sub { my $c = clone($_[0]); $c->badd($_[1]); },

# sub is a bit tricky... b-a => -a+b
'-'	=>	sub { my $c = clone($_[0]); $_[2] ?
                   $c->bneg()->badd($_[1]) :
                   $c->bsub( $_[1]) },
'+='	=>	sub { $_[0]->badd($_[1]); },
'-='	=>	sub { $_[0]->badd($_[1]); },
'*='	=>	sub { $_[0]->bmul($_[1]); },
'/='	=>	sub { scalar $_[0]->bdiv($_[1]); },

'<=>'	=>	sub { 
			$_[2] ?
                      $class->bcmp($_[1],$_[0]) : 
                      $class->bcmp($_[0],$_[1])},
'cmp'	=>	sub { my $c = ref($_[0]); $_[2] ? 
               $_[1] cmp $c->bstr($_[0]) :
               $c->bstr($_[0]) cmp $_[1] },

# dont need int() here ;)
'neg'	=>	sub { my $c = $class->clone($_[0]); $c->bneg(); }, 
'abs'	=>	sub { my $c = $class->clone($_[0]); $c->babs(); },

'*'	=>	sub { 
 my $c = ref $_[0]; 
#  print "$_[0]\n"; my $r = $_[0]->copy(); print "$r\n";
 $_[2]? 
   $c->bmul($c->copy($_[1]),$_[0]) :
   $c->bmul($_[0]->copy(),$_[1]) },
'/'	=>	sub { 
 $_[2]? 
                   scalar bdiv(clone($_[1]),$_[0]) :
                   scalar bdiv(clone($_[0]),$_[1]) },
'%'	=>	sub { $_[2]? 
                   bmod(clone($_[1]),$_[0]) :
                   bmod(clone($_[0]),$_[1]) },
#'**'	=>	sub { $_[2]? 
#                   bpow(clone($_[1]),$_[0]) :
#                   bpow(clone($_[0]),$_[1]) },
'<<'	=>	sub { $_[2]? 
                   blsft(clone($_[1]),$_[0]) :
                   blsft(clone($_[0]),$_[1]) },
'>>'	=>	sub { $_[2]? 
                   brsft(clone($_[1]),$_[0]) :
                   brsft(clone($_[0]),$_[1]) },

'&'	=>	sub { band(clone($_[0]),$_[1]) },
'|'	=>	sub { bior(clone($_[0]),$_[1]) },
'^'	=>	sub { bxor(clone($_[0]),$_[1]) },
'~'	=>	sub { bnot(clone(@_)) },

# can modify arg of ++ and --, so avoid a new-copy for speed, but don't
# use $_[0]->_one(), it modifies $_[0] to be 1!
'++'	=>	sub { my $c = ref($_[0]); $_[0]->badd($c->_one()) },
'--'	=>	sub { my $c = ref($_[0]); $_[0]->badd($c->_one('-')) },

# needed?
#'bool'  =>	sub { is_zero(@_); },

qw(
""	bstr
0+	numify),		# Order of arguments unsignificant
;

# are NaNs ok?
my $NaNOK=1;
# set to 1 for tracing
my $trace = 0;
# constant for easier life
my $nan = 'NaN'; 

##############################################################################
# constructors

sub clone
  {
  my $self = shift;
  # call the correct sub (due to closures), may be removed later on for speed
  #$trace = 1;
  #trace(@_);
  #$trace = 0;
  #print "in $class clone\n";
  # this is wrong since it does not respect inheritance, ouch!
  my $x = shift;
  return $x->copy() if ref($x);
  $class->new($x);
  }

sub new 
  {
  # create a new BigFloat object from a string or another bigfloat object. 
  # _e: exponent
  # _m: mantissa
  # sign  => sign (+/-), or "NaN"

  trace (@_);
  my $class = shift;
 
  my $wanted = shift; # avoid numify call by not using || here
  return $class->bzero() if !defined $wanted;      # default to 0
  return $wanted->copy() if ref($wanted);

  my $round = shift; $round = 0 if !defined $round; # no rounding as default
  my $self = {};
  # got string
  #print "new string '$wanted'\n";
  my ($mis,$miv,$mfv,$es,$ev) = Math::BigInt::_split(\$wanted);
  if (!ref $mis)
    {
    die "$wanted is not a number initialized to $class" if !$NaNOK;
    $self->{_e} = Math::BigInt->new(0);
    $self->{_m} = Math::BigInt->new(0);
    $self->{sign} = $nan;
    }
  else
    {
    # make integer from mantissa by adjusting exp, then convert to bigint
    $self->{_e} = Math::BigInt->new("$$es$$ev");	# exponent
    $self->{_m} = Math::BigInt->new("$$mis$$miv$$mfv");	# mantissa
    #my $mf = Math::BigInt->new( $$mfv );
    #$mf = $mf->bround($round) if $round >= 0; 		# round to int
    $self->{_e}->bzero() if $self->{_m}->is_zero();	# 0Ex => 0E0
    $self->{_e} -= CORE::length($$mfv);			# 3.123E0 = 3123E-3	
    $self->{sign} = $self->{_m}->{sign};
    #print "$self\n";        
    }
  #print "$wanted => $self->{sign} $self->{value}->[0]\n";
  bless $self, $class;
  return $self;
  }

# some shortcuts for easier life
sub bfloat
  {
  # exportable version of new
  trace(@_);
  return $class->new(@_);
  }

sub bint
  {
  # exportable version of new
  trace(@_);
  return $class->new(@_,0);
  }

sub bnan
  {
  # create a bigint 'NaN', if given a BigFloat, set it to 'NaN'
  my $self = shift;
  $self = $class if !defined $self;
  if (!ref($self))
    {
    my $c = $self; $self = {}; bless $self, $c;
    }
  $self->{_e} = new Math::BigInt 0;
  $self->{_m} = new Math::BigInt 0;
  $self->{sign} = $nan;
  trace('NaN');
  return $self;
  }

sub bzero
  {
  # create a bigint '+0', if given a BigFloat, set it to 0
  my $self = shift;
  $self = $class if !defined $self;
  if (!ref($self))
    {
    my $c = $self; $self = {}; bless $self, $c;
    }
  $self->{_e} = new Math::BigInt 1;
  $self->{_m} = new Math::BigInt 0;
  $self->{sign} = '+';
  trace('0');
  return $self;
  }

##############################################################################
# string conversation

sub bstr 
  {
  # (ref to BFLOAT or num_str ) return num_str
  # Convert number from internal format to string format.
  # internal format is always normalized (no leading zeros, "-0" => "+0")
  trace(@_);
  my ($self,$x) = objectify(1,@_);

  return $x->{_m}->bstr()."E".$x->{_e}->bstr() unless $x->{_e}->is_zero();
  return $x->{_m}->bstr();	# E0
  }

sub bsstr 
  {
  # (ref to BFLOAT or num_str ) return num_str
  # Convert number from internal format to scientific string format.
  # internal format is always normalized (no leading zeros, "-0E0" => "+0E0")
  trace(@_);
  my ($self,$x) = objectify(1,@_);

  return $x->{_m}->bstr()."E".$x->{_e}->bstr();
  }

sub numify 
  {
  # Make a number from a BigFloat object
  # simple return string and let Perl's atoi() handle the rest
  trace (@_);
  my ($self,$x) = objectify(1,@_);
  return $x->bstr(); # ref($x); 
  }

##############################################################################
# public stuff (usually prefixed with "b")

sub bcmp 
  {
  # Compares 2 values.  Returns one of undef, <0, =0, >0. (suitable for sort)
  # (BINT or num_str, BINT or num_str) return cond_code
  my ($self,$x,$y) = objectify(2,@_);
  return undef if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));

  # check sign
  return 1 if $x->{sign} eq '+' && $y->{sign} eq '-';
  return -1 if $x->{sign} eq '-' && $y->{sign} eq '+';

  # signs are equal, so check length
  # length(x) is length(m)+e aka length of non-fraction part
  # the longer one is bigger
  my $l = $x->length() - $y->length();
  #print "$l\n";
  return $l if $l != 0;
  #print "equal lengths\n";

  # if both are equal long, make full compare
  # first compare only the mantissa
  # if mantissa are equal, compare fractions
  
  return $x->{_m} <=> $y->{_m} || $x->{_e} <=> $y->{_e};
  }

sub bacmp 
  {
  # Compares 2 values, ignoring their signs. 
  # Returns one of undef, <0, =0, >0. (suitable for sort)
  # (BINT or num_str, BINT or num_str) return cond_code
  my ($self,$x,$y) = objectify(2,@_);
  return undef if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));

  # signs are ignored, so check length
  # length(x) is length(m)+e aka length of non-fraction part
  # the longer one is bigger
  my $l = $x->length() - $y->length();
  #print "$l\n";
  return $l if $l != 0;
  #print "equal lengths\n";

  # if both are equal long, make full compare
  # first compare only the mantissa
  # if mantissa are equal, compare fractions
  
  return $x->{_m} <=> $y->{_m} || $x->{_e} <=> $y->{_e};
  }

sub badd 
  {
  # add second arg (BINT or string) to first (BINT) (modifies first)
  # return result as BINT
  trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  return $x->bnan() if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));
  
  # speed: no add for 0+y or x+0
  return $x if $y->is_zero();				# x+0
  if ($x->is_zero())					# 0+y
    {
    # make copy, clobbering up x
    $x->{_e} = Math::BigInt->new( $y->{_e} );
    $x->{_m} = Math::BigInt->new( $y->{_m} );
    $x->{sign} = $y->{sign} || $nan;
    return $x;
    }
  
  # take lower of the two e's and adapt m1 to it to match m2
  my $e = $y->{_e} - $x->{_e};
  if ($e < 0)
    {
    #print "e < 0\n";
    #print "\$x->{_m}: $x->{_m} ";
    #print "\$x->{_e}: $x->{_e}\n";
    $x->{_m} *= (10 ** $e->babs());
    $x->{_e} += $e;			# already abs in line before
    $x->{_m} += $y->{_m};
    #print "\$x->{_m}: $x->{_m} ";
    #print "\$x->{_e}: $x->{_e}\n";
    }
  elsif ($e > 0)
    {
    #print "e > 0\n";
    #print "\$x->{_m}: $x->{_m} \$y->{_m}: $y->{_m} \$e: $e ",ref($e),"\n";
    $x->{_m} += $y->{_m} * (10 ** $e);
    #print "\$x->{_m}: $x->{_m}\n";
    }
  else
    {
    # else: both are same, so leave them
    $x->{_m} += $y->{_m};
    }
  return $x->_norm();
  }

sub bsub 
  {
  # (BINT or num_str, BINT or num_str) return num_str
  # subtract second arg from first, modify first
  my ($self,$x,$y) = objectify(2,@_);

  trace(@_);
  $x->badd($y->bneg()); # badd does not leave internal zeros
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

sub blcm 
  { 
  # (BINT or num_str, BINT or num_str) return BINT
  # does not modify arguments, but returns new object
  # Lowest Common Multiplicator
  trace(@_);

  my ($self,@arg) = objectify(0,@_);
  my $x = $self->new(shift @arg);
  while (@arg) { $x = _lcm($x,shift @arg); } 
  $x;
  }

sub bgcd 
  { 
  # (BINT or num_str, BINT or num_str) return BINT
  # does not modify arguments, but returns new object
  # GCD -- Euclids algorithm Knuth Vol 2 pg 296
  trace(@_);
   
  my ($self,@arg) = objectify(0,@_);
  my $x = $self->new(shift @arg);
  while (@arg) { $x = _gcd($x,shift @arg); } 
  $x;
  }

sub bmod 
  {
  # modulus
  # (BINT or num_str, BINT or num_str) return BINT
  (&bdiv(@_))[1];
  }

sub is_zero
  {
  # return true if arg (BINT or num_str) is zero (array '+', '0')
  my ($self,$x) = objectify(1,@_);
  trace(@_);
  return ($x->{_e}->is_zero() && $x->{_m}->is_zero()); 
  }

sub is_one
  {
  # return true if arg (BINT or num_str) is +1 (array '+', '1')
  # or -1 if signis given
  my ($self,$x) = objectify(1,@_); 
  my $sign = $_[2] || '+';
  return ($x->{_e}->is_zero() && $x->{_m}->is_one($sign)); 
  }

#sub is_odd
#  {
#  # return true when arg (BINT or num_str) is odd, false for even
#  my ($self,$x) = objectify(@_);
#  return (($x->{sign} ne $nan) && ($x->{value}->[0] & 1));
#  }
#
#sub is_even
#  {
#  # return true when arg (BINT or num_str) is even, false for odd
#  my ($self,$x) = objectify(@_);
#  return (($x->{sign} ne $nan) && (!($x->{value}->[0] & 1)));
#  }

sub bmul 
  { 
  # multiply two numbers -- stolen from Knuth Vol 2 pg 233
  # (BINT or num_str, BINT or num_str) return BINT
  my ($self,$x,$y) = objectify(2,@_);
  trace(@_);

  #print "mul $x->{_m}e$x->{_e} $y->{_m}e$y->{_e}\n";
  return $x->bnan() if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));

  # aEb * cEd = (a*c)E(b+d)
  $x->{_m} = $x->{_m} * $y->{_m};
  #print "m: $x->{_m}\n";
  $x->{_e} = $x->{_e} + $y->{_e};
  #print "e: $x->{_m}\n";
  # adjust sign:
  $x->{sign} = $x->{sign} ne $y->{sign} ? '-' : '+';
  #print "s: $x->{sign}\n";
  $x->_norm();
  #print "x: $x\n";
  return $x;
  }

sub bdiv 
  {
  # (dividend: BINT or num_str, divisor: BINT or num_str) return 
  # (BINT,BINT) (quo,rem) or BINT (only rem)
  
  $trace = 1;
  $class->trace(@_);
  $trace = 0;
  my ($self,$x,$y) = objectify(2,@_);

  return wantarray ? ($x->bnan(),bnan()) : $x->bnan()
   if ($x->{sign} eq $nan || $y->{sign} eq $nan || $y->is_zero());
  
  return wantarray ? ($x,$self->bzero()) : $x if $x->is_zero();

  #if (&acmp($x->{value},$y->{value}) < 0)
  #  {
  #  return $x->bzero() unless wantarray;
  #  my $t = $class->new($x); return ($x->bzero(),$t);
  #  };
    
  $x->{sign} = $x->{sign} ne $y->{sign} ? '-' : '+'; 
  # check for / +-1 ( +/- 1E0)
  if (($y->{_m}->is_one()) && ($y->{_e}->is_zero()))
    {
    return wantarray ? ($x,$self->bzero()) : $x; 
    }

  # a * 10 ** b / c * 10 ** d => a/c * 10 ** (b-d)

  $x->{_m}->bdiv($y->{_m});	# a/c
  $x->{_e}->bsub($y->{_e});	# b-d
  
  return $x;
  }

sub bpow 
  {
  # (BINT or num_str, BINT or num_str) return BINT
  # compute power of two numbers -- stolen from Knuth Vol 2 pg 233
  # modifies first argument

  my ($self,$x,$y) = objectify(2,@_);

  return $x->bnan() if $x->{sign} eq $nan || $y->{sign} eq $nan;
  return $x->bnan() if $x->is_zero() && $y->is_zero();
  return $x         if $x->is_one() || $y->is_one();
  if ($x->{sign} eq '-' && @{$x->{value}} == 1 && $x->{value}->[0] == 1)
    {
    # if $x == -1 and odd/even y => +1/-1
    return $y->is_odd() ? $x : $x->_set(1); # $x->babs() would work to
    }
  return $x->bnan() if $y->{sign} eq '-';
  return $x         if $x->is_zero();  # 0**y => 0 (if not y <= 0)
  return $x->_set(1) if $y->is_zero(); # x**0 => 1

  my $pow2 = $self->_one();
  my $y1 = $class->new($y);
  my ($res);
  while (!$y1->is_one())
    {
    #print "bpow: p2: $pow2 x: $x y: $y1 r: $res\n";
    ($y1,$res)=&bdiv($y1,2);
    if (!$res->is_zero()) { &bmul($pow2,$x); }
    if (!$y1->is_zero())  { &bmul($x,$x); }
    }
  #print "bpow: e p2: $pow2 x: $x y: $y1 r: $res\n";
  &bmul($x,$pow2) if (!$pow2->is_one());
  #print "bpow: e p2: $pow2 x: $x y: $y1 r: $res\n";
  return $x;
  }

##############################################################################
# private stuff (internal use only)

sub _one
  {
  # internal speedup, set argument to 1, or create a +/- 1
  my $self = shift;
  my $x = $self->bzero(); 
  $x->{_m}->{value} = [ 1 ]; $x->{sign} = shift || '+'; 
  return $x;
  }

sub import 
  {
  my $self = shift;
  return unless @_; # do nothing for empty import lists 
  # any non :constant stuff is handled by our parent, Exporter
  return $self->export_to_level(1,$self,@_) 
   unless @_ == 1 and $_[0] eq ':constant';
  # the rest causes overlord er load to step in
  overload::constant float => sub { $self->new(@_) };
  }

sub _norm
  {
  # adjust m and e so that m is smallest possible
  my $x = shift;
  return $x if $x->is_zero();

  # check each array elem in _m for having 0 at end as long as elem == 0
  # Upon finding a elem != 0, stop
  my $zeros = 0; my $elem;
  foreach (@{$x->{_m}->{value}})
    {
    if ($_ != 0)
      {
      $elem = $_;				# preserve x
      $elem =~ s/[1-9]+([0]*)/$1/;		# strip anything not zero
      $zeros += length($elem);			# count trailing zeros
      last;					# early out
      }
    else
      {
      $zeros += 5;				# all zeros
      }
    }
  # correct x if trailing zeros found
  if ($zeros != 0)
    {
    # this could be faster if $zeros > 5 by movind array elemts instead of
    # print "brute divide by 10 ** $zeros\n";
    $x->{_m} /= 10 ** $zeros; $x->{_e} += $zeros;
    }
  # for something like 0Ey, set y to 0
  $x->{_e} = Math::BigInt::bzero() if $x->{_m}->is_zero();
  return $x;
  }
 
##############################################################################
# internal calculation routines

sub acmp
  {
  # internal absolute post-normalized compare (ignore signs)
  # ref to array, ref to array, return <0, 0, >0
  # arrays must have at least on entry, this is not checked for

  print "trace\n";
  $trace = 1;
  print caller();
  $class->trace(@_);
  $trace = 0;
  my ($cx, $cy) = @_;

  #print "$cx $cy\n"; 
  my ($i,$a,$x,$y,$k);
  # calculate length based on digits, not parts
  $x = _digits($cx); $y = _digits($cy);
  # print "length: ",($x-$y),"\n";
  return $x-$y if ($x - $y);              # if different in length
  #print "full compare\n";
  $i = 0; $a = 0;
  # first way takes 5.49 sec instead of 4.87, but has the early out advantage
  # so grep is slightly faster, but more unflexible. hm. $_ instead if $k
  # yields 5.6 instead of 5.5 sec huh?
  # manual way (abort if unequal, good for early ne)
  my $j = scalar @$cx - 1;
  while ($j >= 0)
   {
   # print "$cx->[$j] $cy->[$j] $a",$cx->[$j]-$cy->[$j],"\n";
   last if ($a = $cx->[$j] - $cy->[$j]); $j--;
   }
  return $a;
  # while it early aborts, it is even slower than the manual variant
  #grep { return $a if ($a = $_ - $cy->[$i++]); } @$cx;
  # grep way, go trough all (bad for early ne)
  #grep { $a = $_ - $cy->[$i++]; } @$cx;
  #return $a;
  }

#sub cmp 
#  {
#  # post-normalized compare for internal use (honors signs)
#  # ref to array, ref to array, return < 0, 0, >0
#  my ($cx,$cy,$sx,$sy) = @_;
#
#  return 0 if (is0($cx,$sx) && is0($cy,$sy));
#
#  if ($sx eq '+') 
#    {
#    return 1 if $sy eq '-'; # 0 check handled above
#    return acmp($cx,$cy);
#    }
#  else
#    {
#    # $sx eq '-'
#    return -1 if ($sy eq '+');
#    return acmp($cy,$cx);
#    }
#  return 0; # equal
#  }

sub as_number
  {
  # return a bigint representation of this BigFloat number
  trace(@_);
  my ($self,$x) = objectify(1,@_);

  print "as_number\n";
  print $x->{_e},"n";
  my $u =  $x->{_m} * (10 ** $x->{_e});
  print "u: ",ref($u)," $u\n";
  return $u;
  }

sub length
  {
  trace(@_);
  my ($self,$x) = objectify(1,@_);
  
  #print "length $x\n";  
  return Math::BigInt::_digits($x->{_m}->{value}) + $x->{_e}; 
  }

1;
__END__

=head1 NAME

Math::BigFloat - Arbitrary size floating point math package

=head1 SYNOPSIS

  use Math::BigFloat;

  # not ready yet

  # Number creation	
  $x = Math::BigInt->new($str);	# defaults to 0
  $nan  = Math::BigInt->bnan(); # create a NotANumber
  $zero = Math::BigInt->bzero();# create a "+0"

  # Testing
  $x->is_zero();		# return wether arg is zero or not
  $x->is_one();			# return true if arg is +1
  $x->is_one('-');		# return true if arg is -1
  $x->is_odd();			# return true if odd, false for even
  $x->is_even();		# return true if even, false for odd
  $x->bcmp($y);			# compare numbers (undef,<0,=0,>0)
  $x->bacmp($y);		# compare absolutely (undef,<0,=0,>0)
  $x->sign();			# return the sign, either +,- or NaN

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
  
  $x->bstr();			# return normalized string

=head1 DESCRIPTION

All operators (inlcuding basic math operations) are overloaded if you
declare your big integers as

  $i = new Math::BigFloat '123.456789123456789E-2';

Operations with overloaded operators preserve the arguments which is
exactly what you expect.

=over 2

=item Canonical notation

not ready yet.
Big integer values are strings of the form C</^[+-]\d+$/> with leading
zeros suppressed.

   '-0'                            canonical value '-0', normalized '0'
   '   -123 123 123'               canonical value '-123123123'
   '1 23 456 7890'                 canonical value '1234567890'

=item Input

Input values to these routines may be either Math::BigFloat objects or 
strings of a relaxed canonical form (e.g. leading and trailin zeros are ok).

'' as well as other illegal numbers results in 'NaN'.

bnorm() on a BigFloat object is now effectively a no-op, since the numbers 
are always stored in normalized form. On a string, it creates a BigFloat 
object.

=item Output

Output values are BigFloat objects (normalized), except for bstr(), which
returns a string in normalized form.
Some routines (C<is_odd()>, C<is_even()>, C<is_zero()>, C<is_one()>)
return true or false, while others (C<bcmp()>, C<bacmp()>) return either 
undef, <0, 0 or >0 and are suited for sort.

=back

Actual math is done by using BigInts to represent the mantissa and exponent.
The sign C</^[+-]$/> is stored separately. The string 'NaN' is used to 
represent the result when input arguments are not numbers, as well as 
the result of dividing by zero.

=head1 EXAMPLES
 
  use Math::BigFloat qw(bstr bint);
  # not ready yet
  $x = bstr("1234")                    # string "1234"
  $x = "$x";                           # same as bstr()
  $x = bneg("1234")                    # BigFloat "-1234"
  $x = Math::BigFloat->bneg("1234");   # BigFloat "1234"
  $x = Math::BigFloat->babs("-12345"); # BigFloat "12345"
  $x = Math::BigFloat->bnorm("-0 00"); # BigFloat "0"
  $x = bint(1) + bint(2);              # BigFloat "3"
  $x = bint(1) + "2";                  # dito (auto-BigFloatify of "2")
  $x = bint(1);                        # BigFloat "1"
  $x = $x + 5 / 2;                     # BigFloat "3"
  $x = $x ** 3;                        # BigFloat "27"
  $x *= 2;                             # BigFloat "54"
  $x = new Math::BigFloat;             # BigFloat "0"
  $x--;                                # BigFloat "-1"

=head1 Autocreating constants

After C<use Math::BigFloat ':constant'> all the floating point constants
in the given scope are converted to C<Math::BigFloat>. This conversion
happens at compile time.

In particular

  perl -MMath::BigFloat=:constant -e 'print 2E-100,"\n"'

prints the value of C<2E-100>.  Note that without conversion of 
constants the expression 2E-100 will be calculated as normal floating point 
number.

=head1 PERFORMANCE

Greatly enhanced ;o) 
SectionNotReadyYet.

=head1 BUGS

None known yet.

=head1 CAVEAT

=over 1

=item stringify, bstr()

Both stringify and bstr() now drop the leading '+'. The old code would return
'+1.23', the new returns '1.23'. This is to be consistent with Perl and to make
cmp (especially with overloading) to work as you espect. It also solves
problems with Test.pm, it's ok() uses 'eq' internally. 

Mark said, when asked about to drop the '+' altogether, or make only cmp work:

	I agree (with the first alternative), don't add the '+' on positive
	numbers.  It's not as important anymore with the new internal 
	form for numbers.  It made doing things like abs and neg easier,
	but those have to be done differently now anyway.

So, the following examples now work all:

	use Test;
        BEGIN { plan tests => 1 }
	use Math::BigFloat;

	my $x = new Math::BigFloat 3.12;
	my $y = new Math::BigFloat 3.12;

	ok ($x,3.12);
	print "$x eq 3.12" if $x eq $y;
	print "$x eq 3.12" if $x eq '3.12';
	print "$x eq 3.12" if $x eq 3.12;

Additionally, the following still works:
	
	print "$x == 3.12" if $x == $y;
	print "$x == 3.12" if $x == 3.12;
	print "$x == 3.12" if $x == 3.12;

=item bdiv

The following will probably not do what you expect:

	print $c->bdiv(123.456),"\n";

It prints both quotient and reminder since print works in list context. Also,
bdiv() will modify $c, so be carefull. You probably want to use
	
	print $c / 123.456,"\n";
	print scalar $c->bdiv(123.456),"\n";  # or if you want to modify $c

instead.

=item bpow

C<bpow()> now modifies the first argument, unlike the old code which left
it alone and only returned the result. This is to be consistent with
C<badd()> etc. The first will modify $x, the second one won't:

	print bpow($x,$i),"\n"; 	# modify $x
	print $x->bpow($i),"\n"; 	# dito
	print $x ** $i,"\n";		# leave $x alone 

=back

=head1 AUTHORS

Mark Biggar, overloaded interface by Ilya Zakharevich.
Completely rewritten by Tels http://bloodgate.com in 2001.

=cut
