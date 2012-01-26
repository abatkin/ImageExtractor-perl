package ImageExtractor 1.0;

use strict;
use warnings;
use v5.12;

use constant MAX_FILENAME_ATTEMPTS => 10;

use IO::File;
use ImageExtractor::Source;
use Try::Tiny;

use Moose;

has 'dir', is => 'ro', isa => 'Str';
has 'verbose', is => 'ro';
has 'processed_images', is => 'ro', isa => 'HashRef';

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my $dir = shift;
    my $verbose = shift;
    return {
        dir => $dir,
        verbose => $verbose,
        processed_images => {}
    };
};

sub process_url {
    my $self = shift;
    my $url = shift;

    my $source = ImageExtractor::Source->new($self, $url);
    foreach my $image ($source->images) {
        try {
            $self->save_image($image);
        } catch {
            $self->log_warn($_);
        }
    }
}

# Return true if we have processed this URL before
# Otherwise, return false and mark the URL as processed
sub has_processed {
    my $self = shift;
    my $url = shift;

    return 1 if $self->processed_images->{$url};
    $self->processed_images->{$url} = 1;
    return 0;
}

# Utility functions
sub save_image {
    my $self = shift;
    my $image = shift;
    my $filename = $self->get_image_filename($image);

    my $url_string = $image->url->as_string;
    my $actual_filename = $self->get_actual_filename($filename);
    my $data = $image->data;
    $self->log_verbose("Writing $url_string to $actual_filename");
    $self->save_file($actual_filename, $data);
}

sub save_file {
    my $self = shift;
    my $filename = shift;
    my $data = shift;

    my $fh = IO::File->new($filename, "w");
    die "Unable to write $filename: $!" unless defined $fh;
    $fh->binmode;
    $fh->write($data);
    $fh->close;
}

# Filename manipulation
sub get_actual_filename {
    my $self = shift;
    my $orig_name = shift;

    my $dir = $self->dir;
    die "Invalid filename $orig_name" if $orig_name =~ /^\.+$/;
    return "$dir/$orig_name" unless -e "$dir/$orig_name";

    my ($prefix, $suffix) = ($orig_name =~ /(.*)\.(.*)/);
    $prefix ||= '';
    $suffix ||= '';
    for (my $i = 1; $i < MAX_FILENAME_ATTEMPTS; $i++) {
        my $attempted_name;
        if($orig_name !~ /\./) {
            $attempted_name = "$dir/$orig_name$i";
        } else {
            $attempted_name = "$dir/$prefix$i.$suffix";
        }
        return $attempted_name unless -e $attempted_name;
    }
}

sub get_image_filename {
    my $self = shift;
    my $image = shift;

    my $path = $image->url->epath;
    my $filename = $path;
    $filename =~ s{.*/}{};
    if ($filename eq '') {
        my $url_string = $image->url->as_string;
        die "Skipping $url_string: Unable to determine filename";
    }
    return $filename;
}

# Logging
sub log_verbose {
    my $self = shift;
    my $message = shift;
    return unless $self->verbose;
    say STDERR $message;
}

sub log_warn {
    my $self = shift;
    my $message = shift;
    say STDERR "Warning: $message";
}

=head1 NAME

ImageExtractor - Downloads images from webpages

=head1 VERSION

Version 1.0

=head1 DESCRIPTION

Bulk downloads images from webpages.

The basic process is:

=over 4

=item * Download a set of webpages

=item * Find all of the images specified in the HTML

=item * Download all of the images

=back

=head1 AUTHOR

Adam Batkin, C<< <adam at batkin.net> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Adam Batkin.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;

