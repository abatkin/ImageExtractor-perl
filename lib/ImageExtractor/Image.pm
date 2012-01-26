package ImageExtractor::Image;

use strict;
use warnings;
use v5.12;

use Moose;

has 'data_cache', is => 'rw', isa => 'Str';
has 'fetcher', is => 'ro', isa => 'CodeRef';
has 'url', is => 'ro', isa => 'URI::URL';

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my $url = shift;
    my $fetcher = shift;
    return {
        url => $url,
        fetcher => $fetcher
    };
};

sub data {
    my $self = shift;
    return $self->data_cache if defined $self->data_cache;

    my $data = $self->fetcher->();
    $self->data_cache($data);
    return $data;
}

1;

