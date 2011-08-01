package UserHandler;

use File::Copy;

my $passwdFile="/etc/passwd";
my $shadowFile="/etc/shadow";
my $groupFile="/etc/group";
my (@passwd,@shadow,@group);
my $err = "";
my $state=0; # 0 for not init 1 for init 2 for future reference;
# loads configurations files into their respected arrays
sub init() {
	if(!open(FILE,"<",$passwdFile))
	{ $err .= "Failed to open file: $!\n";}
	else {
		@passwd = <FILE>;
		close FILE;
	} 
        if(!open(FILE,"<",$shadowFile))
        { $err .= "Failed to open file: $!\n";}
        else {
                @shadow = <FILE>;
                close FILE;
        }
        if(!open(FILE,"<",$groupFile))
        { $err .= "Failed to open file: $!\n";}
        else {
                @group = <FILE>;
                close FILE;
        }
	if($err ne "")
	{ 
		$state = 0;
		return $err;
	}
	$state = 1;
	return 0;	

};
# verifies the gloabl arrays are filled with configuration files content
# or exis
sub initiated()
{
	if($state!=1)
	{ 
		if(init())
		{
			print "An error Occured: $err\n";
			exit(0);
		}	
	}

}
# $1 = username to find
# returns the user string from the passwd file
# No root required
sub FindUser($)
{
	my $username = $_[0];
	initiated();
	foreach my $line (@passwd)
	{
		my @curr = split(/:/, $line);
		if ($curr[0] eq $username)
			{ return $line };
	}
	return 0;
};
# $1 = username
# $2 = password string
sub VerifyPassword($$)
{
	my ($username,$pass) = @_;
	initiated();
	my $userline = FindUser($username);
	my @temp = split(/:/,$userline);
	my $uid = $temp[2];
	my $pwd = (getpwuid(1000))[1];
	my $cryptpwd;
	foreach my $line (@shadow)
	{
		if($line=~/$username/)
		{ 
			@temp = split(/:/, $line);
			$cryptopwd = $temp[1];
			break();
		}
	}
	if($cryptopwd eq  crypt($pass, $pwd))
	{ return 1;}
	return 0;
}
# return a hash for all groups in the system where the hash is keyd to group name
# and contains internal hash with id and memebers
sub GetAllGroups()
{
	initiated();
	my %groupHash;
	foreach my $line (@group)
	{
		chomp($line);
		my @temp = split(/:/, $line);
		$groupHash{$temp[0]}={'id'=>$temp[2], 'members'=>$temp[3]};
	}
	return \%groupHash;
}
# $1 = $groupname for group
# $2 = $groupid for group
# will add new group update the file and reinit the code
sub AddNewGroup($$)
{
	my ($groupname, $groupid) = @_;
	my $groupHash = GetAllGroups();
	foreach my $gname (keys %{$groupHash})
	{
		if($gname eq $groupname)
		{ return "Group name already exist";}
		if($groupHash->{$gname}->{'id'}== $groupid)
		{ return "Group ID already in use by $gname";}

	}
	my $newgroup = "$groupname:x:$groupid:\n";
	push(@group, $newgroup);
	WriteConfFile($groupFile, @group);
	
}
# $1 = $pathtofile 
# $2 = $array to write
# will move and than print out configuration file
# this functions has no write or open verifications for now as i am tired
sub WriteConfFile($$)
{
	my ($path, @arr) = @_;
	if(-e "$path.old")
	{ unlink("$path.old");}
	copy("$path", "$path.old");
	open(FILE, ">$path");
	print FILE @arr;
	close FILE;
}
1;

