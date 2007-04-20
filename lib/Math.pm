package Math;
use strict;
use warnings;

our $VERSION = '0.538';

our @POSIX = qw(
  acos
  asin
  atan
  ceil
  floor
  fmod
  round
  log10
  tan
);

use POSIX @POSIX;

use base Exporter::;

our @CONSTANTS = qw(
  E
  LN10
  LN2
  PI
  PI1_4
  PI1_2
  PI3_4
  PI2
  SQRT1_2
  SQRT2
);

our @FUNCTIONS = qw(
  max
  min
  clamp
  random
  pow
  pro
  sum
  even
  odd
  sig
);

our @EXPORT = ( @CONSTANTS, @FUNCTIONS, @POSIX );

=head1 NAME

Math - constants and functions

=head1 SYNOPSIS

	use Math;

	printf "2.71828182845905 = %s\n", E;
	printf "1.5707963267949  = %s\n", PI1_2;
	
	printf "1 = %s\n", round(0.5);
	printf "1 = %s\n", ceil(0.5);
	printf "0 = %s\n", floor(0.5);

	or 

	use Math ();

	printf "%s\n", Math::PI;
	printf "%s\n", Math::round(0.5);

=head1 SEE ALSO

L<perlfunc> Perl built-in functions

L<PDL> for scientific and bulk numeric data processing and display

L<POSIX>

L<Math::Complex>, L<Math::Trig>, L<Math::Quaternion>, L<Math::Vectors>

=head1 Constants

=head2 E

	Euler's constant, e, approximately 2.718

=head2 LN10

	Natural logarithm of 10, approximately 2.302

=head2 LN2

	Natural logarithm of 2, approximately 0.693

=head2 PI

Ratio of the circumference of a circle to its diameter, approximately 3.1415
or L<atan2|http://perldoc.perl.org/search.html?q=atan2>( 0, -1 ).

	PI1_2 == PI * 1/2

=head2 SQRT1_2

	square root of 1/2, approximately 0.707

=head2 SQRT2

	square root of 2, approximately 1.414

=cut

use constant E    => CORE::exp(1);
use constant LN10 => CORE::log(10);
use constant LN2  => CORE::log(2);

use constant PI    => CORE::atan2( 0, -1 );    #arg(-1+i*0)
use constant PI1_4 => CORE::atan2( 1, 1 );
use constant PI1_2 => CORE::atan2( 1, 0 );
use constant PI3_4 => CORE::atan2( 1, -1 );
use constant PI2   => PI * 2;

use constant SQRT1_2 => CORE::sqrt( 1 / 2 );
use constant SQRT2   => CORE::sqrt(2);

=head1 Functions

Note number, number1, number2, base, and exponent indicate any expression with a scalar value.

=head2 abs(number)

	Returns the absolute value of number

=head2 acos(number)

	Returns the arc cosine (in radians) of number

=head2 asin(number)

	Returns the arc sine (in radians) of number

=head2 atan(number)

	Returns the arc tangent (in radians) of number

=head2 atan2(number1, number2)

	perls atan2

=head2 ceil(number)

	Returns the least integer greater than or equal to number

=head2 cos(number)

	Returns the cosine of number where number is expressed in radians

=head2 exp(number)

	Returns e, to the power of number (i.e. enumber)

=head2 even(number)

	Returns 1 if number is even otherwise 0

=head2 floor(number)

	Returns the greatest integer less than or equal to its argument

=head2 fmod(number, number)

	POSIX fmod

=head2 log(number)

	Returns the natural logarithm (base e) of number

=head2 log10(number)

	Returns the logarithm (base 10) of number

=head2 min(number1, number2)

	Returns the lesser of number1 and number2

=head2 max(number1, number2)

	Returns the greater of number1 and number2

=head2 clamp(number, min, max)

	Returns number between or equal min and max

=head2 odd(number)

	Returns 1 if number is odd otherwise 0

=head2 pow(base, exponent)

	Returns base to the exponent power (i.e. base exponent)
	
	$base ** $exponent == pow($base, $exponent);

=head2 pro(number, number1, number2, ...)

	Returns the product of its arguments

	pro(1,2,3) == 1 * 2 * 3;
	my $product = pro(@array);

