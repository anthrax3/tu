use strict;
use warnings;

use Test::More;
use Test::Requires;
use Test::MonkeyMock;

BEGIN { test_requires 'Plack::Middleware::Session::Cookie' };

use Tu::Middleware::Session::Cookie;

subtest 'pass session config' => sub {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { {session => {secret => '123'}} });
    my $mw = _build_middleware(services => $services);

    is $mw->secret, '123';
};

sub _build_middleware { Tu::Middleware::Session::Cookie->new(@_) }

done_testing;
