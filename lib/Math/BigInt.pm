#!/usr/bin/perl -w

# mark.biggar@TrustedSysLabs.com
# eay@mincom.com is dead (math::BigInteger)
# see: http://www.cypherspace.org/~adam/rsa/pureperl.html (contacted c. adam
# on 2000/11/13 - but email is dead

# mailto:sb@sdm.de (Bit::Vector)
# mailto: chip@zfx.com (Math::GMP)
# mailto:mail@vipul.net (build a module based on Math::BigInt)
# mailto:gary@hotlava.com (Math::BigInteger)

# 2001-04-07 v1.23 Tels
 
# todo:
# * fully remove funky $# stuff (maybe)
# * use integer; vs 1e7 as base
# * speed issues (XS? Bit::Vector?) 

# Qs: what exactly happens on numify of HUGE numbers? overflow?
#     $a = -$a is much slower (making copy of $a) than $a->bneg(), hm!?

# The following hash values are used:
#   value: the internal array, base 100000
#   sign : +,-,"NaN" if not a number
# Internally the numbers are stored in an array with at least 1 element, no
# leading zero parts (except the first) and in base 100000

# USE_MUL: due to problems on certain os (os390, posix-bc) "* 1e-5" is used 
# instead of "/ 1e5" at some places, (marked with USE_MUL). But instead of
# using the reverse only on problematic machines, I used it everytime to avoid
# the costly comparisations. This _should_ work everywhere. Thanx Peter Prymmer

package Math::BigInt;
my $class = "Math::BigInt";

$VERSION = 1.23;
use Exporter;
@ISA =       qw( Exporter );
@EXPORT_OK = qw( bneg babs bcmp badd bmul bdiv bmod bnorm bsub
                 bgcd blcm 
                 blsft brsft band bior bxor bnot bpow bnan bzero 
                 bacmp bstr binc bdec bint
                 is_odd is_even is_zero is_one is_nan sign
		 length
		 trace objectify _swap
               ); 

#@EXPORT = qw( );
use vars qw/$AUTOLOAD/;
use strict;

# Inside overload, the first arg is always an object. By using this, we can
# determine from $_[0] the type of class. also, we can use clone() to make
# a copy (since we can't modify it). The newly cloned object is used to call
# the "right" type of calculation routine. Simple using badd() does not work
# since then in a child the inheritance of badd() seems does not work like
# expected due to closures inside overload.
# When we don't need a clone(), we simple take ref() to get the type of class.

# The making of the second arg into an object is carried out by objectify,
# and this determines the type of the class automatically, based on the first
# argument's class.
# The proper objectify (e.g. from a child class) is used if present,
# Math::String uses this to make the second arg have the same charset than the
# first.

# Thus inheritance of overload operators becomes possible and transparent for
# our childs without the need to repeat the entire overload section there.

sub clone;

use overload
'='     =>      \&clone,
#'+'	=>	sub { my @a = $_[0]->_swap(@_); $a[0]->badd($a[1]); },
'+'	=>	sub { my $c = clone($_[0]); $c->badd($_[1]); },

# sub is a bit tricky... b-a => -a+b
'-'	=>	sub { my $c = clone($_[0]); $_[2] ?
                   $c->bneg()->badd($_[1]) :
                   $c->bsub( $_[1]) },

# some shortcuts for speed (assumes that reversed is routed to normal add etc)
'+='	=>	sub { $_[0]->badd($_[1]); },
'-='	=>	sub { $_[0]->bsub($_[1]); },
'*='	=>	sub { $_[0]->bmul($_[1]); },
'/='	=>	sub { scalar $_[0]->bdiv($_[1]); },
'**='	=>	sub { $_[0]->bpow($_[1]); },

'<=>'	=>	sub { 
			$_[2] ?
                      $class->bcmp($_[1],$_[0]) : 
                      $class->bcmp($_[0],$_[1])},
'cmp'	=>	sub { 
	#my $c = ref($_[0]); 
         $_[2] ? 
               $_[1] cmp $_[0]->bstr() :
               $_[0]->bstr() cmp $_[1] },

# dont need 'int' here ;)
'neg'	=>	sub { my $c = clone($_[0]); $c->bneg(); }, 
'abs'	=>	sub { my $c = clone($_[0]); $c->babs(); },

'*'	=>	sub { my @a = $_[0]->_swap(@_); $a[0]->bmul($a[1]); },
'/'	=>	sub { my @a = $_[0]->_swap(@_); scalar $a[0]->bdiv($a[1]); },
'%'	=>	sub { my @a = $_[0]->_swap(@_); $a[0]->bmod($a[1]); },
'**'	=>	sub { my @a = $_[0]->_swap(@_); $a[0]->bpow($a[1]); },
'<<'	=>	sub { my @a = $_[0]->_swap(@_); $a[0]->blsft($a[1]); },
'>>'	=>	sub { my @a = $_[0]->_swap(@_); $a[0]->brsft($a[1]); },

'&'	=>	sub { my $c = clone($_[0]); $c->band($_[1]); },
'|'	=>	sub { my $c = clone($_[0]); $c->bior($_[1]); },
'^'	=>	sub { my $c = clone($_[0]); $c->bxor($_[1]); },
'~'	=>	sub { my $c = clone($_[0]); $c->bnot(); },

# can modify arg of ++ and --, so avoid a new-copy for speed, but don't
# use $_[0]->_one(), it modifies $_[0] to be 1!
'++'	=>	sub { my $c = ref($_[0]); $_[0]->badd($c->_one()) },
'--'	=>	sub { my $c = ref($_[0]); $_[0]->badd($c->_one('-')) },

# if overloaded, O(1) instead of O(N) and twice as fast for small numbers
'bool'  =>	sub {
  # this kludge is needed for perl prior 5.6.0 since returning 0 here fails :-/
  return !$_[0]->is_zero() || undef;
  },

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
my $BASE = 1e5;

##############################################################################
# constructors

sub clone
  {
  # call the correct sub (due to closures), may be removed later on for speed
  #$trace = 1;
  #trace(@_);
  #$trace = 0;
  # this is wrong since it does not respect inheritance, ouch!
  my $x = shift;
  return $x->copy() if ref($x);
  $class->new( $x ); 
  }

sub copy
  {
  my ($c,$x);
  if (@_ > 1)
    {
    ($c,$x) = @_;
    }
  else
    {
    $x = shift;
    $c = ref($x);
    }
  return unless ref($x); # only for objects

  my $self = {}; bless $self,$c;
  foreach my $k (keys %$x)
    {
    if (ref($x->{$k}) eq 'ARRAY')
      {
      $self->{$k} = [ @{$x->{$k}} ];
      }
    elsif (ref($x->{$k}) eq 'HASH')
      {
      # only one level deep!
      foreach my $h (keys %{$x->{$k}})
        {
        $self->{$k}->{$h} = $x->{$k}->{$h};
        }
      }
    elsif (ref($x->{$k}))
      {
      my $c = ref($x->{$k});
      $self->{$k} = $c->new($x->{$k}); #->new(); # no copy() due to deep rec
      }
    else
      {
      $self->{$k} = $x->{$k};
      }
    }
  $self;
  }

