use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Util::Nginx',
    AUTHOR           => q{norbornen <reiserford@gmail.com>},
    VERSION_FROM     => 'lib/Util/Nginx.pm',
    ABSTRACT_FROM    => 'lib/Util/Nginx.pm',
    LICENSE          => 'mit',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'common::sense'=>0,
        'DBI'=>0,
        'Carp'=>0,
        'Data::Dumper'=>0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Util-Nginx-*' },
);
