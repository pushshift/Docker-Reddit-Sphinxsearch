package RSApp::Controller::Redditactivity;
use Mojo::Base 'Mojolicious::Controller';
use strict;
use warnings;
use Data::Dumper;
use Math::BaseCnv;
use Time::HiRes 'time';
use DBI;

# This action will render a template

sub activity {
my $self = shift;
my $table = $self->stash('time') ? lc($self->stash('time')) : "second";
my @connection = ("DBI:mysql:reddit;host=rs-database", "root", "", {
                PrintError => 1,
                AutoCommit => 1,
                mysql_enable_utf8 => 1,
                mysql_write_timeout => 10,
                RaiseError => 1,
                });

my $dbh = DBI->connect(@connection) or die;
my $data;
$data->{data} = undef;
# Get MySQL Data
my $query = $dbh->prepare(qq|SELECT * FROM time_$table ORDER BY created_utc DESC LIMIT 100|);
$query->execute();
my $arr_ref = $query->fetchall_arrayref({});
for (@$arr_ref) {
    for (values %$_) {
        $_=$_+0 if defined $_ && /^[\.\d]+$/;
        }
    }
$data->{data} = $arr_ref;
$self->render(json => $data);
$dbh->disconnect;
}


1;
