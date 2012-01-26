use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ImageExtractor',
    AUTHOR              => q{Adam Batkin <adam@batkin.net>},
    VERSION_FROM        => 'lib/ImageExtractor.pm',
    ABSTRACT_FROM       => 'lib/ImageExtractor.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    EXE_FILES           => ['scripts/extract-images.pl'],
    PREREQ_PM => {
        'Test::More' => 0,
        'Getopt::Long' => 0,
        'HTML::TreeBuilder::XPath' => 0,
        'LWP::UserAgent' => 0,
        'Moose' => 0,
        'Pod::Usage' => 0,
        'Try::Tiny' => 0,
        'URI::URL' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ImageExtractor-*' },
);
