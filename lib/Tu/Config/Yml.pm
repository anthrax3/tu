package Tu::Config::Yml;

use strict;
use warnings;

use Carp qw(croak);
use YAML::Tiny;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub parse {
    my $self = shift;
    my ($config) = @_;

    $config = YAML::Tiny->read_string($config) or croak $YAML::Tiny::errstr;
    return $config->[0] || {};
}

1;
