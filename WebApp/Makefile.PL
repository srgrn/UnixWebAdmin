use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WebApp',
    AUTHOR              => 'eran@zimbler.net',
    VERSION_FROM        => 'lib/WebApp.pm',
    ABSTRACT            => 'This is the unix project for afeka unix course',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
		'IO::Interface::Simple' => 0, 
        'Dancer'     => 1.3060,
		'Modern::Perl' => 0, 
	'Plack'	     => 0,
	'Proc'       => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WebApp-*' },
);
