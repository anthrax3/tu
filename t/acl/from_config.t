use strict;
use warnings;

use Test::More;

use Tu::ACL;
use Tu::ACL::FromConfig;

subtest 'build acl from config' => sub {
    my $acl = _build_acl()->load('t/acl/from_config_t/acl.yml');

    ok $acl->is_allowed('anonymous', 'login');
    ok !$acl->is_allowed('anonymous', 'logout');
    ok !$acl->is_allowed('user',      'login');
    ok $acl->is_allowed('user', 'logout');
};

subtest 'do nothing when empty' => sub {
    my $acl = _build_acl()->load('t/acl/from_config_t/empty.yml');

    ok !$acl->is_allowed('anonymous', 'login');
};

subtest 'accept acl from outside' => sub {
    my $acl =
      _build_acl(acl => Tu::ACL->new)->load('t/acl/from_config_t/acl.yml');

    ok $acl->is_allowed('anonymous', 'login');
};

sub _build_acl {
    return Tu::ACL::FromConfig->new(@_);
}

done_testing;
