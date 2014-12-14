package Tu::HelperFactory;

use strict;
use warnings;

use base 'Tu::Factory';

require Carp;
use Scalar::Util ();

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{services} = $params{services};

    $self->{env} = $params{env};
    Scalar::Util::weaken($self->{env});

    return $self;
}

sub register_helper {
    my $self = shift;
    my ($name, $instance) = @_;

    Carp::croak("Helper '$name' already registered")
      if exists $self->{helpers}->{$name};

    $self->{helpers}->{$name} = $instance;
}

sub build {
    my $self = shift;
    my ($name, @args) = @_;

    return $self->SUPER::build(
        $name,
        services => $self->{services},
        env      => $self->{env},
        @args
    );
}

sub create_helper {
    my $self = shift;
    my ($name) = @_;

    if (exists $self->{helpers}->{$name}) {
        my $helper = $self->{helpers}->{$name};

        return
            ref $helper eq 'CODE'          ? $helper->()
          : Scalar::Util::blessed($helper) ? $helper
          :                                  $self->build($helper);
    }

    return $self->build($name);
}

sub DESTROY { }

our $AUTOLOAD;

sub AUTOLOAD {
    my $self = shift;

    my ($method) = (split /::/, $AUTOLOAD)[-1];

    return if $method =~ /^[A-Z]/;
    return if $method =~ /^_/;

    return $self->create_helper($method, @_);
}

1;
