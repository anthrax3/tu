package Tu::Middleware::LanguageDetection;

use strict;
use warnings;

use base 'Tu::Middleware';

use Carp qw(croak);
use List::Util qw(first);
use I18N::AcceptLanguage;
use I18N::LangTags::List ();
use Tu::Scope;

sub new {
    my $self = shift->SUPER::new(@_);

    croak 'default_language required' unless $self->{default_language};
    croak 'languages required'        unless $self->{languages};

    $self->{use_path}    = 1 unless defined $self->{use_path};
    $self->{use_session} = 1 unless defined $self->{use_session};
    $self->{use_header}  = 1 unless defined $self->{use_header};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_detect_language($env);

    return $self->app->($env);
}

sub _detect_language {
    my $self = shift;
    my ($env) = @_;

    my $lang;
    $lang = $self->_detect_from_path($env) if $self->{use_path};
    $lang ||= $self->_detect_from_session($env) if $self->{use_session};
    $lang ||= $self->_detect_from_header($env)  if $self->{use_header};
    $lang = $self->_detect_from_custom_cb($env, $lang) if $self->{custom_cb};

    $lang ||= $self->{default_language};

    my $scope = Tu::Scope->new($env);
    $scope->set('i18n.language'      => $lang);
    $scope->set('i18n.language_name' => I18N::LangTags::List::name($lang));

    if ($self->{use_session}) {
        $env->{'psgix.session'}->{'tu.i18n.language'} = $lang;
    }
}

sub _detect_from_session {
    my $self = shift;
    my ($env) = @_;

    return unless my $session = $env->{'psgix.session'};

    return unless my $lang = $session->{'tu.i18n.language'};

    return unless $self->_is_allowed($lang);

    return $lang;
}

sub _detect_from_path {
    my $self = shift;
    my ($env) = @_;

    my $path = $env->{PATH_INFO};

    my $languages_re = join '|', @{$self->{languages}};
    if ($path =~ s{^/($languages_re)(?=/|$)}{}) {
        $env->{PATH_INFO} = $path;
        return $1 if $self->_is_allowed($1);
    }

    return;
}

sub _detect_from_header {
    my $self = shift;
    my ($env) = @_;

    return unless my $accept_header = $env->{HTTP_ACCEPT_LANGUAGE};

    return
      unless my $lang =
      $self->_build_acceptor->accepts($accept_header, $self->{languages});

    return unless $self->_is_allowed($lang);

    return $lang;
}

sub _detect_from_custom_cb {
    my $self = shift;
    my ($env, $detected_lang) = @_;

    my $lang = $self->{custom_cb}->($env, $detected_lang);

    return unless $lang;

    return unless $self->_is_allowed($lang);

    return $lang;
}

sub _build_acceptor {
    my $self = shift;

    return I18N::AcceptLanguage->new();
}

sub _is_allowed {
    my $self = shift;
    my ($lang) = @_;

    return !!first { $lang eq $_ } $self->{default_language},
      @{$self->{languages}};
}

1;
