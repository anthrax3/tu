package Turnaround::Plugin::I18N;

use strict;
use warnings;

use base 'Turnaround::Base';

use Turnaround::I18N;

sub BUILD {
    my $self = shift;

    $self->{service_name}             ||= 'i18n';
    $self->{helper_name}              ||= $self->{service_name};
    $self->{helper_name}              ||= $self->{service_name};
    $self->{insert_before_middleware} ||= 'RequestDispatcher';
}

sub startup {
    my $self = shift;

    my $i18n = Turnaround::I18N->new(app_class => $self->{app_class});
    $self->{services}->register($self->{service_name} => $i18n);

    $self->{builder}
      ->insert_before_middleware($self->{insert_before_middleware},
        'I18N', i18n => $i18n);
}

sub run {
    my $self = shift;
    my ($env) = @_;

    my $i18n = $self->{services}->service('i18n');
    $env->{'turnaround.displayer.vars'}->{'loc'} =
      sub { $env->{'turnaround.i18n.maketext'}->loc(@_) };

    my $languages_names = $i18n->get_languages_names;
    if (keys %$languages_names > 1) {
          $env->{'turnaround.displayer.vars'}->{'languages'} = [
              map { {code => $_, name => $languages_names->{$_}} }
                keys %$languages_names
          ];
    }

    $env->{'turnaround.displayer.vars'}->{helpers}->register_helper(
          $self->{helper_name} => 'Turnaround::Plugin::I18N::Helper');
}

1;