sub new 
  {
  # create a new BigInts object from a string or another bigint object. 
  # value => internal array representation 
  # sign  => sign (+/-), or "NaN"

  # the argument could be an object, so avoid ||, && etc on it, this would
  # cause costly overloaded code to be called. The only allowed op are ref() 
  # and definend.

  trace (@_);
  my $class = shift;
 
  my $wanted = shift; # avoid numify call by not using || here
  return $class->bzero() if !defined $wanted;	# default to 0
  return $class->copy($wanted) if ref($wanted);

  my $self = {}; bless $self, $class;
  # split str in m mantissa, e exponent, i integer, f fraction, v value, s sign
  my ($mis,$miv,$mfv,$es,$ev) = _split(\$wanted);
  if (!ref $mis)
    {
    die "$wanted is not a number initialized to $class" if !$NaNOK;
    #print "NaN 1\n";
    $self->{value} = [ 0 ];
    $self->{sign} = $nan;
    }
  else
    {
    # make integer from mantissa by adjusting exp, then convert to bigint
    $self->{sign} = $$mis;			# store sign
    $self->{value} = [ 0 ];			# for all the NaN cases
    my $e = int("$$es$$ev");			# exponent (avoid recursion)
    if ($e > 0)
      {
      my $diff = $e - CORE::length($$mfv);
      if ($diff < 0)				# Not integer
        {
        #print "NOI 1\n";
        $self->{sign} = $nan;
        }
      else					# diff >= 0
        {
        # adjust fraction and add it to value
        # print "diff > 0 $$miv\n";
        $$miv = $$miv . ($$mfv . '0' x $diff);
        }
      }
    else
      {
      if ($$mfv != 0)				# e <= 0
        {
        # fraction and negative/zero E => NOI
        #print "NOI 2 \$\$mfv '$$mfv'\n";
        $self->{sign} = $nan;
        }
      elsif ($e < 0)
        {
        # xE-y, and empty mfv
        #print "xE-y\n";
        $e = abs($e);
        if ($$miv !~ s/0{$e}$//)		# can strip so many zero's?
          {
          #print "NOI 3\n";
          $self->{sign} = $nan;
          }
        }
      }
    $self->{sign} = '+' if $$miv eq '0';	# normalize -0 => +0
    $self->_internal($miv) if $self->{sign} ne $nan; # store as internal array
    #print "$self\n";
    }
  #print "$wanted => $self->{sign} $self->{value}->[0]\n";
  return $self;
  }

# some shortcuts for easier life
sub bint
  {
  # exportable version of new
  trace(@_);
  return $class->new(@_);
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
  return if $self->modify('bnan');
  $self->{value} = [ 0 ];
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
  return if $self->modify('bzero');
  $self->{value} = [ 0 ];
  $self->{sign} = '+';
  trace('0');
  return $self;
  }

##############################################################################
# string conversation

sub bstr 
  {
  # (ref to BINT or num_str ) return num_str
  # Convert number from internal base 100000 format to string format.
  # internal format is always normalized (no leading zeros, "-0" => "+0")
  trace(@_);
  my $x = shift; $x = $class->new($x) unless ref $x;
  # my ($self,$x) = objectify(1,@_);

  my $ar = $x->{value} || return $nan;
  return $nan if $x->{sign} eq $nan;
  my $es = "";
  $es = $x->{sign} if $x->{sign} eq '-';	# get sign, but not '+'
  my $l = scalar @$ar;         # number of parts
  return $nan if $l < 1;       # should not happen   
  # handle first one different to strip leading zeros from it (there are no
  # leading zero parts in internal representation)
  $l --; $es .= $ar->[$l]; $l--; 
  # Interestingly, the pre-padd method uses more time
  # the old grep variant takes longer (14 to 10 sec)
  while ($l >= 0)
    {
    $es .= substr('0000'.$ar->[$l],-5);   # fastest way I could think of 
    $l--;
    }
  return $es;
  }

sub numify 
  {
  # Make a number from a BigInt object
  # old: simple return string and let Perl's atoi() handle the rest
  # new: calc because it is faster than bstr()+atoi()
  #trace (@_);
  #my ($self,$x) = objectify(1,@_);
  #return $x->bstr(); # ref($x); 
  my $x = shift; $x = $class->new($x) unless ref $x;

  return $nan if $x->{sign} eq $nan;
  my $fac = 1; $fac = -1 if $x->{sign} eq '-';
  return $fac*$x->{value}->[0] if @{$x->{value}} == 1;	# below 1e5
  my $num = 0;
  foreach (@{$x->{value}})
    {
    $num += $fac*$_; $fac *= $BASE;
    }
  return $num;
  }

##############################################################################
# public stuff (usually prefixed with "b")

sub sign
  {
  # return the sign of the number: +/-/NaN
  my ($self,$x) = objectify(1,@_);
  return $x->{sign};
  }

sub bnorm 
  { 
  # (num_str or BINT) return BINT
  # Normalize number (strip leading zeros, strip any white space and add a 
  # sign, if missing. Strings that are not numbers result the value 'NaN')
  # does nothing for BigInts, these are already normalized.
  my ($v) = @_;
  trace (@_);
  
  # if object, simple return it (it is already normalized)
  return $v if ref($v);
  # else scalar string, make object and return it
  return new @_;            
  }

sub babs 
  {
  # (BINT or num_str) return BINT
  # make number absolute, or return absolute BINT from string
  #my ($self,$x) = objectify(1,@_);
  my $x = shift; $x = $class->new($x) unless ref $x;
  return $x if $x->modify('babs');
  # post-normalized abs for internal use (does nothing for NaN)
  $x->{sign} =~ s/^-/+/;
  $x;
  }

sub bneg 
  { 
  # (BINT or num_str) return BINT
  # negate number or make a negated number from string
  my ($self,$x) = objectify(1,@_);
  return $x if $x->modify('bneg');
  # for +0 dont negate (to have always normalized)
  return $x if $x->is_zero(); #is0($x->{value},$x->{sign});
  $x->{sign} =~ tr/+\-/-+/; # does nothing for NaN
  $x;
  }

sub bcmp 
  {
  # Compares 2 values.  Returns one of undef, <0, =0, >0. (suitable for sort)
  # (BINT or num_str, BINT or num_str) return cond_code
  my ($self,$x,$y) = objectify(2,@_);
  return undef if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));
  &cmp($x->{value},$y->{value},$x->{sign},$y->{sign}) <=> 0;
  }

sub bacmp 
  {
  # Compares 2 values, ignoring their signs. 
  # Returns one of undef, <0, =0, >0. (suitable for sort)
  # (BINT, BINT) return cond_code
  my ($self,$x,$y) = objectify(2,@_);
  return undef if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));
  acmp($x->{value},$y->{value}) <=> 0;
  }

