use Test::More;
use Test::Differences;
use Test::Exception;

use strictures;
use Router::Easy;
use Test::Mech;

my $rs = Router::Easy->new;
use Data::Dumper 'Dumper';

# Test utility functions

eq_or_diff($rs->simple('/foo')->path, '/foo');
eq_or_diff($rs->friendly('/foo/:bar')->path, '/foo/:bar');
eq_or_diff($rs->regex(qr(/foo/(?<bar>[a-z]+)))->path, qr(/foo/(?<bar>[a-z]+)));

# Test adding

eq_or_diff($rs->routes,[]);

$rs->sim('/',1);
eq_or_diff($rs->routes->[0]->[0]->path,'/');
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

eq_or_diff([$rs->match('/')],[1]);
eq_or_diff([$rs->match('/foo/bar')],[2]);
eq_or_diff([$rs->match('/foo/baz')],[2,3]);

# Test reversing
TODO: {
  local $TODO = "Reverse routing is not currently supported and is going to be a nightmare for regexes. Will figure out later";
}

# Test clear

$rs->clear;
eq_or_diff($rs->routes,[]);

# Test to_psgi

$rs->sim('/',1);

throws_ok {
  $rs->to_psgi;
} qr(All entries in the router must be subrefs for to_psgi to work. The following keys are not: /);

$rs->clear;

$rs->sim('/',sub {"Foo"});
$rs->f('/foo/:bar', {}, sub {"Bar"});
$rs->f('/foo/:bar', {bar => qr/[0-9]+/}, sub {"Baz"});
$rs->r(qr(/foo/bar/(?<baz>[^/])), sub {"Quux"});

my $psgi = $rs->to_psgi;
my $mech = Test::Mech->new(app => $psgi);

# Does it smell like a psgi sub?
eq_or_diff(ref($psgi),'CODE');
# Prod gently, it might be sleeping. Pretend we're professionals.
throws_ok {
  $mech->get('/404-qwertyuiop')
} qr/NotFound404/;
throws_ok {
  $mech->get('/foo/123');
} qr/Server500/;
eq_or_diff($mech->get('/'),"Foo");
eq_or_diff($mech->post('/foo/abc'),"Bar");
eq_or_diff($mech->put('/foo/bar/baz'), "Quux");

done_testing;
