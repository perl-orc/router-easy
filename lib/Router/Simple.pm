package Router::Simple;

# ABSTRACT: A simple routing system for plumbing frameworky things

use Router::Simple::Route::Simple;
use Router::Simple::Route::Friendly;
use Router::Simple::Route::Regex;

use Moo;

has routes => (
  is => 'rw',
  init_arg => undef,
  default => sub {[]},
);

sub simple {
  my ($self, $url) = @_;
  return Router::Simple::Route::Simple->new(path => $url);
}

sub friendly {
  my ($self, $url, $rules) = @_;
  $rules ||= {};
  return Router::Simple::Route::Friendly->new(path =>$url, rules => $rules);
}

sub regex {
  my ($self, $url) = @_;
  return Router::Simple::Route::Regex->new(path => $url);
}
{
  no strict 'refs';
  # This is a hack to preserve cperl-mode highlighting, which thinks i'm doing s///
  *{__PACKAGE__.'::s'} = sub {
	my ($self, $url, $return) = @_;
	my $s = $self->simple($url);
	$self->add($s, $return);
  };
}

sub f {
  my ($self, $url, $rules, $return) = @_;
  my $f = $self->friendly($url,$rules);
  $self->add($f,$return);
}

sub r {
  my ($self, $url, $return) = @_;
  my $r = $self->regex($url);
  $self->add($r, $return);
}

sub add {
  my ($self, $route, $return) = @_;
  my @routes = @{$self->routes};
  push @routes, [$route,$return];
  $self->routes([@routes]);
  $self;
}
sub match {
  my ($self, $url) = @_;
  my @ret;
  grep {
    $_ = $_->matches($url);
  } @{$self->routes}
}

sub clear {
  my ($self) = @_;
  $self->routes([]);
}
sub to_app {
  sub {}
}

1
__END__

=head1 SYNOPSIS

    use Router::Simple;
    my $rs = Router::Simple->new;
    # Simple routes just match a string
    $rs->s('/',sub {"Hello World"});
    $rs->s('/blog', sub {"Listing of blogs"});
    # Friendly routes are rails inspired and take regexes. Name tokens are `:[a-z]+`
    $rs->f('/blog/:blog', {blog => '[a-z]+'}, sub {"A blog"});
    # Regex routes allow ultimate flexibility
    $rs->r('/blog/(?<blog>[a-z]+)/tag/(?<tag>[a-z]+)', sub {"A tag:"});
    # We get a psgi app out the end suitable for using with Placky things
    $rs->to_app;

=head1 METHODS

=head2 new() => Router::Simple

=head2 s($path: Str, $return: Any) => Router

Creates a new simple route out of $path and adds it to the router to return $return

=head2 f($path: Str, $rules: HashRef[Str|Regex], $return: Any) => Router

Creates a new friendly route out of $path and $rules and adds it to the router to return $return

=head2 r($path: Str|Regex, $return: Any

Creates a new regex route out of $path and adds it to the router to return $return

=head2 simple($path: Str) => RouteSimple

Takes a simple string constant for the url, returns a RouteSimple

=head2 friendly($path: String, $rules: Maybe[Hashref[String]]) => RouteFriendly

Takes a rails-inspired route path, eg. /blog/:blog and a hashref of rules, returns a RouteFriendly.

The colon, : is used to mark the name of a capture. it can be followed with any name of your choosing of at least one character. Names must be completely lowercase, a-z. The capture will match any string of characters not containing a '/' (i.e. it will do the tirhg thing).

Each capture can optionally have a regex associated with it in the rules hashref. The capture will match this regex, which you should store as a string or a regex. If you use a string, you will need to backslash escape certain things, like forward slashes. You can use a regex with the C<qr(foo)> syntax and that will work as well

Examples:
    $rs->friendly('/tag/:tag', {tag => qr/[a-z]+/});
    $rs->friendly('/blog/:blog/:tag/:tag', {blog => qr/[a-z0-9_]+/});

=head2 regex($path: String) => RouteRegex

Creates a regex route and returns it. You can get named captures using the standard perl named capture syntax: C<(?<name>match)>. There are gotchas using named captchas if you're doing silly things with lots of alternation because names are actually bound to numbers so if orders change... Anyway, you shouldn't come across this doing URLs, and in any case, if you do, I hope you know what you're doing. It's a mad world out there...

=head2 add($route: Route, $return: Any) => Router

Adds a route to the router. The return value is what will be returned when the route matches. If you're going to use to_psgi(), you want a SubRef in here to invoke code. It should behave like a standard PSGI sub.

=head2 clear => Router

Removes all routes

=head2 match($url) => Any

Matches the url in sequence against the routes, returns a list of results that matched

=head2 to_psgi() => SubRef

Assumes that all routes resolve to subrefs and creates a PSGI application on that basis.

=head1 NOTES

This might annoy you, but we don't care if urls end in a slash in the 'friendly' pattern. We explicitly add '/?' to the end. You can force a slash by adding another (which requires escaping, so use a backslash), but you can't do it the other way around.

=head1 COPYRIGHT

Copyright 2014 James Edward Daniel

=head1 LICENSE

Perl Artistic License.
