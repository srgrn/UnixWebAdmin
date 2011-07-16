require ProcessHandler;
my $list = &ProcessHandler::proclist();
foreach my $pid (keys %$list)
{
	print $pid,"\t", $list->{ $pid },"\n";
}
