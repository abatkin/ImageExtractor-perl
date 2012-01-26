#!env perl

# Set up some sane defaults
use strict;
use warnings;
use v5.12;

use Pod::Usage;
use Getopt::Long;

use ImageExtractor;

# Parse the command line
my $dir = "images";
my ($verbose, $help);

my $result = GetOptions(
    "dir=s"         => \$dir,
    "verbose"       => \$verbose,
    "help"          => \$help
);

pod2usage(0) if $help;

my $extractor = ImageExtractor->new($dir, $verbose);

mkdir $dir unless -d $dir;
foreach my $url (@ARGV) {
    $extractor->process_url($url);
}


__END__

=head1 NAME

extract-images.pl - Downloads images from webpages

=head1 VERSION

Version 1.0

=head1 SYNOPSIS

extract-images.pl [B<--dir>=I<dir>] [B<--verbose>] I<urls...>

  Downloads images from webpages

extract-images.pl B<--help>

=head1 ABSTRACT

B<extract-images.pl> bulk downloads images from webpages.

The basic process is:

=over 4

=item * Download a set of webpages

=item * Find all of the images specified in the HTML

=item * Download all of the images

=back

=head1 OPTIONS

=over 4

=item B<--dir>=I<dir>

The output directory. Defaults to "images".

=item B<--verbose>

Print verbose messages during processing.

=back

=head1 AUTHOR

Adam Batkin, C<< <adam at batkin.net> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Adam Batkin.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


