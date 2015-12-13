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
#$query->execute('Einstein');

my $arr_ref = $query->fetchall_arrayref({});
$time = time;
my $comments = ::getComments($dbh,[map {$_->{id}} @$arr_ref]);
$data->{debug}->{dbtime} = time - $time;
$time = time;
for (@$arr_ref) {
    my $json = decode_json($comments->{$_->{id}}->{json});
    my $submission_id = lc(cnv($_->{submission_id},10,36));
    my $subreddit_id = lc(cnv($_->{subreddit_id},10,36));
    my $comment_id = lc(cnv($_->{id},10,36));
    my $score = $_->{score}+0;
    my $count = $_->{c}+0;
    my $body = $json->{body};
    my $html = "";#markdown(decode_entities($body));
    push(@{$data->{data}},{"subreddit_id" => "t5_$subreddit_id", "link_id" => "t3_$submission_id", "count" => $count,"top_comment_body" => $body,"top_comment_score" => $score,"top_comment_id" => "t1_$comment_id"});
    }
$data->{debug}->{processing} = time - $time;
  $self->render(json => $data);
  $dbh->disconnect;
}


1;