=head2 random()

	Returns a pseudo-random number between 0 and 1.

=head2 random(number)

	Returns a pseudo-random number between 0 and number.

=head2 random(number1, number2)

	Returns a pseudo-random number between number1 and number2.

=head2 round(number)

	Returns the value of number rounded to the nearest integer

=head2 round(number1, digits)

	round(0.123456, 2) == 0.12;

	round(50, -2)   == 100;
	round(5, -1)    == 10;
	round(0.5)      == 1;
	round(0.05, 1)  == 0.1;
	round(0.005, 2) == 0.01;

=head2 sig(number)

	Returns 1 if number is greater 0.
	Returns -1 if number is lesser 0 otherwise -1.

=head2 sin(number)

	Returns the sine of number where number is expressed in radians

=head2 sqrt(number)

	Returns the square root of its argument

=head2 sum(number, number1, number2, ...)

	Returns the sum of its arguments

	sum(1..3) == 1 + 2 + 3;
	my $sum = sum(@array);

=head2 tan(number)

	Returns the tangent of number, where number is expressed in radians

=cut

sub abs   { CORE::abs( $_[0] ) }
sub atan2 { CORE::atan2( $_[0], $_[1] ) }

sub cos   { CORE::cos( $_[0] ) }

sub exp { CORE::exp( $_[0] ) }
sub log { CORE::log( $_[0] ) }

sub min {
	@_ = sort { $a <=> $b } @_;
	shift;
}

sub max {
	@_ = sort { $a <=> $b } @_;
	pop;
}

sub clamp { min( max( $_[0], $_[1] ), $_[2] ) }

sub pro {
	my $pro = 1;
	$pro *= $_ foreach @_;
	return @_ ? $pro : 0;
}

sub random {
	@_ = sort { $a <=> $b } @_;
	return $_[0] + rand( $_[1] - $_[0] ) if @_ == 2;
	return rand(@_);
}

sub round {
	return int( $_[0] + ( $_[0] < 0 ? -0.5 : 0.5 ) ) if @_ == 1 || $_[1] == 0; # @_ == 1 || $_[1] == 0;
	return sprintf "%.$_[1]f", $_[0] if $_[1] >= 0;

	my $f = 10**-$_[1];
	return round( $_[0] / $f ) * $f;
}

sub sig { $_[0] ? ( $_[0] < 0 ? -1 : 1 ) : 0 }

sub sum {
	my $sum = 0;
	$sum += $_ foreach @_;
	return $sum;
}

sub sin  { CORE::sin( $_[0] ) }
sub sqrt { CORE::sqrt( $_[0] ) }

sub even { $_[0] & 1 ? 0 : 1 }
sub odd { $_[0] & 1 }

1;

=head1 MODULES

=head2 Algebra

L<perlfunc>

L<Math>

L<Math::Algebra::Symbols>

L<Math::Algebra::Symbols::Sum>

L<Math::Algebra::Symbols::Term>

L<Math::Algebra::SymbolsSum>

L<Math::Algebra::SymbolsTerm>

=head2 Algorithms

L<Math::Amoeba>

L<Math::Approx>

L<Math::Approx::Symbolic>

L<Math::Base36>

L<Math::Base85>

L<Math::BaseArith>

L<Math::BaseCalc>

L<Math::BaseCnv>

L<Math::Bezier>

L<Math::Bezier::Convert>

L<Math::Big>

L<Math::Big::Factors>

L<Math::BigFloat>

L<Math::BigFloat::Trace>

L<Math::BigInt>

L<Math::BigInt::BitVect>

L<Math::BigInt::Calc>

L<Math::BigInt::CalcEmu>

L<Math::BigInt::Constant>

L<Math::BigInt::FastCalc>

L<Math::BigInt::GMP>

L<Math::BigInt::Lite>

L<Math::BigInt::Named>

L<Math::BigInt::Named::English>

L<Math::BigInt::Named::German>

L<Math::BigInt::Pari>

L<Math::BigInt::Random>

L<Math::BigInt::Scalar>

L<Math::BigInt::Trace>

L<Math::BigIntFast>

L<Math::BigInteger>

L<Math::BigRat>

L<Math::BigSimple>

L<Math::BooleanEval>

