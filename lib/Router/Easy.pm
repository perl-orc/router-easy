package Router::Easy;

# ABSTRACT: A simple routing system for plumbing frameworky things

use Router::Easy::Route::Simple;
use Router::Easy::Route::Friendly;
use Router::Easy::Route::Regex;
use Router::Easy::Error qw(new_404 new_500);

use v5.16.0;

use Moo;
use Carp qw(carp cluck confess croak);
use Scalar::Util 'blessed';

has routes => (
  is => 'rw',
  init_arg => undef,
  default => sub {[]},
);

sub simple {
  my ($self, $url, $method) = @_;
  return Router::Easy::Route::Simple->new(path => $url, method => $method);
}

sub friendly {
  my ($self, $url, $method, $rules) = @_;
  $rules ||= {};
  return Router::Easy::Route::Friendly->new(path =>$url, rules => $rules, method => $method);
}

sub regex {
  my ($self, $url, $method) = @_;
  return Router::Easy::Route::Regex->new(path => $url, method => $method);
}
sub sim {
  my ($self, $url, $method, $return) = @_;
  my $s = $self->simple($url, $method);
  $self->add($s, $return);
}

sub f {
  my ($self, $url, $method, $rules, $return) = @_;
  my $f = $self->friendly($url, $method, $rules);
  $self->add($f,$return);
}

sub r {
  my ($self, $url, $method, $return) = @_;
  my $r = $self->regex($url, $method);
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
  my ($self, $url, $method) = @_;
  my @ret;
  map $_->[1], grep !!$_->[0]->matches($url,$method), @{$self->routes};
}

sub clear {
  my ($self) = @_;
  $self->routes([]);
}

sub to_psgi {
  my ($self) = @_;
  # Hunt out any members that aren't coderefs.
  # The contract is that requests will be handled by calling the return
  # and we can't call something that isn't a subref...
  my @invalid = grep {
	ref($_->[1]) ne 'CODE';
  } @{$self->routes};
  confess(
    "All entries in the router must be subrefs for to_psgi to work. " .
    "The following keys are not: " .
	join(",", map {$_->[0]->path} @invalid)
  ) if @invalid;
  # This is the subref that we'll be returning
  sub {
    my $env = shift;
	# Get the matching routes
    my @matches = $self->match($env->{'REQUEST_URI'},$env->{'REQUEST_METHOD'});
	# Huzzah!
	return $matches[0]->($env) if 1 == @matches;
	# More than one route matched
	die(new_500("Multiple matches", $env)) if @matches;
	# No routes matched
    die(new_404($env->{'REQUEST_URI'}, $env));
  }
}

1
__END__

=head1 SYNOPSIS

    use Router::Easy;
    my $rs = Router::Easy->new;
    # Simple routes just match a string
    $rs->sim('/',sub {"Hello World"});
    $rs->sim('/blog', sub {"Listing of blogs"});
    # Friendly routes are rails inspired and take regexes. Name tokens are `:[a-z]+`
    $rs->f('/blog/:blog', {blog => '[a-z]+'}, sub {"A blog"});
    # Regex routes allow ultimate flexibility
    $rs->r('/blog/(?<blog>[a-z]+)/tag/(?<tag>[a-z]+)', sub {"A tag:"});
    # We get a psgi app out the end suitable for using with Placky things
    $rs->to_app;

=head1 METHODS

=head2 new() => Router::Easy

=head2 sim($path: Str, $return: Any) => Router

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
