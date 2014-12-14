use strict;
use warnings;

use lib 't/factory_t';

use Test::More;
use Test::Fatal;

use Tu::Factory;

subtest 'build_an_object' => sub {
    my $factory = _build_factory();

    my $foo = $factory->build('Foo');

    ok($foo);
};

subtest 'not_throw_on_unknown_class' => sub {
    my $factory = _build_factory(try => 1);

    ok !$factory->build('Unknown');
};

subtest 'throw_on_unknown_class' => sub {
    my $factory = _build_factory();

    like exception { $factory->build('Unknown') },
      qr/Can't locate Unknown\.pm in \@INC/;
};

subtest 'rethrow_during_creation_errors' => sub {
    my $factory = _build_factory();

    ok exception { $factory->build('DieDuringCreation') };
};

sub _build_factory {
    return Tu::Factory->new(@_);
}

done_testing;
