package Router::Easy::Route::Simple;
use Moo;
has path => (
  is => 'ro',
  required => 1,
);
sub matches {
  my ($self, $path) = @_;
  $path eq $self->path;
}
sub reverse {
  my ($self) = @_;
	return $self->path;
}
1
__END__
