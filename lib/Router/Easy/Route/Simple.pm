package Router::Easy::Route::Simple;
use Moo;
extends 'Router::Easy::Route';
has path => (
  is => 'ro',
  required => 1,
);
sub matches {
  my ($self, $path, $method) = @_;
  if ($self->method) {
	return if ($self->method ne $method);
  }
  return ($path eq $self->path);
}
sub reverse {
  my ($self) = @_;
  return $self->path;
}
1
__END__
