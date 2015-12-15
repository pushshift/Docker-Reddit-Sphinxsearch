package RSApp;
use Mojo::Base 'Mojolicious';
use Mojo::mysql;
#use Mojolicious::Plugin::Database;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Database Connection

  $self->helper(db => sub { state $pg = Mojo::mysql->new('mysql://root@rs-database/reddit') });
  $self->helper(sphinx => sub { state $sphinx = Mojo::mysql->new('mysql://root@rs-sphinxsearch:9306/rt') });
#  $self->plugin('database', {
#            databases => {
#                'db' => {
#                 dsn      => 'dbi:mysql:dbname=reddit;host=rs-database',
#                 username => 'root',
#                 password => '',
#                 options  => { AutoCommit => 1 },
#                 },
#                'sphinx' => {
#                    dsn      => 'dbi:mysql:database=rt;host=rs-sphinxsearch;port=9306',
#                },
#            },
#        });

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
