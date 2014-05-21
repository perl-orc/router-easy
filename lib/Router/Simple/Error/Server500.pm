package Router::Simple::Error::Server500;

use Moo;
extends 'Router::Simple::Error';

has message => (
  is => 'ro',
  required => 1,
);
1
__END__
