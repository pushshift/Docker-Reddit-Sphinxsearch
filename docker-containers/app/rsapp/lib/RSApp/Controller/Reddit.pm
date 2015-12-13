package RSApp::Controller::Reddit;
use Mojo::Base 'Mojolicious::Controller';
use strict;
use warnings;
use Data::Dumper;
use Math::BaseCnv;
use Text::Markdown 'markdown';
use HTML::Entities;
use Cpanel::JSON::XS;
use Time::HiRes 'time';
use DBI;

# This action will render a template

sub search {
my $self = shift;
my @connection = ("DBI:mysql:reddit;host=rs-database", "root", "", {
                PrintError => 1,
                AutoCommit => 1,
                mysql_enable_utf8 => 1,
                mysql_write_timeout => 10,
                RaiseError => 1,
                });

my $sphinx = DBI->connect("DBI:mysql:database=rt;host=rs-sphinxsearch;port=9306") or die $!;
my $dbh = DBI->connect(@connection) or die;
my $data;
$data->{data} = undef;
my $limit = $self->param('limit') ? int $self->param('limit') : 25;
if ($limit > 100) {$limit = 100}
my $query = $sphinx->prepare(qq|
SELECT id, count(*) c, submission_id, subreddit_id, score FROM rt 
WHERE match(?) GROUP BY submission_id
WITHIN GROUP ORDER BY score DESC
ORDER BY c DESC
LIMIT ?
|);
my $time = time;
$query->execute($self->param('q'),$limit);
$data->{debug}->{sphinxtime} = time - $time;
my $arr_ref = $query->fetchall_arrayref({});

# Get SphinxSearch Data
$query = $sphinx->prepare(qq|SHOW META|);
$query->execute();
my $arr_ref2 = $query->fetchall_arrayref({});
my $hash_ref;
for (@$arr_ref2) {
    my $value = $_->{'Value'} =~ /^[\.\d]+$/ ? $_->{'Value'}+0 : $_->{'Value'};
    $hash_ref->{$_->{'Variable_name'}} = $value;
    }
$data->{debug}->{'meta'} = $hash_ref;
undef $arr_ref2;
undef $hash_ref;

$time = time;
my $comments = ::getComments($dbh,[map {$_->{id}} @$arr_ref]);
$data->{debug}->{dbtime} = time - $time;
$time = time;
for (@$arr_ref) {
    next unless $comments->{$_->{id}}->{json};
    my $json = decode_json($comments->{$_->{id}}->{json});
    $json->{created_utc} = $json->{created_utc} + 0;   # force string to int for JSON
    my $subreddit = $json->{subreddit};
    delete $json->{subreddit};
    my $submission_id = lc(cnv($_->{submission_id},10,36));
    my $subreddit_id = lc(cnv($_->{subreddit_id},10,36));
    my $comment_id = lc(cnv($_->{id},10,36));
    my $score = $_->{score}+0;
    my $count = $_->{c}+0;
    my $body = $json->{body};
    my $html = "";#markdown(decode_entities($body));
    push(@{$data->{data}},{"top_comment" => $json , "subreddit" => $subreddit, "subreddit_id" => "t5_$subreddit_id", "link_id" => "t3_$submission_id", "count" => $count});
    }
$data->{debug}->{processing} = time - $time;
$self->render(json => $data);
$dbh->disconnect;
}


1;