L<Math::Brent>

L<Math::Business::BlackSch>

L<Math::Business::BlackScholes>

L<Math::Business::EMA>

L<Math::Business::MACD>

L<Math::Business::SMA>

L<Math::CDF>

L<Math::Calc::Euro>

L<Math::Calc::Units>

L<Math::Calc::Units::Compute>

L<Math::Calc::Units::Convert>

L<Math::Calc::Units::Convert::Base>

L<Math::Calc::Units::Convert::Base2Metric>

L<Math::Calc::Units::Convert::Byte>

L<Math::Calc::Units::Convert::Combo>

L<Math::Calc::Units::Convert::Date>

L<Math::Calc::Units::Convert::Distance>

L<Math::Calc::Units::Convert::Metric>

L<Math::Calc::Units::Convert::Multi>

L<Math::Calc::Units::Convert::Time>

L<Math::Calc::Units::Grammar>

L<Math::Calc::Units::Rank>

L<Math::Calculator>

L<Math::Calculus::Differentiate>

L<Math::Calculus::NewtonRaphson>

L<Math::Calculus::TaylorEquivalent>

L<Math::Calculus::TaylorSeries>

L<Math::CatmullRom>

L<Math::Cephes>

L<Math::Cephes::Complex>

L<Math::Cephes::Fraction>

L<Math::Cephes::Matrix>

L<Math::Cephes::Polynomial>

L<Math::Color>

L<Math::ColorRGBA>

L<Math::Combinatorics>

=head2 Complex

L<Math::Complex>

L<Math::ConvexHull>

L<Math::Counting>

L<Math::Currency>

L<Math::Currency::GBP>

L<Math::Currency::JPY>

L<Math::Curve::Hilbert>

L<Math::Derivative>

L<Math::ES>

L<Math::ErrorPropagation>

L<Math::Evol>

L<Math::Expr>

L<Math::Expr::FormulaDB>

L<Math::Expr::MatchSet>

L<Math::Expr::Node>

L<Math::Expr::Num>

L<Math::Expr::Opp>

L<Math::Expr::OpperationDB>

L<Math::Expr::Rule>

L<Math::Expr::TypeDB>

L<Math::Expr::Var>

L<Math::Expr::VarSet>

=head2 Expression

L<Math::Expression>

L<Math::FFT>

L<Math::FFTW>

L<Math::Factor::XS>

L<Math::Fibonacci>

L<Math::Fibonacci::Phi>

L<Math::Financial>

L<Math::FitRect>

L<Math::FixedPrecision>

L<Math::Fleximal>

L<Math::Fortran>

=head2 Fourier

L<Math::Fourier>

=head2 Fractal

L<Math::Fractal::Curve>

L<Math::Fractal::DLA>

L<Math::Fractal::DLA::Explode>

L<Math::Fractal::DLA::GrowUp>

L<Math::Fractal::DLA::Race2Center>

L<Math::Fractal::DLA::Surrounding>

L<Math::Fractal::Mandelbrot>

L<Math::Fraction>

L<Math::FractionDemo>

L<Math::FresnalZone>

L<Math::FresnelZone>

L<Math::Function::Roots>

L<Math::GAP>

L<Math::GMP>

L<Math::GMPf>

L<Math::GMPq>

L<Math::GMPz>

L<Math::GMatrix>

L<Math::GSL>

L<Math::GammaFunction>

=head2 Geometry

L<Math::Geometry>

L<Math::Geometry::GPC>

L<Math::Geometry::Planar>

L<Math::Geometry::Planar::GPC>

L<Math::Geometry::Planar::GPC::Inherit>

L<Math::Geometry::Planar::GPC::Polygon>

L<Math::Geometry::Planar::Offset>

L<Math::Gradient>

L<Math::GrahamFunction>

L<Math::GrahamFunction::Object>

L<Math::GrahamFunction::SqFacts>

L<Math::GrahamFunction::SqFacts::Dipole>

L<Math::Group::Thompson>

L<Math::Gsl>

L<Math::Gsl::Polynomial>

L<Math::Gsl::Sf>

L<Math::HashSum>

L<Math::Int64>

=head2 Integral

L<Math::Integral>

L<Math::Integral::Romberg>

