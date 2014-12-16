package Tu::Builder;

use strict;
use warnings;

use Carp qw(croak);
use Scalar::Util ();

use Tu::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{middleware} = [];
    $self->{namespaces} = $params{namespaces} || [];

    $self->{loader} ||= Tu::Loader->new(namespaces =>
          [@{$self->{namespaces}}, qw/Tu::Middleware:: Plack::Middleware::/]);

    return $self;
}

sub add_middleware {
    my $self = shift;
    my ($middleware, @args) = @_;

    push @{$self->{middleware}}, {name => $middleware, args => [@args]};

    return $self;
}

sub insert_before_middleware {
    my $self = shift;
    my ($before, $middleware, @args) = @_;

    my $i = $self->_find_middleware_index($before);

    splice @{$self->{middleware}}, $i, 0,
      {name => $middleware, args => [@args]};

    return $self;
}

sub insert_after_middleware {
    my $self = shift;
    my ($before, $middleware, @args) = @_;

    my $i = $self->_find_middleware_index($before);

    splice @{$self->{middleware}}, $i + 1, 0,
      {name => $middleware, args => [@args]};

    return $self;
}

sub list_middleware {
    my $self = shift;

    my $list = [];

    foreach my $middleware (@{$self->{middleware}}) {
        my $name = $middleware->{name};
        push @$list, ref $name eq 'CODE' ? '__ANON__' : $name;
    }

    return $list;
}

sub wrap {
    my $self = shift;
    my ($app) = @_;

    my $loader = $self->{loader};

    foreach my $middleware (reverse @{$self->{middleware}}) {
        my $instance = $middleware->{name};

        if (ref $instance eq 'CODE') {
            $app = $instance->($app);
        }
        elsif (!Scalar::Util::blessed($instance)) {
            $instance = $loader->load_class($instance);
            $instance = $instance->new(@{$middleware->{args}});

            $app = $instance->wrap($app);
        }
    }

    return $app;
}

sub _find_middleware_index {
    my $self = shift;
    my ($middleware) = @_;

    my $i = 0;
    foreach my $mw (@{$self->{middleware}}) {
        if ($mw->{name} eq $middleware) {
            return $i;
        }
        $i++;
    }

    croak "Unknown middleware '$middleware'";
}

1;
