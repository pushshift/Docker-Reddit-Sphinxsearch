#!/usr/bin/env perl

use strict;
use warnings;
use Cpanel::JSON::XS;
use List::MoreUtils qw /uniq/;
use DBI;
use POSIX;
$|=1;
my @connection = ("DBI:mysql:reddit;host=rs-database", "root", "", {
                PrintError => 1,
                AutoCommit => 0,
                mysql_enable_utf8 => 1,
                mysql_write_timeout => 10,
                RaiseError => 1,
                });

my $sphinx = DBI->connect("DBI:mysql:database=rt;host=rs-sphinxsearch;port=9306") or die $!;
my $dbh = DBI->connect(@connection) or die;
my $insert_json = $dbh->prepare('INSERT IGNORE INTO com_json VALUES (?,?)') or die "Couldn't prepare statement: " . $dbh->errstr;
my $insert_subreddit = $dbh->prepare('INSERT IGNORE INTO subreddit VALUES (?,?)') or die "Couldn't prepare statement: " . $dbh->errstr;
my $insert_comindex = $dbh->prepare('INSERT IGNORE INTO `com_index` VALUES (?,?,?,?,?)') or die "Couldn't prepare statement: " . $dbh->errstr;

my $count = 0;
my %subreddit;
my %comments;

while (<STDIN>) {
chomp $_;
my $json = decode_json($_);
my $id = strtol($json->{id},36);
$comments{$id} = $json;
unless (++$count % 1000) { 
    removeCommentsAlreadyIndexed(\%comments);
    processRemainingComments(\%comments);
    } 
}

sub removeCommentsAlreadyIndexed {
my $comments = shift;
if (keys %$comments) {
    my $check = $dbh->prepare("SELECT comment_id FROM com_json WHERE comment_id IN (" . join(",",keys %$comments) .  ")");
    $check->execute;
    my @data = map @$_, @{$check->fetchall_arrayref()};
    delete @comments{@data};
    }
}

sub processRemainingComments {
my $comments = shift;
my (@sphinx,@com_index,@com_json);

my @authors =  uniq(map { $comments->{$_}->{author} } keys %$comments);
print scalar @authors;
die;

for (keys %$comments) {
    my $json = $comments->{$_};
    my $id = $json->{id}; 
    my $subreddit = $json->{subreddit};
    my $subreddit_id = strtol(substr($json->{subreddit_id},3),36);
    my $link_id = strtol(substr($json->{link_id},3),36);
    my $created_utc = $json->{created_utc};
    my $score = $json->{score};
    my $body = $json->{body};
    unless ($subreddit{$subreddit}) {
        $insert_subreddit->execute($subreddit_id,$subreddit);
        $subreddit{$subreddit} = $subreddit_id;
        }
    push(@sphinx, [$id,$body,$created_utc,$subreddit_id,$link_id,$score]);
    push(@com_index, [$id,$created_utc,$subreddit_id,$link_id,$score]);
    push(@com_json, [$id,$_]);
}

print ".";
bulkInsert($dbh,\@com_index, "INSERT IGNORE INTO com_index VALUES ");
bulkInsert($dbh,\@com_json, "INSERT IGNORE INTO com_json VALUES ");
bulkInsert($sphinx,\@sphinx, "REPLACE INTO rt (id,body,date,subreddit_id,submission_id,score) VALUES ");
$dbh->commit;
}

sub bulkInsert {
my $db_handle = shift;
my $records = shift;
my $query = shift;
my $start = 0;
for (@$records) {
    $query .= ',' if $start++;
    $query .= '('
       . (join (",", map { $db_handle->quote($_)} @$_))
       .')';
}
my $affected = $db_handle->do($query) or die;
undef @$records;
}

