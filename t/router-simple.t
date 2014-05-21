use Test::More;
use Test::Differences;
use strictures;
use Router::Simple;

my $rs = Router::Simple->new;
use Data::Dumper 'Dumper';

# Test utility functions

eq_or_diff($rs->simple('/foo')->path, '/foo');
eq_or_diff($rs->friendly('/foo/:bar')->path, '/foo/:bar');
eq_or_diff($rs->regex(qr(/foo/(?<bar>[a-z]+)))->path, qr(/foo/(?<bar>[a-z]+)));

# Test adding

eq_or_diff($rs->routes,[]);

$rs->s(qr(/),1);
eq_or_diff($rs->routes->[0]->[0]->path,qr(/));
$rs->f('/foo/:bar',{},2);
eq_or_diff($rs->routes->[1]->[0]->path,'/foo/:bar');
$rs->r(qr(/foo/(?<bar>baz)),3);
eq_or_diff($rs->routes->[2]->[0]->path,qr(/foo/(?<bar>baz)));

my $s = $rs->routes->[0]->[0];
my $f = $rs->routes->[1]->[0];
my $r = $rs->routes->[2]->[0];

$rs->clear();

eq_or_diff($rs->routes,[]);
$rs->add($s,1);
eq_or_diff($rs->routes->[0]->[0]->path,$s->path);
$rs->add($f,2);
eq_or_diff($rs->routes->[1]->[0]->path,$f->path);
$rs->add($r,3);
eq_or_diff($rs->routes->[2]->[0]->path,$r->path);

# Test matching
TODO: {
  local $TODO = "Matching tests coming next";
}

# Test reversing
TODO: {
  local $TODO = "Reverse routing is not currently supported and is going to be a nightmare for regexes. Will figure out later";
}

# to_psgi

done_testing;
