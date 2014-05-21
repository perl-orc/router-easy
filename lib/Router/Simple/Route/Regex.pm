package Router::Simple::Route::Regex;
use Carp 'croak';
use Moo;
has path => (
  is => 'ro',
  required => 1,
);
sub matches {
  my ($self, $url) = @_;
  if ($url =~ $self->path) {
    return {%+};
  }
  return;
}
sub reverse {
  my ($self, @placeholders) = @_;
}
1
__END__
