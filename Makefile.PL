use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
              NAME          => 'Scrumy',
              AUTHOR        => q{Keith Minkler <kminkler@synacor.com>},
              VERSION_FROM  => 'lib/Scrumy.pm',
              ABSTRACT_FROM => 'lib/Scrumy.pm',
              PREREQ_PM     => {'Test::More' => 0,},
              dist          => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',},
              clean => {FILES => 'Scrumy-* MANIFEST*'},
             );
