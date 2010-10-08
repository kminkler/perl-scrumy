#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Scrumy' );
}

diag( "Testing Scrumy $Scrumy::VERSION, Perl $], $^X" );
