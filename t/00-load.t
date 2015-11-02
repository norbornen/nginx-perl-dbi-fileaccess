#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 4;

BEGIN {
    use_ok( 'Util::Nginx' ) || print "Bail out!\n";
    use_ok( 'Util::Nginx::Helper' ) || print "Bail out!\n";
    use_ok( 'Util::Nginx::DB' ) || print "Bail out!\n";
    use_ok( 'Util::Nginx::FileAccessor' ) || print "Bail out!\n";
}

diag( "Testing Util::Nginx $Util::Nginx::VERSION, Perl $], $^X" );
