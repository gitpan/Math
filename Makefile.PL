use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME'         => 'Math',
	'VERSION_FROM' => 'lib/Math.pm',    # finds $VERSION
	'PREREQ_PM'    => {
		Test::More       => 0,
		POSIX            => 0,
		Math::Quaternion => 0,
	},                                  # e.g., Module::Name => 1.1

	#ABSTRACT_FROM => 'lib/Math/Color.pm',
	ABSTRACT => 'Contains some vector math',
	AUTHOR   => 'Holger Seelig <holger.seelig@yahoo.de>',
	#NO_META  => 1,
);

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
cat MANIFEST | cpanversion+ 0.001 | grep OK
make test | grep OK
make dist | grep OK
mv *.gz ../


#mk install
sudo cpan . | grep OK

