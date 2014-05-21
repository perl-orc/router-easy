use Test::More;
use Test::Differences;
use strictures;
use Router::Simple;

my $rs = Router::Simple->new;

# Test utility functions

eq_or_diff($rs->simple('/foo')->path, '/foo');
eq_or_diff($rs->friendly('/foo/:bar')->path, '/foo/:bar');
eq_or_diff($rs->regex('/foo/(?<bar>[a-z]+)')->path, '/foo/(?<bar>[a-z]+)');

done_testing;
