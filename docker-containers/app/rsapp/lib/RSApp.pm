package RSApp;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  #$r->get('/reddit/:action')->to('reddit#');
  $r->get('/reddit/search')->to('reddit#search');
  $r->get('/reddit/activity')->to('redditactivity#activity');
  $r->get('/reddit/activity/:time')->to('redditactivity#activity');
  $r->get('/status/tables')->to('main#tablestatus');
  $r->get('/(*everything)')->to('main#catchall');
}

1;
