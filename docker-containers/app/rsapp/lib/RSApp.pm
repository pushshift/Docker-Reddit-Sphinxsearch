package RSApp;
use Mojo::Base 'Mojolicious';
use Mojo::mysql;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Misc Helpers

  $self->helper(toHashRef => sub {
      my ($self,$array,$key) = @_;
      my $hashref = { map { $_->{$key} => $_ } @$array };
      return $hashref;
 });

  $self->helper(strToNum => sub {
      my ($self, $array) = @_;
      for my $object (@$array) {
          for (keys %$object) {
	  $object->{$_} = looks_like_number($object->{$_}) ? $object->{$_} + 0 : $object->{$_};
          }
      }
      return $array;
 });

  # Database Connection
  $self->helper(db => sub { state $pg = Mojo::mysql->new('mysql://root@rs-database/reddit') });
  $self->helper(sphinx => sub { state $sphinx = Mojo::mysql->new('mysql://root@rs-sphinxsearch:9306/rt') });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  #$r->get('/reddit/:action')->to('reddit#');
  #$r->get('/reddit/search/')->to('reddit#search');
  $r->get('/reddit/search/comments')->to(controller => 'reddit', action => 'searchComments');
  $r->get('/reddit/search/author')->to(controller => 'reddit', action => 'searchAuthor');
  $r->get('/reddit/search/')->to(controller => 'reddit', action => 'search', type => undef);
  $r->get('/reddit/activity')->to('redditactivity#activity');
  $r->get('/reddit/activity/:time')->to('redditactivity#activity');
  $r->get('/status/tables')->to('main#tablestatus');
  $r->get('/(*everything)')->to('main#catchall');
}

1;
