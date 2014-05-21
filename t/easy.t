use Test::More;
use Test::Differences;
use Test::Exception;

use strictures;
use Router::Easy;
use Test::Mech;

my $re = Router::Easy->new;
use Data::Dumper 'Dumper';

# Test utility functions

eq_or_diff($re->simple('/foo','GET')->path, '/foo');
eq_or_diff($re->friendly('/foo/:bar','POST')->path, '/foo/:bar');
eq_or_diff($re->regex(qr(/foo/(?<bar>[a-z]+)), 'PUT')->path, qr(/foo/(?<bar>[a-z]+)));

# Test adding
diag("Testing adding");
eq_or_diff($re->routes,[]);

$re->sim('/','GET',1);
eq_or_diff($re->routes->[0]->[0]->path,'/');
eq_or_diff($re->routes->[0]->[0]->method, 'GET');
$re->f('/foo/:bar','POST',{},2);
eq_or_diff($re->routes->[1]->[0]->path,'/foo/:bar');
eq_or_diff($re->routes->[1]->[0]->method, 'POST');
$re->r(qr(/foo/(?<bar>baz)),'POST',3);
eq_or_diff($re->routes->[2]->[0]->path,qr(/foo/(?<bar>baz)));
eq_or_diff($re->routes->[2]->[0]->method, 'POST');
$re->sim('/put','PUT',1);
eq_or_diff($re->routes->[3]->[0]->path,'/put');
eq_or_diff($re->routes->[3]->[0]->method,'PUT');
$re->sim('/delete','DELETE',1);
eq_or_diff($re->routes->[4]->[0]->path,'/delete');
eq_or_diff($re->routes->[4]->[0]->method,'DELETE');

my $s = $re->routes->[0]->[0];
my $f = $re->routes->[1]->[0];
my $r = $re->routes->[2]->[0];
my $s2 = $re->routes->[3]->[0];
my $s3 = $re->routes->[4]->[0];

diag("Clearing routes");
$re->clear();

eq_or_diff($re->routes,[]);
$re->add($s,1);
eq_or_diff($re->routes->[0]->[0]->path,$s->path);
$re->add($f,2);
eq_or_diff($re->routes->[1]->[0]->path,$f->path);
$re->add($r,3);
eq_or_diff($re->routes->[2]->[0]->path,$r->path);
$re->add($s2,4);
eq_or_diff($re->routes->[3]->[0]->path,$s2->path);
$re->add($s3,5);
eq_or_diff($re->routes->[4]->[0]->path,$s3->path);

# Test matching
diag("Testing Matching");
eq_or_diff([$re->match('/','GET')],[1]);
eq_or_diff([$re->match('/','POST')],[]);
eq_or_diff([$re->match('/','PUT')],[]);
eq_or_diff([$re->match('/','DELETE')],[]);
eq_or_diff([$re->match('/foo/bar','GET')],[]);
eq_or_diff([$re->match('/foo/bar','POST')],[2]);
eq_or_diff([$re->match('/foo/bar','PUT')],[]);
eq_or_diff([$re->match('/foo/bar','DELETE')],[]);
eq_or_diff([$re->match('/foo/baz','GET')],[]);
eq_or_diff([$re->match('/foo/baz','POST')],[2,3]);
eq_or_diff([$re->match('/foo/baz','PUT')],[]);
eq_or_diff([$re->match('/foo/baz','DELETE')],[]);
diag("Testing PUT and DELETE");
eq_or_diff([$re->match('/put','GET')],[]);
eq_or_diff([$re->match('/put','POST')],[]);
eq_or_diff([$re->match('/put','PUT')],[4]);
eq_or_diff([$re->match('/put','DELETE')],[]);
eq_or_diff([$re->match('/delete','GET')],[]);
eq_or_diff([$re->match('/delete','POST')],[]);
eq_or_diff([$re->match('/delete','PUT')],[]);
eq_or_diff([$re->match('/delete','DELETE')],[5]);

# Test reversing
TODO: {
  local $TODO = "Reverse routing is not currently supported and is going to be a nightmare for regexes. Will figure out later";
}

# Test clear

$re->clear;
eq_or_diff($re->routes,[]);

# Test to_psgi

$re->sim('/',1);

throws_ok {
  $re->to_psgi;
} qr(All entries in the router must be subrefs for to_psgi to work. The following keys are not: /);

$re->clear;
eq_or_diff($re->routes,[]);

$re->sim('/','GET', sub {"Foo"});
$re->f('/foo/:bar', 'POST', {}, sub {"Bar"});
$re->f('/foo/:bar', 'POST', {bar => qr/[0-9]+/}, sub {"Baz"});
$re->r(qr(/foo/bar/(?<baz>[^/])), 'PUT', sub {"Quux"});

my $psgi = $re->to_psgi;
my $mech = Test::Mech->new(app => $psgi);

# Does it smell like a psgi sub?
eq_or_diff(ref($psgi),'CODE');
# Prod gently, it might be sleeping. Pretend we're professionals.
throws_ok {
  $mech->get('/404-qwertyuiop')
} qr/NotFound404/;
throws_ok {
  $mech->post('/foo/123');
} qr/Server500/;
eq_or_diff($mech->get('/'),"Foo");
eq_or_diff($mech->post('/foo/abc'),"Bar");
eq_or_diff($mech->put('/foo/bar/baz'), "Quux");

done_testing;
