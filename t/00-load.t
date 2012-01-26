#!perl -T

use Test::More tests => 3;

BEGIN {
    use_ok( 'ImageExtractor' ) || print "Bail out!\n";
    use_ok( 'ImageExtractor::Source' ) || print "Bail out!\n";
    use_ok( 'ImageExtractor::Image' ) || print "Bail out!\n";
}

diag( "Testing ImageExtractor $ImageExtractor::VERSION, Perl $], $^X" );
