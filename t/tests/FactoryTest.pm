package FactoryTest;

use strict;
use warnings;

use base 'TestBase';

use lib 't/tests/FactoryTest';

use Test::More;
use Test::Fatal;

use Turnaround::Factory;

sub build_an_object : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    my $foo = $factory->build('Foo');

    ok($foo);
}

sub build_an_object_with_default_args : Test {
    my $self = shift;

    my $factory = $self->_build_factory(default_args => {foo => 'bar'});

    my $foo = $factory->build('Foo');

    is($foo->{foo}, 'bar');
}

sub throw_on_unknown_class : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    isa_ok(exception { $factory->build('Unknown') }, 'Turnaround::Exception::ClassNotFound');
}

sub throw_on_syntax_errors : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    ok(exception { $factory->build('WithSyntaxErrors') }, 'Turnaround::Exception::Base');
}

sub throw_during_creation_errors : Test {
    my $self = shift;

    my $factory = $self->_build_factory;
    my $e = exception { $factory->build('DieDuringCreation') };
    isa_ok($e, 'Turnaround::Exception::Base');
}

sub _build_factory {
    my $self = shift;

    return Turnaround::Factory->new(@_);
}

1;