L<Math::Interpolate>

L<Math::Interpolator>

L<Math::Interpolator::Knot>

L<Math::Interpolator::Linear>

L<Math::Interpolator::Robust>

L<Math::Interpolator::Source>

L<Math::Intersection::StraightLine>

L<Math::Interval>

L<Math::IntervalSearch>

L<Math::LP>

L<Math::LP::Constraint>

L<Math::LP::LinearCombination>

L<Math::LP::Object>

L<Math::LP::Solve>

L<Math::LP::Variable>

L<Math::Libm>

L<Math::LinearCombination>

L<Math::LinearProg>

L<Math::LogRand>

=head2 Logic

L<Math::Logic>

L<Math::Logic::Predicate>

L<Math::Logic::Ternary>

L<Math::MPFR>

L<Math::MVPoly>

L<Math::MVPoly::Ideal>

L<Math::MVPoly::Integer>

L<Math::MVPoly::Monomial>

L<Math::MVPoly::Parser>

L<Math::MVPoly::Polynomial>

L<Math::Macopt>

L<Math::MagicSquare>

L<Math::MagicSquare::Generator>

L<Math::Matlab>

L<Math::Matlab::Engine>

L<Math::Matlab::Local>

L<Math::Matlab::Pool>

L<Math::Matlab::Remote>

L<Math::Matlab::Server>

=head2 Matrix

L<Math::Matrix>

L<Math::Matrix::SVD>

L<Math::MatrixBool>

L<Math::MatrixCplx>

L<Math::MatrixReal>

L<Math::MatrixReal::Ext1>

L<Math::MatrixSparse>

L<Math::MultiplicationTable>

L<Math::NoCarry>

L<Math::Nocarry>

L<Math::NumberCruncher>

=head2 Numbers

L<Math::Numbers>

L<Math::ODE>

L<Math::Orthonormalize>

L<Math::PRSG>

L<Math::Pari>

L<Math::PariBuild>

L<Math::PartialOrder>

L<Math::PartialOrder::Base>

L<Math::PartialOrder::CEnum>

L<Math::PartialOrder::CMasked>

L<Math::PartialOrder::Caching>

L<Math::PartialOrder::LRUCaching>

L<Math::PartialOrder::Loader>

L<Math::PartialOrder::Std>

L<Math::Polygon>

L<Math::Polygon::Calc>

L<Math::Polygon::Clip>

L<Math::Polygon::Surface>

L<Math::Polygon::Transform>

L<Math::Polyhedra>

=head2 Polynom

L<Math::Polynom>

L<Math::Polynomial>

L<Math::Polynomial::Solve>

L<Math::Prime::XS>

L<Math::Project>

L<Math::Project3D>

L<Math::Project3D::Function>

L<Math::Project3D::Plot>

L<Math::Quaternion>

L<Math::RPN>

L<Math::Rand48>

=head2 Random

L<Math::Random>

L<Math::Random::AcceptReject>

L<Math::Random::Brownian>

L<Math::Random::Cauchy>

L<Math::Random::MT>

L<Math::Random::MT::Auto>

L<Math::Random::MT::Auto::Range>

L<Math::Random::MT::Auto::Util>

L<Math::Random::OO>

L<Math::Random::OO::Bootstrap>

L<Math::Random::OO::Normal>

L<Math::Random::OO::Uniform>

L<Math::Random::OO::UniformInt>

L<Math::Random::TT800>

L<Math::RandomOrg>

L<Math::Roman>

L<Math::Rotation>

L<Math::Round>

L<Math::Round::Var>

L<Math::RungeKutta>

L<Math::SO3>

L<Math::Sequence>

L<Math::Series>

L<Math::SigFigs>

=head2 Simple

L<Math::Simple>

L<Math::SimpleInterest>

L<Math::SimpleVariable>

L<Music::is::Math|http://www.discogs.com/release/24432>

L<Math::Sparse::Matrix>

L<Math::Sparse::Vector>

L<Math::SparseMatrix>

L<Math::SparseVector>

L<Math::Spline>

L<Math::Stat>

=head2 String

L<Math::String>

L<Math::String::Charset>

L<Math::String::Charset::Grouped>

L<Math::String::Charset::Nested>

