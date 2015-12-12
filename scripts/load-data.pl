#!/usr/bin/env perl

use strict;
use warnings;
use Cpanel::JSON::XS;
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
my @sphinx;

while (<STDIN>) {
chomp $_;
my $json = decode_json($_);
my $id = strtol($json->{id},36);
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
$insert_json->execute($id,$_);
$insert_comindex->execute($id,$created_utc,$subreddit_id,$link_id,$score);
unless (++$count % 1000) {
    print ".";
    BulkInsertSphinx(\@sphinx, "REPLACE INTO rt (id,body,date,subreddit_id,submission_id,score) VALUES ");
    $dbh->commit;
    undef @sphinx;
    }
}

BulkInsertSphinx(\@sphinx, "REPLACE INTO rt (id,body,date,subreddit_id,submission_id,score) VALUES ") if @sphinx;
$dbh->commit;

sub BulkInsertSphinx {
my $records = shift;
my $query = shift;
my $start = 0;
for (@$records) {
    $query .= ',' if $start++;
    $query .= '('
       . (join (",", map { $sphinx->quote($_)} @$_))
       .')';
}
my $affected = $sphinx->do($query) or die;
undef @$records;
}