sub badd 
  {
  # add second arg (BINT or string) to first (BINT) (modifies first)
  # return result as BINT
  trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  return $x if $x->modify('badd');
  return $x->bnan() if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));

  # speed: no add for 0+y or x+0
  return $x if $y->is_zero(); # is0($y->{value},$y->{sign});       # x+0
  if ($x->is_zero()) # is0($x->{value},$x->{sign}))                # 0+y
    {
    # make copy, clobbering up x
    $x->{value} = [ @{$y->{value}} ];
    $x->{sign} = $y->{sign} || $nan;
    return $x;
    }

  # shortcuts
  my $xv = $x->{value};
  my $yv = $y->{value};
  my ($sx, $sy) = ( $x->{sign}, $y->{sign} ); # get signs

  if ($sx eq $sy)  
    {
    add($xv,$yv);			# if same sign, absolute add
    $x->{sign} = $sx;
    }
  else 
    {
    my $a = acmp ($yv,$xv);		# absolute compare
    if ($a > 0)                           
      {
      #print "swapped sub (a=$a)\n";
      &sub($yv,$xv,1);			# absolute sub w/ swapped params
      $x->{sign} = $sy;
      } 
    elsif ($a == 0)
      {
      # speedup, if equal, set result to 0
      $x->{value} = [ 0 ];
      $x->{sign} = '+';
      }
    else # a < 0
      {
      #print "unswapped sub (a=$a)\n";
      &sub($xv, $yv);			# absolute sub
      $x->{sign} = $sx;
      }
    }
  return $x;
  }

sub bsub 
  {
  # (BINT or num_str, BINT or num_str) return num_str
  # subtract second arg from first, modify first
  my ($self,$x,$y) = objectify(2,@_);

  trace(@_);
  return $x if $x->modify('bsub');
  $x->badd($y->bneg()); # badd does not leave internal zeros
  $y->bneg();           # refix y, assumes no one reads $y in between
  return $x;   
  }

sub binc
  {
  # increment arg by one
  #my ($self,$x) = objectify(1,@_);
  my $x = shift; $x = $class->new($x) unless ref $x; my $self = ref($x);
  trace(@_);
  return $x if $x->modify('binc');
  $x->badd($self->_one());
  }

sub bdec
  {
  # decrement arg by one
  my ($self,$x) = objectify(1,@_);
  trace(@_);
  return $x if $x->modify('bdec');
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
  my ($self,$x,$y) = objectify(2,@_);
  
  return $x if $x->modify('bmod');
  (&bdiv($self,$x,$y))[1];
  }

sub bnot 
  {
  # (num_str or BINT) return BINT
  # represent ~x as twos-complement number
  my ($self,$x) = objectify(1,@_);
  return $x if $x->modify('bnot');
  $x->bneg(); $x->bdec(); # was: bsub(-1,$x);, time it someday
  $x;
  }

sub is_zero
  {
  # return true if arg (BINT or num_str) is zero (array '+', '0')
  #my ($self,$x) = objectify(1,@_);
  #trace(@_);
  my $x = shift; $x = $class->new($x) unless ref $x;
  return (@{$x->{value}} == 1) && ($x->{sign} eq '+') 
   && ($x->{value}->[0] == 0); 
  }

sub is_nan
  {
  # return true if arg (BINT or num_str) is NaAN
  #my ($self,$x) = objectify(1,@_);
  #trace(@_);
  my $x = shift; $x = $class->new($x) unless ref $x;
  return ($x->{sign} eq $nan); 
  }

sub is_one
  {
  # return true if arg (BINT or num_str) is +1 (array '+', '1')
  # or -1 if signis given
  #my ($self,$x) = objectify(1,@_); 
  my $x = shift; $x = $class->new($x) unless ref $x;
  my $sign = shift || '+'; #$_[2] || '+';
  return (@{$x->{value}} == 1) && ($x->{sign} eq $sign) 
   && ($x->{value}->[0] == 1); 
  }

sub is_odd
  {
  # return true when arg (BINT or num_str) is odd, false for even
  my $x = shift; $x = $class->new($x) unless ref $x;
  #my ($self,$x) = objectify(1,@_);
  return (($x->{sign} ne $nan) && ($x->{value}->[0] & 1));
  }

sub is_even
  {
  # return true when arg (BINT or num_str) is even, false for odd
  my $x = shift; $x = $class->new($x) unless ref $x;
  #my ($self,$x) = objectify(1,@_);
  return (($x->{sign} ne $nan) && (!($x->{value}->[0] & 1)));
  }

sub bmul 
  { 
  # multiply two numbers -- stolen from Knuth Vol 2 pg 233
  # (BINT or num_str, BINT or num_str) return BINT
  my ($self,$x,$y) = objectify(2,@_);
  trace(@_);
  return $x if $x->modify('bdiv');
  return $x->bnan() if (($x->{sign} eq $nan) || ($y->{sign} eq $nan));

  mul($x,$y);  # do actual math
  $x;
  }

sub bdiv 
  {
  # (dividend: BINT or num_str, divisor: BINT or num_str) return 
  # (BINT,BINT) (quo,rem) or BINT (only rem)
  trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  return $x if $x->modify('bdiv');

  # NaN?
  return wantarray ? ($x->bnan(),bnan()) : $x->bnan()
   if ($x->{sign} eq $nan || $y->{sign} eq $nan || $y->is_zero());

  # 0 / something
  return wantarray ? ($x,$self->bzero()) : $x if $x->is_zero();
 
  # Is $x in the interval [0, $y) ?
  my $cmp = acmp($x->{value},$y->{value});
  if (($cmp < 0) and ($x->{sign} eq $y->{sign}))
    {
    return $x->bzero() unless wantarray;
    my $t = $x->copy();      # make copy first, because $x->bzero() clobbers $x
    return ($x->bzero(),$t);
    }
  elsif ($cmp == 0)
    {
    # shortcut, both are the same, so set to +/- 1
    $x->_one( ($x->{sign} ne $y->{sign} ? '-' : '+') ); 
    return $x unless wantarray;
    return ($x,$self->bzero());
    }
   
  # calc new sign and in case $y == +/- 1, return $x
  $x->{sign} = ($x->{sign} ne $y->{sign} ? '-' : '+'); 
  # check for / +-1 (cant use $y->is_one due to '-'
  if ((@{$y->{value}} == 1) && ($y->{value}->[0] == 1))
    {
    return wantarray ? ($x,$self->bzero()) : $x; 
    }

  # call div here 
  my $r = $self->bzero(); 
  $r->{sign} = $y->{sign};
  ($x->{value},$r->{value}) = div($x->{value},$y->{value});
  if (($x->{sign} eq '-') and (!$r->is_zero()))
    {
    $x->bdec();
    }
  if (wantarray)
    {
    return ($x,$y-$r) if $x->{sign} eq '-';	# was $x,$r
    return ($x,$r);
    }
  return $x; 
  }

