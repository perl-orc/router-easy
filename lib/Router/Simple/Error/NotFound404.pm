package Router::Simple::Error::NotFound404;

use Moo;
extends 'Router::Simple::Error';

has uri => (
  is => 'ro',
  required => 1,
);
1
__END__
