use strict;
use warnings;

use Test::More;

use Tu::Validator::In;

subtest 'returns true when in' => sub {
    my $rule = _build_rule();

    ok $rule->is_valid('foo', [qw/foo bar/]);
};

subtest 'returns false when not in' => sub {
    my $rule = _build_rule();

    ok !$rule->is_valid('baz', [qw/foo bar/]);
};

sub _build_rule {
    return Tu::Validator::In->new(@_);
}

done_testing;
