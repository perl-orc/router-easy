package Router::Easy::Route;

use Moo;

has path => (
  is => 'ro',
  isa => sub{die("Not a string: $_") unless !ref($_);},
  required => 1,
);

has method => (
  is => 'ro',
  isa => sub{die("Not a string: $_") unless !ref($_);},
  default => sub { undef },
);

1
__END__
