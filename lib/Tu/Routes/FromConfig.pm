package Tu::Routes::FromConfig;

use strict;
use warnings;

use base 'Tu::FromConfig';

use Tu::Routes;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{routes} = $params{routes};

    $self->{routes} ||= Tu::Routes->new;

    return $self;
}

sub _from_config {
    my $self = shift;
    my ($config) = @_;

    my $routes = $self->{routes};

    return $routes unless $config && ref $config eq 'ARRAY';

    foreach my $route (@{$config}) {
        $routes->add_route(delete $route->{route}, %$route);
    }

    return $routes;
}

1;
