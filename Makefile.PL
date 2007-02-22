use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Pod::InComments',
    VERSION_FROM      => 'lib/Pod/InComments.pm', # finds $VERSION
    PREREQ_PM         => { Pod::POM => 0 }, 
    EXE_FILES        => [ 'bin/config2pod.pl' ],

    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Pod/InComments.pm', # retrieve abstract from module
       AUTHOR         => 'Jaap Voets <narked@xperience-automatisering.nl>') : ()),
);
