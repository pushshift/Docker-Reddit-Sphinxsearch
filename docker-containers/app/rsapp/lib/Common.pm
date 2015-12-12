sub getComments {
my $dbh = shift;
my $comment_ids = shift;
my @comments;
return unless scalar @$comment_ids > 0;
my $query = "SELECT comment_id, json from com_json WHERE comment_id IN (" . join(",",@$comment_ids) . ")";
my $select = $dbh->prepare($query);
$select->execute();
return $select->fetchall_hashref('comment_id');
}

1;
