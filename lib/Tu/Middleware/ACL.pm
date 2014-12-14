package Tu::Middleware::ACL;

use strict;
use warnings;

use base 'Tu::Middleware';

use Carp qw(croak);
use Scalar::Util qw(blessed);

use Tu::Exception::HTTP;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{acl} = $params{acl};
    croak 'acl required' unless $self->{acl};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_acl($env);
    return $res if $res;

    return $self->app->($env);
}

sub _acl {
    my $self = shift;
    my ($env) = @_;

    return $self->_deny($env) unless my $user = $env->{'turnaround.user'};

    my $action = $self->_get_action($env);

    my $role = blessed $user ? $user->role : $user->{role};

    return $self->_deny($env) unless $self->{acl}->is_allowed($role, $action);

    return;
}

sub _get_action {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = $env->{'turnaround.dispatched_request'};

    croak 'No DispatchedRequest found' unless $dispatched_request;

    return $dispatched_request->action;
}

sub _deny {
    my $self = shift;
    my ($env) = @_;

    my $redirect_to = $self->{redirect_to};
    if (defined $redirect_to && $env->{PATH_INFO} ne $redirect_to) {
        return [302, ['Location' => $redirect_to], ['']];
    }

    Tu::Exception::HTTP->throw('Forbidden', code => 403);
}

1;
