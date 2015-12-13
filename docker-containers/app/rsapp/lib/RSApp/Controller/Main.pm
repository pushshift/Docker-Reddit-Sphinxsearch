package RSApp::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';
use strict;
use warnings;
use Data::Dumper;
use DBI;

sub tablestatus {
my $self = shift;
my @connection = ("DBI:mysql:reddit;host=rs-database", "root", "", {
                PrintError => 1,
                AutoCommit => 0,
                mysql_enable_utf8 => 1,
                mysql_write_timeout => 10,
                RaiseError => 1,
                });

my $dbh = DBI->connect(@connection) or die;
my $sphinx = DBI->connect("DBI:mysql:database=rt;host=rs-sphinxsearch;port=9306") or die $!;
my $data;

# Get MySQL Data
my $query = $dbh->prepare(qq|SHOW TABLE STATUS|);
$query->execute();
my $arr_ref = $query->fetchall_arrayref({});
for (@$arr_ref) { 
    for (values %$_) {
        $_=$_+0 if defined $_ && /^[\.\d]+$/;
        }
    } 

$data->{mysql}->{'SHOW TABLE STATUS'} = $arr_ref;
undef $arr_ref;

# MySQL Information_schema
$query = $dbh->prepare(qq|select * from information_schema.columns where table_schema = 'reddit'|);
$query->execute();
$arr_ref = $query->fetchall_arrayref({});
for (@$arr_ref) {
    for (values %$_) {
        $_=$_+0 if defined $_ && /^[\.\d]+$/;
        }
    }
$data->{mysql}->{'SELECT * FROM information_schema.columns'} = $arr_ref;
undef $arr_ref;

# MySQL SHOW VARIABLS
$query = $dbh->prepare(qq|SHOW VARIABLES|);
$query->execute();
$arr_ref = $query->fetchall_arrayref({});
my $hash_ref;
for (@$arr_ref) {
    my $value = $_->{'Value'} =~ /^[\.\d]+$/ ? $_->{'Value'}+0 : $_->{'Value'};
    $hash_ref->{$_->{'Variable_name'}} = $value;
    }
$data->{mysql}->{'SHOW VARIABLES'} = $hash_ref;
undef $arr_ref;
undef $hash_ref;

# Get SphinxSearch Data
$query = $sphinx->prepare(qq|SHOW INDEX rt STATUS|);
$query->execute();
$arr_ref = $query->fetchall_arrayref({});
for (@$arr_ref) {
    my $value = $_->{'Value'} =~ /^[\.\d]+$/ ? $_->{'Value'}+0 : $_->{'Value'};
    $hash_ref->{$_->{'Variable_name'}} = $value;
    }
$data->{sphinxserch}->{'SHOW INDEX rt STATUS'} = $hash_ref;
undef $arr_ref;
undef $hash_ref;

# Get SphinxSearch Status
$query = $sphinx->prepare(qq|SHOW STATUS|);
$query->execute();
$arr_ref = $query->fetchall_arrayref({});
for (@$arr_ref) {
    my $value = $_->{'Value'} =~ /^[\.\d]+$/ ? $_->{'Value'}+0 : $_->{'Value'};
    $hash_ref->{$_->{'Counter'}} = $value;
    }
$data->{sphinxserch}->{'SHOW STATUS'} = $hash_ref;
undef $arr_ref;


$self->render(json => $data);
$dbh->disconnect;
}

1;