sub bpow 
  {
  # (BINT or num_str, BINT or num_str) return BINT
  # compute power of two numbers -- stolen from Knuth Vol 2 pg 233
  # modifies first argument
  #trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  return $x if $x->modify('bpow');
 
  return $x->bnan() if $x->{sign} eq $nan || $y->{sign} eq $nan;
  return $x->_one() if $y->is_zero();
  return $x         if $x->is_one() || $y->is_one();
  if ($x->{sign} eq '-' && @{$x->{value}} == 1 && $x->{value}->[0] == 1)
    {
    # if $x == -1 and odd/even y => +1/-1
    return $y->is_odd() ? $x : $x->_set(1); # $x->babs() would work to
    }
  return $x->bnan() if $y->{sign} eq '-';
  return $x         if $x->is_zero();  # 0**y => 0 (if not y <= 0)

  # 10**x is special (actually 100**x etc is special, too) but not here
  if ((@{$x->{value}} == 1) && ($x->{value}->[0] == 10))
    {
    # 10**2
    my $yi = int($y); my $yi5 = int($yi/5);
    $x->{value} = [];		
    if ($yi5 > 0)
      { 
      #$yi5 --;
      #$x->{value}->[$yi5] = 0;		# pre-padd array
      for (my $i = 0; $i < $yi5; $i++)
        {
        $x->{value}->[$i] = 0;
        } 
      }
    push @{$x->{value}}, int( '1'.'0' x ($yi % 5));
    if ($x->{sign} eq '-')
      {
      $x->{sign} = $y->is_odd() ? '-' : '+';	# -10**2 = 100, -10**3 = -1000
      }
    return $x; 
    }

  my $pow2 = $self->_one();
  my $y1 = $class->new($y);
  my ($res);
  while (!$y1->is_one())
    {
    #print "bpow: p2: $pow2 x: $x y: $y1 r: $res\n";
    #print "len ",$x->length(),"\n";
    ($y1,$res)=&bdiv($y1,2);
    if (!$res->is_zero()) { &bmul($pow2,$x); }
    if (!$y1->is_zero())  { &bmul($x,$x); }
    }
  #print "bpow: e p2: $pow2 x: $x y: $y1 r: $res\n";
  &bmul($x,$pow2) if (!$pow2->is_one());
  #print "bpow: e p2: $pow2 x: $x y: $y1 r: $res\n";
  return $x;
  }

sub blsft 
  {
  # (BINT or num_str, BINT or num_str) return BINT
  # compute x << y, y >= 0
  my ($self,$x,$y) = objectify(2,@_);
  bmul($x, $self->bpow(2, $y));
  }

sub brsft 
  {
  # (BINT or num_str, BINT or num_str) return BINT
  # compute x >> y, y >= 0
  my ($self,$x,$y) = objectify(2,@_);
  scalar bdiv($x, $self->bpow(2, $y));
  }

sub band 
  {
  #(BINT or num_str, BINT or num_str) return BINT
  # compute x & y
  trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  return $x->bzero() if $y->is_zero();
  return $x->bnan() if ($x->{sign} eq $nan || $y->{sign} eq $nan);
  my $r = $self->bzero(); my $m = new Math::BigInt 1; my ($xr,$yr);
  my $x10000 = new Math::BigInt (0x10000);
  my $y1 = clone($y);		 		# make copy
  while (!$x->is_zero() && !$y1->is_zero())
    {
    ($x, $xr) = bdiv($x, $x10000);
    ($y1, $yr) = bdiv($y1, $x10000);
    $r->badd( bmul( new Math::BigInt ( int($xr) & int($yr)), $m ));
    $m->bmul($x10000);
    }
  $x = $r;
  }

sub bior 
  {
  #(BINT or num_str, BINT or num_str) return BINT
  # compute x | y
  trace(@_);
  my ($self,$x,$y) = objectify(2,@_);

  return $x if $y->is_zero();
  return $x->bnan() if ($x->{sign} eq $nan || $y->{sign} eq $nan);
  my $r = $self->bzero(); my $m = new Math::BigInt 1; my ($xr,$yr);
  my $x10000 = new Math::BigInt (0x10000);
  my $y1 = $y->clone();		 		# make copy
  while (!$x->is_zero() || !$y1->is_zero())
    {
    ($x, $xr) = bdiv($x,$x10000);
    ($y1, $yr) = bdiv($y1,$x10000);
    $r->badd( bmul( new Math::BigInt ( int($xr) | int($yr)), $m ));
    $m->bmul($x10000);
    }
  $x = $r;
  }

sub bxor 
  {
  #(BINT or num_str, BINT or num_str) return BINT
  # compute x ^ y
  my ($self,$x,$y) = objectify(2,@_);

  return $x if $y->is_zero();
  return $x->bnan() if ($x->{sign} eq $nan || $y->{sign} eq $nan);
  return $x->bzero() if $x == $y; # shortcut
  my $r = $self->bzero(); my $m = new Math::BigInt 1; my ($xr,$yr);
  my $x10000 = new Math::BigInt (0x10000);
  my $y1 = clone($y);		 		# make copy
  while (!$x->is_zero() || !$y1->is_zero())
    {
    ($x, $xr) = bdiv($x, $x10000);
    ($y1, $yr) = bdiv($y1, $x10000);
    $r->badd( bmul( new Math::BigInt ( int($xr) ^ int($yr)), $m ));
    $m->bmul($x10000);
    }
  $x = $r;
  }

sub length
  {
  trace(@_);
  my ($self,$x) = objectify(1,@_);
  _digits($x->{value});
  }

