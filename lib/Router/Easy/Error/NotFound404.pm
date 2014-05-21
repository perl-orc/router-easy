package Router::Easy::Error::NotFound404;

use Moo;
extends 'Router::Easy::Error';

has uri => (
  is => 'ro',
  required => 1,
);
1
__END__
