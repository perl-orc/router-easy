package Router::Easy::Error::Server500;

use Moo;
extends 'Router::Easy::Error';

has message => (
  is => 'ro',
  required => 1,
);
1
__END__