sub digit
  {
  # return the nth digit, negative values count backward
  my $x = shift;
  my $n = shift || 0; 

  my $len = $x->length();

  $n = $len+$n if $n < 0;		# -1 last, -2 second-to-last
  $n = abs($n);				# if negatives are to big
  $len--; $n = $len if $n > $len;	# n to big?
  
  my $elem = int($n / 5);		# which array element
  my $digit = $n % 5;			# which digit in this element
  $elem = '0000'.$x->{value}->[$elem];	# get element padded with 0's
  return substr($elem,-$digit-1,1);
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

sub _set
  {
  # internal set routine to set X fast to an integer value < [+-]100000
  my $self = shift;
 
  my $wanted = shift || 0;
  $self->{sign} = '-'; $self->{sign} = '+' if $wanted >= 0;
  $self->{value} = [ abs($wanted) ];
  return $self;
  }

sub _one
  {
  # internal speedup, set argument to 1, or create a +/- 1
  my $self = shift;
  my $x = $self->bzero(); $x->{value} = [ 1 ]; $x->{sign} = shift || '+'; $x;
  }

sub _swap
  {
  # Overload will swap params if first one is no object ref so that the first
  # one is always an object ref. In this case, third param is true.

  # object, (object|scalar) => preserve first and make copy
  # scalar, object	    => swapped, re-swap and create new from first
  #                            (using class of second object)
  my $self = shift;
  #print "swap $_[0] $_[1] $_[2]\n";
  my @return;
  if ($_[2])
    {
    my $c = ref ($_[0] ) || $class; 	# fallback should not happen
    return ( $c->new($_[1]), $_[0] );
    }
  else
    { 
    return ( $_[0]->copy(), $_[1] );
    }
  }

sub objectify
  {
  # check for strings, if yes, return objects instead
 
  # the first argument is number of args objectify() should look at it will
  # return $count+1 elements, the first will be a classname. This is because
  # overloaded '""' calls bstr($object,undef,undef) and this would result in
  # useless objects beeing created and thrown away. So we cannot simple loop
  # over @_. If the given count is 0, all arguments will be used.
 
  # If the second arg is a ref, use it as class.
  # If not, try to use it as classname, unless undef, then use $class 
  # (aka Math::BigInt). The latter shouldn't happen,though.

  # caller:			   gives us:
  # $x->badd(1);                => ref x, scalar y
  # Class->badd(1,2);           => classname x (scalar), scalar x, scalar y
  # Class->badd( Class->(1),2); => classname x (scalar), ref x, scalar y
  # Math::BigInt::badd(1,2);    => scalar x, scalar y
  # In the last case we check number of arguments to turn it silently into
  # $class,1,2. (We can not take '1' as class ;o)
  # badd($class,1) is not supported (it should, eventually, try to add undef)
  # currently it tries 'Math::BigInt' + 1, which will not work.
 
  trace(@_); 
  my $count = abs(shift || 0);
  
  #print caller(),"\n";
 
  my @a;			# resulting array 
  if (ref $_[0])
    {
    # okay, got object as first
    $a[0] = ref $_[0];
    }
  else
    {
    # nope, got either $class,1,2 or 1,2
    $a[0] = $class; 
    $a[0] = shift if (@_ > $count && $count != 0);
    }
  #print caller(),"\n";
  #print "Now in objectify, my class is today $a[0]\n";
  my $k; 
  if ($count == 0)
    {
    while (@_)
      {
      $k = shift;
      if (!ref($k))
        {
        $k = $a[0]->new($k);
        }
      elsif (ref($k) ne $a[0])
	{
	# foreign object, try to convert to integer
        $k->can('as_number') ?  $k = $k->as_number() : $k = $a[0]->new($k);
	}
      push @a,$k;
      }
    }
  else
    {
    while ($count > 0)
      {
      #print "$count\n";
      $count--; 
      $k = shift; 
      if (!ref($k))
        {
        $k = $a[0]->new($k);
        }
      elsif (ref($k) ne $a[0])
	{
	# foreign object, try to convert to integer
        $k->can('as_number') ?  $k = $k->as_number() : $k = $a[0]->new($k);
	}
      push @a,$k;
      }
    #print "objectify() dropped ",scalar @_," arguments to the floor.\n" 
    # if @_ > 0; # debug
    }
  #my $i = 0;
  #foreach (@a)
  #  {
  #  print "o $i $a[0]\n" if $i == 0;
  #  print "o $i ",ref($_),"\n" if $i != 0; $i++;
  #  }
  #print "objectify done: would return ",scalar @a," values\n";
  #print caller(1),"\n" unless wantarray;
  die "$class objectify needs list context" unless wantarray;
  @a;
  }

sub import 
  {
  my $self = shift;
  return unless @_; # do nothing for empty import lists 
  # any non :constant stuff is handled by our parent, Exporter
  return $self->export_to_level(1,$self,@_) 
   unless @_ == 1 and $_[0] eq ':constant';
  #print "constant\n";
  # the rest causes overlord er load to step in
  overload::constant integer => sub { $self->new(@_) };
  }

sub _internal 
  { 
  # (ref to self, ref to string) return ref to num_array
  # Convert a number from string format to internal base 100000 format.
  # Assumes normalized value as input.
  my ($s,$d) = @_;
  my $il = CORE::length($$d)-1;
  # these leaves '00000' instead of int 0 and will be corrected after any op
  $s->{value} = [ reverse(unpack("a" . ($il%5+1) . ("a5" x ($il/5)), $$d)) ];
  $s;
  }

sub _strip_zeros
  {
  # internal normalization function that strips leading zeros from the array
  # args: ref to array
  #trace(@_);
  my $s = shift;
 
  my $cnt = scalar @$s; # get count of parts
  my $i = $cnt-1;
  #print "strip: cnt $cnt i $i\n";
  # '0', '3', '4', '0', '0',
  #  0    1    2    3    4    
  # cnt = 5, i = 4
  # i = 4
  # i = 3
  # => fcnt = cnt - i (5-2 => 3, cnt => 5-1 = 4, throw away from 4th pos)
  # >= 1: skip first part (this can be zero)
  while ($i > 0) { last if $s->[$i] != 0; $i--; }
  $i++; splice @$s,$i if ($i < $cnt); # $i cant be 0
  return $s;
  }

sub _split
  {
  # (ref to num_str) return num_str
  # internal, take apart a string and return the pieces
  my $x = shift;

  $$x =~ s/\s+//g;                        # strip white space (really?)
  return if $$x eq "";
  # possible inputs: 2.1234 # 0.12 # 1 # 1E1 # 2.134E1 # 434E-10

  #print "input: '$$x' ";
  my ($m,$e) = split /[Ee]/,$$x;
  $e = '0' if !defined $e || $e eq "";
  #print "'$m' '$e' ";
  # sign,value for exponent,mantint,mantfrac
  my ($es,$ev,$mis,$miv,$mfv);
  # valid exponent?
  if ($e =~ /^([+-]?)0*(\d+)$/) # strip leading zeros
    {
    $es = $1; $ev = $2;
    #print "'$m' '$e' e: $es $ev ";
    # valid mantissa?
    my ($mi,$mf) = split /\./,$m;
    $mf = '0' if !defined $mf;
    if ($mi =~ /^([+-]?)0*(\d+)$/) # strip leading zeros
      {
      $mis = $1||'+'; $miv = $2;
      #print "$mis $miv";
      # valid, existing fraction part of mantissa?
      return unless ($mf =~ /^(\d+?)0*$/);	# strip trailing zeros
      $mfv = $1;
      #print " split: $mis $miv . $mfv E $es $ev\n";
      return (\$mis,\$miv,\$mfv,\$es,\$ev);
      }
    }
  return; # NaN, not a number
  }

sub _digits
  {
  # computer number of digits in bigint, minus the sign
  # int() because add/sub leaves sometimes strings (like '00005') instead of
  # int ('5') in this place, causing length to fail
  my $cx = shift;

  #print "len: ",(@$cx-1)*5+CORE::length(int($cx->[-1])),"\n";
  return (@$cx-1)*5+CORE::length(int($cx->[-1]));
  }

sub as_number
  {
  # an object might be asked to return itself as bigint on certain overloaded
  # operations, this does exactly this, so that sub classes can simple inherit
  # it or override with their own integer conversion routine
  my $self = shift;

  return Math::BigInt::bstr($self);
  }

##############################################################################
# internal calculation routines

sub acmp
  {
  # internal absolute post-normalized compare (ignore signs)
  # ref to array, ref to array, return <0, 0, >0
  # arrays must have at least on entry, this is not checked for

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

sub cmp 
  {
  # post-normalized compare for internal use (honors signs)
  # ref to array, ref to array, return < 0, 0, >0
  my ($cx,$cy,$sx,$sy) = @_;

  #return 0 if (is0($cx,$sx) && is0($cy,$sy));

  if ($sx eq '+') 
    {
    return 1 if $sy eq '-'; # 0 check handled above
    return acmp($cx,$cy);
    }
  else
    {
    # $sx eq '-'
    return -1 if ($sy eq '+');
    return acmp($cy,$cx);
    }
  return 0; # equal
  }

#sub is0
#  {
#  # internal is_zero check
#  my ($x,$sx) = @_;
#  return @$x == 1 && $x->[0] == 0 && $sx eq '+';
#  }

sub add 
  {
  # (ref to int_num_array, ref to int_num_array)
  # routine to add two base 1e5 numbers
  # stolen from Knuth Vol 2 Algorithm A pg 231
  # there are separate routines to add and sub as per Kunth pg 233
  # This routine clobbers up array x, but not y. 

  my ($x,$y) = @_;

  # for each in Y, add Y to X and carry. If after that, something is left in
  # X, foreach in X add carry to X and then return X, carry
  # Trades one "$j++" for having to shift arrays, $j could be made integer
  # but this would impose a limit to number-length to 2**32.
  my $i; my $car = 0; my $j = 0;
  for $i (@$y)
    {
    $x->[$j] -= 1e5 
      if $car = (($x->[$j] += $i + $car) >= 1e5) ? 1 : 0; 
    $j++;
    }
  while ($car != 0)
    {
    $x->[$j] -= 1e5 if $car = (($x->[$j] += $car) >= 1e5) ? 1 : 0; $j++;
    }
  }

sub sub
  {
  # (ref to int_num_array, ref to int_num_array)
  # subtract base 1e5 numbers -- stolen from Knuth Vol 2 pg 232, $x > $y
  # subtract Y from X (X is always greater/equal!) by modifiyng x in place
  my ($sx,$sy,$s) = @_;

  my $car = 0; my $i; my $j = 0;
  if (!$s)
    {
    #print "case 2\n";
    for $i (@$sx)
      {
      last unless defined $sy->[$j] || $car;
      #print "x: $i y: $sy->[$j] c: $car\n";
      $i += 1e5 if $car = (($i -= ($sy->[$j] || 0) + $car) < 0); $j++;
      #print "x: $i y: $sy->[$j-1] c: $car\n";
      }
    # might leave leading zeros, so fix that
    _strip_zeros($sx);
    return $sx;
    }
  else
    { 
    #print "case 1 (swap)\n";
    for $i (@$sx)
      {
      last unless defined $sy->[$j] || $car;
      #print "$sy->[$j] $i $car => $sx->[$j]\n";
      $sy->[$j] += 1e5
       if $car = (($sy->[$j] = $i-($sy->[$j]||0) - $car) < 0); 
      #print "$sy->[$j] $i $car => $sy->[$j]\n";
      $j++;
      }
    # might leave leading zeros, so fix that
    _strip_zeros($sy);
    return $sy;
    }
  }
    
sub mul 
  {
  # (BINT, BINT) return nothing
  # multiply two numbers in internal representation
  # modifies first arg, second needs not be different from first
  my ($x,$y) = @_;

  $x->{sign} = $x->{sign} ne $y->{sign} ? '-' : '+';
  my @prod = (); my ($prod,$car,$cty,$xi,$yi);
  my $xv = $x->{value};
  my $yv = $y->{value};
  # since multiplying $x with $x fails, make copy in this case
  $yv = [@$xv] if "$xv" eq "$yv";
  for $xi (@$xv) 
    {
    $car = 0; $cty = 0;
    for $yi (@$yv)  
      {
      $prod = $xi * $yi + ($prod[$cty] || 0) + $car;
      $prod[$cty++] =
       $prod - ($car = int($prod * 1e-5)) * 1e5;	# see USE_MUL
      }
    $prod[$cty] += $car if $car; # need really to check for 0?
    $xi = shift @prod;
    }
  push @$xv, @prod;
  _strip_zeros($x->{value});
  # normalize (handled last to save check for $y->is_zero()
  $x->{sign} = '+' if @$xv == 1 && $xv->[0] == 0; # not is_zero due to '-' 
  }

sub div
  {
  # ref to array, ref to array, modify first array and return reminder if 
  # in list context
  # does no longer handle sign
  my ($x,$yorg) = @_;
  my ($car,$bar,$prd,$dd,$xi,$yi,@q,$v2,$v1);

  my (@d,$tmp,$q,$u2,$u1,$u0);

  $car = $bar = $prd = 0;
  
  my $y = [ @$yorg ];
  if (($dd = int(1e5/($y->[-1]+1))) != 1) 
    {
    for $xi (@$x) 
      {
      $xi = $xi * $dd + $car;
      $xi -= ($car = int($xi * 1e-5)) * 1e5;	# see USE_MUL
      }
    push(@$x, $car); $car = 0;
    for $yi (@$y) 
      {
      $yi = $yi * $dd + $car;
      $yi -= ($car = int($yi * 1e-5)) * 1e5;	# see USE_MUL
      }
    }
  else 
    {
    push(@$x, 0);
    }
  @q = (); ($v2,$v1) = @$y[-2,-1];
  $v2 = 0 unless $v2;
  while ($#$x > $#$y) 
    {
    ($u2,$u1,$u0) = @$x[-3..-1];
    $u2 = 0 unless $u2;
    $q = (($u0 == $v1) ? 99999 : int(($u0*1e5+$u1)/$v1));
    --$q while ($v2*$q > ($u0*1e5+$u1-$q*$v1)*1e5+$u2);
    if ($q)
      {
      ($car, $bar) = (0,0);
      for ($yi = 0, $xi = $#$x-$#$y-1; $yi <= $#$y; ++$yi,++$xi) 
        {
        $prd = $q * $y->[$yi] + $car;
        $prd -= ($car = int($prd * 1e-5)) * 1e5;	# see USE_MUL
	$x->[$xi] += 1e5 if ($bar = (($x->[$xi] -= $prd + $bar) < 0));
	}
      if ($x->[-1] < $car + $bar) 
        {
        $car = 0; --$q;
	for ($yi = 0, $xi = $#$x-$#$y-1; $yi <= $#$y; ++$yi,++$xi) 
          {
	  $x->[$xi] -= 1e5
	   if ($car = (($x->[$xi] += $y->[$yi] + $car) > 1e5));
	  }
	}   
      }
      pop(@$x); unshift(@q, $q);
    }
  if (wantarray) 
    {
    @d = ();
    if ($dd != 1)  
      {
      $car = 0; 
      for $xi (reverse @$x) 
        {
        $prd = $car * 1e5 + $xi;
        $car = $prd - ($tmp = int($prd / $dd)) * $dd; # see USE_MUL
        unshift(@d, $tmp);
        }
      }
    else 
      {
      @d = @$x;
      }
    @$x = @q;
    _strip_zeros($x); 
    _strip_zeros(\@d);
    return ($x,\@d);
    }
  @$x = @q;
  _strip_zeros($x); 
  return $x;
  }

sub _lcm 
  { 
  # (BINT or num_str, BINT or num_str) return BINT
  # does modify first argument
  # LCM
 
  my $x = shift; my $ty = shift;
  return $x->bnan() if ($x->{sign} eq $nan) || ($ty->{sign} eq $nan);
  return $x * $ty / bgcd($x,$ty);
  }

sub _gcd 
  { 
  # (BINT or num_str, BINT or num_str) return BINT
  # does modify first arg
  # GCD -- Euclids algorithm Knuth Vol 2 pg 296
  trace(@_);
 
  my $x = shift; my $ty = $class->new(shift); # preserve y
  return $x->bnan() if ($x->{sign} eq $nan) || ($ty->{sign} eq $nan);
  while (!$ty->is_zero())
    {
    ($x, $ty) = ($ty,bmod($x,$ty));
    }
  $x;
  }

###############################################################################
# this method return 0 if the object can be modified, or 1 for not
# We use a fast use constant statement here, to avoid costly calls. Subclasses
# may override it with special code (f.i. Math::BigInt::Constant does so)

#use constant modify => 0;

sub modify
  {
  my $self = shift;
  my $method = shift;
#  print "original $self modify by $method\n";
  return 0; # $self;
  }

1;
__END__

=head1 NAME

Math::BigInt - Arbitrary size integer math package

=head1 SYNOPSIS

  use Math::BigInt;

  # Number creation	
  $x = Math::BigInt->new($str);	# defaults to 0
  $nan  = Math::BigInt->bnan(); # create a NotANumber
  $zero = Math::BigInt->bzero();# create a "+0"

  # Testing
  $x->is_zero();		# return whether arg is zero or not
  $x->is_nan();			# return whether arg is NaN or not
  $x->is_one();			# return true if arg is +1
  $x->is_one('-');		# return true if arg is -1
  $x->is_odd();			# return true if odd, false for even
  $x->is_even();		# return true if even, false for odd
  $x->bcmp($y);			# compare numbers (undef,<0,=0,>0)
  $x->bacmp($y);		# compare absolutely (undef,<0,=0,>0)
  $x->sign();			# return the sign, either +,- or NaN
  $x->digit($n);		# return the nth digit, counting from right
  $x->digit(-$n);		# return the nth digit, counting from left

  # The following all modify their first argument:

  # set 
  $x->bzero();			# set $x to 0
  $x->bnan();			# set $x to NaN

  $x->bneg();			# negation
  $x->babs();			# absolute value
  $x->bnorm();			# normalize (no-op)
  $x->bnot();			# two's complement (bit wise not)
  $x->binc();			# increment x by 1
  $x->bdec();			# decrement x by 1
  
  $x->badd($y);			# addition (add $y to $x)
  $x->bsub($y);			# subtraction (subtract $y from $x)
  $x->bmul($y);			# multiplication (multiply $x by $y)
  $x->bdiv($y);			# divide, set $x to quotient
				# return (quo,rem) or quo if scalar

  $x->bmod($y);			# modulus (x % y)
  $x->bpow($y);			# power of arguments (x ** y)
  $x->blsft($y);		# left shift
  $x->brsft($y);		# right shift 
  
  $x->band($y);			# bitwise and
  $x->bior($y);			# bitwise inclusive or
  $x->bxor($y);			# bitwise exclusive or
  $x->bnot();			# bitwise not (two's complement)
  
  # The following do not modify their arguments:

  bgcd(@values);		# greatest common divisor
  blcm(@values);		# lowest common multiplicator
  
  $x->bstr();			# return normalized string
  $x->length();			# return number of digits in number

=head1 DESCRIPTION

All operators (inlcuding basic math operations) are overloaded if you
declare your big integers as

  $i = new Math::BigInt '123 456 789 123 456 789';

Operations with overloaded operators preserve the arguments which is
exactly what you expect.

=over 2

=item Canonical notation

Big integer values are strings of the form C</^[+-]\d+$/> with leading
zeros suppressed.

   '-0'                            canonical value '-0', normalized '0'
   '   -123 123 123'               canonical value '-123123123'
   '1 23 456 7890'                 canonical value '1234567890'

=item Input

Input values to these routines may be either Math::BigInt objects or
strings of the form C</^\s*[+-]?[\d\s]+\.?[\d\s]*E?[+-]?[\d\s]*$/>.

This means integer values like 1.01E2 or even 1000E-2 are also accepted.
Non integer values result in NaN.

Math::BigInt::new() defaults to 0, while Mah::BigInt::new('') results
in 'NaN'.

bnorm() on a BigInt object is now effectively a no-op, since the numbers 
are always stored in normalized form. On a string, it creates a BigInt 
object.

=item Output

Output values are BigInt objects (normalized), except for bstr(), which
returns a string in normalized form.
Some routines (C<is_odd()>, C<is_even()>, C<is_zero()>, C<is_one()>,
C<is_nan()>) return true or false, while others (C<bcmp()>, C<bacmp()>)
return either undef, <0, 0 or >0 and are suited for sort.

=back

Actual math is done in an internal format consisting of an array of
elements of base 100000 digits with the least significant digit first.
The sign C</^[+-]$/> is stored separately. The string 'NaN' is used to 
represent the result when input arguments are not numbers, as well as 
the result of dividing by zero.

=head1 EXAMPLES
 
  use Math::BigInt qw(bstr bint);
  $x = bstr("1234")                  	# string "1234"
  $x = "$x";                         	# same as bstr()
  $x = bneg("1234")                  	# Bigint "-1234"
  $x = Math::BigInt->bneg("1234");   	# Bigint "-1234"
  $x = Math::BigInt->babs("-12345"); 	# Bigint "12345"
  $x = Math::BigInt->bnorm("-0 00"); 	# BigInt "0"
  $x = bint(1) + bint(2);            	# BigInt "3"
  $x = bint(1) + "2";                	# ditto (auto-BigIntify of "2")
  $x = bint(1);                      	# BigInt "1"
  $x = $x + 5 / 2;                   	# BigInt "3"
  $x = $x ** 3;                      	# BigInt "27"
  $x *= 2;                           	# BigInt "54"
  $x = new Math::BigInt;             	# BigInt "0"
  $x--;                              	# BigInt "-1"
  $x = Math::BigInt->badd(4,5)		# BigInt "9"
  $x = Math::BigInt::badd(4,5)		# BigInt "9"

=head1 Autocreating constants

After C<use Math::BigInt ':constant'> all the B<integer> decimal constants
in the given scope are converted to C<Math::BigInt>. This conversion
happens at compile time.

In particular

  perl -MMath::BigInt=:constant -e 'print 2**100,"\n"'

prints the integer value of C<2**100>.  Note that without conversion of 
constants the expression 2**100 will be calculated as floating point 
number.

Please note that strings and floating point constants are not affected,
so that

  	use Math::BigInt qw/:constant/;

	$x = 1234567890123456789012345678901234567890
		+ 123456789123456789;
	$x = '1234567890123456789012345678901234567890'
		+ '123456789123456789';

do both not work. You need a explicit Math::BigInt->new() around one of them.

=head1 PERFORMANCE

Using the form $x += $y; etc over $x = $x + $y is faster, since a copy of $x
must be made in the second case. For long numbers, the copy can eat up to 20%
of the work (in case of addition/subtraction, less for
multiplication/division). If $y is very small compared to $x, the form
$x += $y is MUCH faster than $x = $x + $y since the copy of $x takes more
time then the actual addition.

The new version of this module is slower on new(), bstr() and numify(). Some
operations may be slower for small numbers, but are significantly faster for
big numbers. Other operations are now constant (O(1), bneg(), babs() etc),
instead of O(N) and thus nearly always take much less time.

For more benchmark results see http://bloodgate.com/perl/benchmarks.html

=head1 BUGS

=over 2

=item :constant and eval()

Under Perl prior to 5.6.0 having an C<use Math::BigInt ':constant';> and 
C<eval()> in your code will crash with "Out of memory". This is probably an
overload/exporter bug. You can workaround by not having C<eval()> 
and ':constant' at the same time, upgrade your Perl or find out why it
happens ;)

=back

=head1 CAVEATS

Some things might not work as you expect them. Below is documented what is
known to be troublesome:

=over 1

=item stringify, bstr()

Both stringify and bstr() now drop the leading '+'. The old code would return
'+3', the new returns '3'. This is to be consistent with Perl and to make
cmp (especially with overloading) to work as you expect. It also solves
problems with Test.pm, it's ok() uses 'eq' internally. 

Mark said, when asked about to drop the '+' altogether, or make only cmp work:

	I agree (with the first alternative), don't add the '+' on positive
	numbers.  It's not as important anymore with the new internal 
	form for numbers.  It made doing things like abs and neg easier,
	but those have to be done differently now anyway.

So, the following examples will now work all as expected:

	use Test;
        BEGIN { plan tests => 1 }
	use Math::BigInt;

	my $x = new Math::BigInt 3*3;
	my $y = new Math::BigInt 3*3;

	ok ($x,3*3);
	print "$x eq 9" if $x eq $y;
	print "$x eq 9" if $x eq '9';
	print "$x eq 9" if $x eq 3*3;

Additionally, the following still works:
	
	print "$x == 9" if $x == $y;
	print "$x == 9" if $x == 9;
	print "$x == 9" if $x == 3*3;

=item bdiv

The following will probably not do what you expect:

	print $c->bdiv(10000),"\n";

It prints both quotient and reminder since print works in list context. Also,
bdiv() will modify $c, so be carefull. You probably want to use
	
	print $c / 10000,"\n";
	print scalar $c->bdiv(10000),"\n";  # or if you want to modify $c

instead.

The quotient is always the greatest integer less than or equal to the
real-valued quotient of the two operands, and the remainder (when it is
nonzero) always has the same sign as the second operand; so, for
example,

	1 / 4 => (0,1)
	1 / -4 => (-1,-3)
	-3 / 4 => (-1,1)
	-3 / -4 => (0,-3)

As a consequence, the behavior of the operator % agrees with the
behavior of Perl's built-in % operator (as documented in the perlop
manpage), and the equation

	$x == ($x / $y) $y + ($x % $y)

holds true for any $x and $y, which justifies calling the two return
values of bdiv() the quotient and remainder.

Perl's 'use integer;' changes the behaviour of % and / for scalars, but will
not change BigInt's way to do things. This is because under 'use integer' Perl
will do what the underlying C thinks is right and this is different for each
system. If you need BigInt's behaving exactly like Perl's 'use integer', bug
the author to implement it ;)

=item bpow

C<bpow()> now modifies the first argument, unlike the old code which left
it alone and only returned the result. This is to be consistent with
C<badd()> etc. The first three will modify $x, the last one won't:

	print bpow($x,$i),"\n"; 	# modify $x
	print $x->bpow($i),"\n"; 	# ditto
	print $x **= $i,"\n";		# the same
	print $x ** $i,"\n";		# leave $x alone 

The form C<$x **= $y> is faster than C<$x = $x ** $y;>, though.

=item Overloading -$x

The following:

	$x = -$x;

is slower than

	$x->bneg();

since overload calls C<sub($x,0,1);> instead of C<neg($x)>. The first variant
needs to preserve $x since it does not know that it later will get overwritten.
This makes a copy of $x and takes O(N). But $x->bneg() is O(1).

=item Mixing differend object types

In Perl you will get a floating point value if you do one of the following:

	$float = 5.0 + 2;
	$float = 2 + 5.0;
	$float = 5 / 2;

With overloaded math, only the first two variants will result in a BigFloat:

	use Math::BigInt;
	use Math::BigFloat;
	
	$mbf = Math::BigFloat->new(5);
	$mbi2 = Math::BigInteger->new(5);
	$mbi = Math::BigInteger->new(2);

	$float = $mbf + $mbi;		# $mbf->badd()
	$float = $mbf / $mbi;		# $mbf->bdiv()
	$integer = $mbi + $mbf;		# $mbi->badd()
	$integer = $mbi2 / $mbi;	# $mbi2->bdiv()
	$integer = $mbi2 / $mbf;	# $mbi2->bdiv()

This is because math with overloaded operators follows the first (dominating)
operand, this one's operation is called and returns such the result. Thus,
Math::BigInt::bdiv() will always return a Math::BigInt, regardless whether
the result should be a Math::BigFloat or the second operant is one.

To get a Math::BigFloat you either need to call the operation manually,
make sure the operands are already of the proper type or casted to that type
via Math::BigFloat->new().
	
	$float = Math::BigFloat->new($mbi2) / $mbi;	# = 2.5

Beware of simple "casting" the entire expression, this would only convert
the already computed result:

	$float = Math::BigFloat->new($mbi2 / $mbi);	# = 2.0 thus wrong!

Beware of the order of more complicated expressions like:

	$integer = ($mbi2 + $mbi) / $mbf;		# int / float => int
	$integer = $mbi2 / Math::BigFloat->new($mbi);	# ditto

If in doubt, break the expression into simpler terms, or cast all operands
to the desired resulting type.

Scalar values are a bit different, since:
	
	$float = 2 + $mbf;
	$float = $mbf + 2;

will both result in the proper type due to the way overload works.

This section also applies to other overloaded math packages, like Math::String.

=back

=head1 AUTHORS

Original code by Mark Biggar, overloaded interface by Ilya Zakharevich.
Completely rewritten by Tels http://bloodgate.com in late 2000, 2001.

=cut
