use strict;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'             => 'jacode.pl',
    'VERSION_FROM'     => 'META.yml', # finds $VERSION
    ($] >= 5.005 ?                    # Add these new keywords supported since 5.005
      ('PREREQ_PM'     => {},         # e.g., Module::Name => 1.1
       'ABSTRACT_FROM' => 'META.yml', # retrieve abstract from module
       'AUTHOR'        => 'ina <ina@cpan.org>',
      )
      :
      ()
    ),
);
__END__
