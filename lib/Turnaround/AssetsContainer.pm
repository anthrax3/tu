package Turnaround::AssetsContainer;

use strict;
use warnings;

use base 'Turnaround::Base';

sub BUILD {
    my $self = shift;

    $self->{paths} = [];
}

sub require {
    my $self = shift;
    my ($path, $type) = @_;

    return $self if grep { $path eq $_->{path} } @{$self->{paths}};

    ($type) = $path =~ m/\.([^\.]+)$/ unless $type;

    push @{$self->{paths}}, {type => $type, path => $path};

    return $self;
}

sub include {
    my $self = shift;
    my ($type) = @_;

    my @html;
    foreach my $asset (@{$self->{paths}}) {
        next if $type && $asset->{type} ne $type;

        if ($asset->{type} eq 'js') {
            push @html,
              qq|<script src="$asset->{path}" type="text/javascript"></script>|;
        }
    }

    return join "\n", @html;
}

1;