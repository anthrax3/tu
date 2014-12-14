package Tu::Middleware::I18N;

use strict;
use warnings;

use base 'Tu::Middleware::LanguageDetection';

use Carp qw(croak);

sub new {
    my $class = shift;
    my (%params) = @_;

    croak 'i18n is required' unless my $i18n = delete $params{i18n};

    $params{default_language} = $i18n->default_language;
    $params{languages}        = [$i18n->languages];

    my $self = $class->SUPER::new(%params);

    $self->{i18n} = $i18n;

    return $self;
}

sub _detect_language {
    my $self = shift;
    my ($env) = @_;

    $self->SUPER::_detect_language($env);

    my $language = $env->{'turnaround.i18n.language'};
    $env->{'turnaround.i18n.maketext'} = $self->{i18n}->handle($language);

    $env->{'turnaround.displayer.vars'}->{'loc'} =
      sub { $env->{'turnaround.i18n.maketext'}->loc(@_) };

    $env->{'turnaround.displayer.vars'}->{'lang'} =
      $env->{'turnaround.i18n.language'};
}

1;
