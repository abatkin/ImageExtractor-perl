package ImageExtractor::Source;

use strict;
use warnings;
use v5.12;

use Moose;
use Try::Tiny;
use LWP::UserAgent;
use HTML::TreeBuilder::XPath;
use URI::URL ();

use ImageExtractor::Image;

has 'url', is => 'ro', isa => 'Str';
has 'ua', is => 'ro', isa => 'LWP::UserAgent';
has 'context', is => 'ro', isa => 'ImageExtractor';
has 'imagelist', is => 'rw', isa => 'ArrayRef[URI::URL]';

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my $context = shift;
    my $url = shift;
    return {
        context => $context,
        url => $url,
        ua => LWP::UserAgent->new
    };
};

sub images {
    my $self = shift;
    my @image_list = $self->get_imagelist;
    return scalar(@image_list) unless wantarray;

    my @images;
    foreach my $url (@image_list) {
        my $url_string = $url->as_string;
        next if $self->context->has_processed($url_string);
        push(@images, ImageExtractor::Image->new($url, sub {
            return $self->fetch_url($url_string);
        }));
    }
    return @images;
}

sub make_url_absolute {
    my $self = shift;
    my $orig_url = shift;

    my $base_url = $self->url;
    return URI::URL->new($orig_url, $base_url)->abs;
}

sub get_imagelist {
    my $self = shift;

    return @{$self->imagelist} if defined($self->imagelist);

    my $tree = $self->get_page_tree;
    my @imagelist = map({$self->make_url_absolute($_)} $tree->findnodes_as_strings('//img/@src'));
    $self->imagelist(\@imagelist);
    return @imagelist;
}

sub get_page_tree {
    my $self = shift;
    my $url = $self->url;

    my $html = $self->fetch_url($url);
    return HTML::TreeBuilder::XPath->new_from_content($html);
}

sub fetch_url {
    my $self = shift;
    my $url = shift;

    $self->context->log_verbose("Fetching [$url]");
    my $response = $self->ua->get($url);
    if ($response->is_success) {
        return $response->decoded_content;
    } else {
        die "Skipping $url: " . $response->status_line;
    }
}

1;

