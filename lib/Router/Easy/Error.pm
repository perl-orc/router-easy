package Router::Easy::Error;

use Sub::Exporter -setup => {
  exports => [qw(new_404 new_500)],
};

use Moo;
use Router::Easy::Error::NotFound404;
use Router::Easy::Error::Server500;

has request => (
  is => 'ro',
  required => 1,
);

sub new_404 {
  my ($self, $uri, $req) = @_;
  return Router::Easy::Error::NotFound404->new(uri => $uri, request => $req);
}

sub new_500 {
  my ($self, $message, $req) = @_;
  return Router::Easy::Error::Server500->new(message => $message, request => $req);
}
1
__END__
