package Router::Easy::Route::Friendly;
use Moo;
extends 'Router::Easy::Route';
use Carp 'confess';
has rules => (
  is => 'ro',
  required => 1,
);
has re => (
  is => 'rw',
  default => sub {undef},
);
sub matches {
  my ($self, $url, $method) = @_;
  if ($url =~ $self->re) {
	if ($self->method) {
	  if ($self->method ne $method) {
		return;
	  }
	}
	return {%+};
  }
  return;
}
sub reverse {
  my ($self, @matches) = @_;
}
sub _decompose {
  my ($self, $url, $rules) = @_;
  my $working = $url;
  my @vars;
  my @pieces;
  while ($working) {
	if ($working =~ s/^:([a-z]+)//) {
	  no autovivification;
	  # We need to be able to identify it by name for reverse
	  push @vars, $1;
	  my $re = '(?<' . $1 . '>' . ($rules->{$1} || '[^\/]+') . ')';
	  push @pieces, $re;
	} else {
	  # We've got an invalid variable
	  confess("Couldn't figure out what to do with $working") if ($working =~ m/^:/);
	  push @pieces, quotemeta($1) if $working =~ s/^([^:]+)//;
	}
	my $re = '^' . (join '', @pieces) . '\/?$';
	$re = qr/$re/;
	$self->re($re);
  }
}

sub BUILD {
  my $self = shift;
  $self->_decompose($self->path, $self->rules);
}

1
__END__
