#package Makefile
use 5.006;
use ExtUtils::MakeMaker;

BEGIN {
	# See lib/ExtUtils/MakeMaker.pm for Details of how to influence
	# the Contents of the Makefile that is written.
	WriteMakefile(
		'NAME'         => 'Math',
		'VERSION_FROM' => 'lib/Math.pm',    # finds $VERSION
		'PREREQ_PM'    => {
			Test::More => 0,
			base       => 0,
			constant   => 0,
			Exporter   => 0,
			POSIX      => 0,
		},                                     # e.g., Module::Name => 1.1

		#ABSTRACT_FROM => 'lib/Math/Color.pm',
		#ABSTRACT => 'Contains the Abstract that will be displayed on CPAN',
		AUTHOR => 'Holger Seelig <holger.seelig@yahoo.de>',
		#NO_META  => 1,
	);
}
__END__

#clean
cd '/home/holger/perl/cpan/Math'
perl Makefile.PL | grep OK
sudo make clean | grep OK
sudo rm Makefile.old 2>&1 | grep OK
sudo rm MANIFEST 2>&1 | grep OK
sudo rm MANIFEST.bak 2>&1 | grep OK


#mk dist
perl Makefile.PL | grep OK
make manifest 2>&1 | grep OK
cat MANIFEST | cpanversion+ 0.0001 | grep OK
perl Makefile.PL | grep OK
make test | grep OK
make dist | grep OK
mv *.gz ../


#mk install
sudo cpan . | grep OK


#mk test
perl Makefile.PL | grep OK
make test
