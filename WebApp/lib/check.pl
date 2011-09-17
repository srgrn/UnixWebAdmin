use Data::Dumper;
use feature 'say';
require ProcessHandler;
require UserHandler;
require FileHandler;
require SystemHandler;

sub checkProcessList(){
	my $list = &ProcessHandler::proclist();
	foreach my $pid (keys %$list)
	{
	print $pid,"\t", $list->{ $pid },"\n";
	}
};
sub checkFindUser()
{
	print "Checking FindUser\n";
	my $username = $ENV{USER} || $ENV{USERNAME};
	my $exist = &UserHandler::FindUser($username);
	if($exist) 
	{ print "User $username exist in passwd\n"; }
	$username = "cats";
	$exist = &UserHandler::FindUser($username);
	if($exist)
	{ print "User $username exist in passwd\n";}

};
sub checkUserPass()
{
	print "Checking VerifyPassword\n";
	my $username = "zimbler";
	my $password = "Echo Team";
	my $password2 = "black123";
	if (&UserHandler::VerifyPassword($username,$password2))
		{
			print "Error has occured\n";
		}
	if(&UserHandler::VerifyPassword($username,$password))
		{
			print "correct password given $password\n";
		}
	else
	{
		print "Correct password incorrect $password\n";
	}
};

sub checkGetGroups()
{
	my $hash = &UserHandler::GetAllGroups();
	print $hash, "\n";
	print Dumper($hash),"\n";
}
sub checkAddRemoveNewGroup()
{
	my ($val, $m) = &UserHandler::AddNewGroup("TestGroup1", 1500);
	print $m, "\n";
	($val, $m) = &UserHandler::AddNewGroup("TestGroup2", 1500);
	print $m, "\n";
	&UserHandler::RemoveGroup(1500);
	my ($ret, $msg) = &UserHandler::RemoveGroup(1600);
	if(!$ret)
	{ print $msg, "\n"; }

}

sub main()
{
#	my $ref = &FileHandler::ShowDir("/proc");
#	say Dumper($ref);
	my $path = "check/movedBrag";
	my @ret = &FileHandler::grepFiles($path, '\w+\d+', '\w+');
	print @ret, "\n";
	#my $newpath ="check/movedBrag";
	#&FileHandler::MovePath($path, $newpath);	
}


main();
