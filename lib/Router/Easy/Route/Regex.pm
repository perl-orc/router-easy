package Router::Easy::Route::Regex;
use Carp 'croak';
use Moo;
extends 'Router::Easy::Route';
has path => (
  is => 'ro',
  required => 1,
);
sub matches {
  my ($self, $url, $method) = @_;
  if ($url =~ $self->path) {
	if ($self->method) {
	  return unless($self->method eq $method);
	}
	return {%+};
  }
  return;
}
sub reverse {
  my ($self, @placeholders) = @_;
}
1
__END__
