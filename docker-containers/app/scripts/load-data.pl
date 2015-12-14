#!/usr/bin/env perl

use strict;
use warnings;
use Cpanel::JSON::XS;
use Term::ANSIColor qw(:constants);
use Time::Piece;
use Data::Dumper;
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
my $c_utc;

while (<STDIN>) {
	chomp $_;
        $count++;
	my $json = decode_json($_);
	my $id = strtol($json->{id},36);
	$c_utc = $json->{created_utc};
	$json->{original} = $_;
	$comments{$id} = $json;
	unless ($count % 5000) { 
		processBatch(\%comments);
	} 
}

processBatch(\%comments);

sub processBatch {
	my $comments = shift;
	removeCommentsAlreadyIndexed($comments);
	processRemainingComments($comments);
	print "Processed ", commify($count), " [", localtime($c_utc)->strftime('%F %T'), "]\r";
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

# To avoid the MySQL Auto-increment bug on insert ignore, we have to check records ourselves (This can probably be optimized) 
	my %authors_from_batch = map { $comments->{$_}->{author} => 1 } keys %$comments;
	my %authors_to_insert = %authors_from_batch;
	my $query = qq|SELECT name FROM author WHERE name IN ('| . join("','", map { $_ } keys %authors_from_batch) .  qq|')|;
	my $sth = $dbh->prepare($query);
	$sth->execute;
	my @authors_in_db = map @$_, @{$sth->fetchall_arrayref()};
	delete @authors_to_insert{@authors_in_db};
	bulkInsert($dbh,[map {[$_]} keys %authors_to_insert], "INSERT IGNORE INTO author (name) VALUES ") if keys %authors_to_insert;
	$dbh->commit;
	$sth = $dbh->prepare(qq|SELECT author_id, name FROM author WHERE name IN ('| . join("','", map { $_ } keys %authors_from_batch) .  qq|')|);
	$sth->execute;
	my $author = $sth->fetchall_hashref('name');
# ----------------------------------------------
	my ($seconds,$minutes,$hours,$days);
	my %indexes;

	for (keys %$comments) {
		my $json = $comments->{$_};
		my $json_encoded = $json->{original};;
		my $id = strtol($json->{id},36);  
		my $subreddit = $json->{subreddit};
		my $subreddit_id = strtol(substr($json->{subreddit_id},3),36);
		my $link_id = strtol(substr($json->{link_id},3),36);
		my $created_utc = $json->{created_utc};
		my $score = $json->{score};
		my $body = $json->{body};
		my $author_id = $author->{$json->{author}}->{author_id};
		unless ($subreddit{$subreddit}) {
			$insert_subreddit->execute($subreddit_id,$subreddit);
			$subreddit{$subreddit} = $subreddit_id;
		}
		$indexes{time_second}{$created_utc}++;
		$indexes{time_minute}{floor($created_utc/60)*60}++;
		$indexes{time_hour}{floor($created_utc/3600)*3600}++;
		$indexes{time_day}{floor($created_utc/86400)*86400}++;
		$indexes{time_link_hour}{$link_id}{floor($created_utc/3600)*3600}++;
		$indexes{time_link_minute}{$link_id}{floor($created_utc/60)*60}++;
		$indexes{time_link_second}{$link_id}{$created_utc}++;
		$indexes{time_subreddit_second}{$subreddit_id}{$created_utc}++;
		$indexes{time_subreddit_minute}{$subreddit_id}{floor($created_utc/60)*60}++;
		$indexes{time_subreddit_hour}{$subreddit_id}{floor($created_utc/3600)*3600}++;
		$indexes{time_subreddit_day}{$subreddit_id}{floor($created_utc/86400)*86400}++;
		push(@sphinx, [$id,$body,$created_utc,$subreddit_id,$link_id,$score]);
		push(@com_index, [$id,$created_utc,$subreddit_id,$link_id,$author_id,$score]);
		push(@com_json, [$id,$json_encoded]);
	}

	bulkInsert($dbh,\@com_index, "INSERT IGNORE INTO com_index VALUES ") if @com_index;
	bulkInsert($dbh,\@com_json, "INSERT IGNORE INTO com_json VALUES ") if @com_json;
	bulkInsert($sphinx,\@sphinx, "REPLACE INTO rt (id,body,date,subreddit_id,submission_id,score) VALUES ") if @sphinx;


	for (qw|time_second time_minute time_hour time_day|) {
		if ($indexes{$_}) {
			my @array;
			for my $s (keys %{$indexes{$_}}) {
				push(@array,[$s,$indexes{$_}{$s}]);
			}
			bulkInsert($dbh, \@array,"INSERT INTO $_ (created_utc,comment_count) VALUES ", "ON DUPLICATE KEY UPDATE comment_count=comment_count+VALUES(comment_count)");
		}
	}

	for (qw|time_link_second time_link_minute time_link_hour|) {
		my @array;
		if ($indexes{$_}) {
			for my $s (keys %{$indexes{$_}}) {
				for my $t (keys %{$indexes{$_}{$s}}) {
					push(@array,[$t,$s,$indexes{$_}{$s}{$t}]);
				}
			}
			bulkInsert($dbh, \@array,"INSERT INTO $_ (created_utc,link_id,count) VALUES ", "ON DUPLICATE KEY UPDATE count=count+VALUES(count)");
		}
	}

	for (qw|time_subreddit_second time_subreddit_minute time_subreddit_hour time_subreddit_day|) {
		my @array;
		if ($indexes{$_}) {
			for my $s (keys %{$indexes{$_}}) {
				for my $t (keys %{$indexes{$_}{$s}}) {
					push(@array,[$t,$s,$indexes{$_}{$s}{$t}]);
				}
			}
			bulkInsert($dbh, \@array,"INSERT INTO $_ (created_utc,subreddit_id,count) VALUES ", "ON DUPLICATE KEY UPDATE count=count+VALUES(count)");
		}
	}


	$dbh->commit;
	undef %$comments;
}

sub bulkInsert {
	my $db_handle = shift;
	my $records = shift;
	my $query = shift;
	my $end_query = shift || "";
	my $start = 0;
	for (@$records) {
		$query .= ',' if $start++;
		$query .= '('
			. (join (",", map { $db_handle->quote($_)} @$_))
			.')';
	}
	my $affected = $db_handle->do("$query $end_query") or die;
	undef @$records;
}

sub commify {
	my ( $sign, $int, $frac ) = ( $_[0] =~ /^([+-]?)(\d*)(.*)/ );
	my $commified = (
			scalar reverse join ',',
			unpack '(A3)*',
			scalar reverse $int
			);
	return $sign . $commified . $frac;
}