L<Math::String::Charset::Wordlist>

L<Math::String::Sequence>

=head2 Symbolic

L<Math::Symbolic>

L<Math::Symbolic::AuxFunctions>

L<Math::Symbolic::Base>

L<Math::Symbolic::Compiler>

L<Math::Symbolic::Constant>

L<Math::Symbolic::Custom>

L<Math::Symbolic::Custom::Base>

L<Math::Symbolic::Custom::CCompiler>

L<Math::Symbolic::Custom::Contains>

L<Math::Symbolic::Custom::DefaultDumpers>

L<Math::Symbolic::Custom::DefaultMods>

L<Math::Symbolic::Custom::DefaultTests>

L<Math::Symbolic::Custom::ErrorPropagation>

L<Math::Symbolic::Custom::LaTeXDumper>

L<Math::Symbolic::Custom::Pattern>

L<Math::Symbolic::Custom::Pattern::Export>

L<Math::Symbolic::Custom::Simplification>

L<Math::Symbolic::Custom::Transformation>

L<Math::Symbolic::Custom::Transformation::Group>

L<Math::Symbolic::Derivative>

L<Math::Symbolic::ExportConstants>

L<Math::Symbolic::MiscAlgebra>

L<Math::Symbolic::MiscCalculus>

L<Math::Symbolic::Operator>

L<Math::Symbolic::Parser>

L<Math::Symbolic::Parser::Precompiled>

L<Math::Symbolic::Parser::Yapp>

L<Math::Symbolic::Variable>

L<Math::Symbolic::VectorCalculus>

L<Math::SymbolicX::BigNum>

L<Math::SymbolicX::Calculator>

L<Math::SymbolicX::Calculator::Command>

L<Math::SymbolicX::Calculator::Command::Assignment>

L<Math::SymbolicX::Calculator::Command::DerivativeApplication>

L<Math::SymbolicX::Calculator::Command::Insertion>

L<Math::SymbolicX::Calculator::Command::Transformation>

L<Math::SymbolicX::Calculator::Interface>

L<Math::SymbolicX::Calculator::Interface::Shell>

L<Math::SymbolicX::Calculator::Interface::Web>

L<Math::SymbolicX::Calculator::Interface::Web::Server>

L<Math::SymbolicX::Complex>

L<Math::SymbolicX::Error>

L<Math::SymbolicX::Inline>

L<Math::SymbolicX::NoSimplification>

L<Math::SymbolicX::ParserExtensionFactory>

L<Math::SymbolicX::Statistics::Distributions>

L<Math::Systems>

=head2 Taylor

L<Math::Taylor>

L<Math::Telephony::ErlangB>

L<Math::Telephony::ErlangC>

L<Math::TotalBuilder>

L<Math::TotalBuilder::Common>

L<Math::TriangularNumbers>

=head2 Trig

L<Math::Trig>

L<Math::Trig::Degree>

L<Math::Trig::Gradian>

L<Math::Trig::Radian>

L<Math::Trig::Units>

L<Math::TrulyRandom>

L<Math::Units>

L<Math::Units::PhysicalValue>

=head2 Vector

L<Math::Vec>

L<Math::Vec2>

L<Math::Vec3>

L<Math::VecStat>

L<Math::Vector>

L<Math::Vectors>

L<Math::Vector::SortIndexes>

L<Math::VectorReal>

L<Math::Zap::Vector>

L<Math::Zap::Vector2>

=head2 ematica

L<Math::Volume::Rotational>

L<Math::WalshTransform>

L<Math::XOR>

L<Math::Zap::Color>

L<Math::Zap::Cube>

L<Math::Zap::Draw>

L<Math::Zap::Exports>

L<Math::Zap::Line2>

L<Math::Zap::Matrix>

L<Math::Zap::Matrix2>

L<Math::Zap::Rectangle>

L<Math::Zap::Triangle>

L<Math::Zap::Triangle2>

L<Math::Zap::Unique>

L<Math::ematica>

=head1 SEE ALSO

L<perlfunc> Perl built-in functions

L<PDL> for scientific and bulk numeric data processing and display

L<POSIX>

L<Math::Complex>, L<Math::Trig>, L<Math::Quaternion>, L<Math::Vectors>

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

