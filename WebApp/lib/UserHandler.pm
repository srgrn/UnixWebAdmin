package UserHandler;

use Modern::Perl;
use File::Copy;
our $_caller = "Web";
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
			if ($_caller eq "Shell")
			{ exit(0); }
			return(0);
		}	
	}
	return 1;

};
# $1 = username to find
# returns the user string from the passwd file or 0 if there is no such user
# No root required
# Apperantly this entire function can be replaced with getpwnam(name))
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
sub userDetails($)
{
	my %details;
	$details{"username"}= $_[0];
	my $userline = FindUser($details{"username"});
	if($userline)
	{
		my @temp = split(/:/, $userline);
		$details{"UID"}=$temp[2];
		$details{"GID"}=$temp[3];
		$details{"homedir"}=$temp[5];
		$details{"shell"}=$temp[6];
		return \%details;
	}
	return 0;
}
sub getAllUsers()
{
	my @list;
	initiated();
	foreach my $line (@passwd)
	{
		my @curr = split(/:/, $line);
		push(@list, $curr[0]);
	}
	return @list;
};
# $1 username
# $2 password (due to my lazuness of encrypting in JS it will be encrypted on the server)
# $3 user id if we want to specify it 
# this function will create a new user and as a must will create a new homedir for him.
# it will also set his main group to a new group with his username if such doesn't exist yet
sub AddNewUser($$)
{
	my ($username, $pass, $uid) = @_;
	my $gid = 0;
	initiated();
	if(FindUser($username))
	{ return 0, "$username already exist"; }
	# i will do the simple thing and look for the greatest uid  in the passwd file than +1 it
	my @uids;
	foreach my $line (@passwd)
	{
		my @temp = split(/:/, $line);
		push(@uids, $temp[2]);
	}
	@uids = sort {$a <=> $b} @uids;
	if(!$uid)
	{
		$uid = $uids[$#uids];
		++$uid; # now the uid has the largets number  +1
	}
	else
	{
		if (any { $_ == $uid} @uids)
		{ return 0, "$uid is already in use";}
	}
	my ($rval, $err) = AddNewGroup($username, $uid);
	$gid = $uid;
	if(!$rval && $err =~/name/)
	{ return 0, "can't create group for user";}
	elsif(!$rval && $err =~/id/)
	{
		if(!AddNewGroup($username, ""))
		{ return 0, "can't create group for user";}
	}
	my $userline = "$username:x:$uid:$gid:\:/home/$username:/bin/bash";
	push(@passwd, $userline);
	WriteConfFile($passwdFile, @passwd);
	init();
	my $shadowline = "$username:". crypt($pass,(getpwuid(0))[1] ) . ":15071:0:99999:7:::";
	push(@shadow, $shadowline);
	WriteConfFile($shadowFile, @shadow);
	init();
	mkdir("/home/$username");
	return 1, "Create user $username";
};
# $1 = Username 
# remove the requested user from the passwd and shaow files
sub RemoveUser($)
{
	my $username = $_[0];
	initiated();
	my $userline = FindUser($username);
	if($userline)
	{
		my $change =0;
		for (my $i=0;$i<=$#passwd;$i++) #using for since i want the number of the line
		{
			if($userline eq $passwd[$i])
			{
				splice(@passwd, $i);
				$change++;
				last;
			}
		}
		for (my $i=0;$i<=$#shadow;$i++)
		{
			if($shadow[$i] =~ /$username:/)
			{
				splice(@shadow, $i);
				$change++;
				last;
		
			}
		}
		if($change == 2 )
		{ 
			WriteConfFile($passwdFile, @passwd);
			WriteConfFile($shadowFile, @shadow);
			RemoveGroup($username);
			init();
			return 1, "Deleted user";
		}
	}
	return 0, "no Such user";

};
# $1 = username
# $2 = password string
# returns 1 if the password is correct  0 if not
sub VerifyPassword($$)
{
	my ($username,$pass) = @_;
	initiated();
	my $userline = FindUser($username);
	my @temp = split(/:/,$userline);
	my $uid = $temp[2];
	my $pwd = (getpwuid($uid))[1];
	my $cryptopwd;
	foreach my $line (@shadow)
	{
		if($line=~/$username/)
		{ 
			@temp = split(/:/, $line);
			$cryptopwd = $temp[1];
			last;
		}
	}
	if($cryptopwd eq  crypt($pass, $pwd))
	{ return 1;}
	return 0;
};
sub getUserGroups($)
{
	my $username = $_[0];
	initiated();
	my @usergroups;
	foreach my $line (@group)
	{
		chomp($line);
		my @temp = split(/:/, $line);
		if($temp[3] && $temp[3] =~ /$username(,|$)/)
		{
			push(@usergroups, $temp[0]);
		}
	}
	return @usergroups;
};
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
};
# $1 = $groupname for group
# $2 = $groupid for group
# will add new group update the file and reinit the arrays
sub AddNewGroup($$)
{
	my ($groupname, $groupid) = @_;
	if(!$groupid)
	{
		my @gids;
		foreach my $line (@group)
		{
			my @temp = split(/:/, $line);
			push(@gids, $temp[2]);
		}
		@gids = sort {$a <=> $b} @gids;
		$groupid = $gids[$#gids];
		$groupid++;
	}
	initiated();
	my $groupHash = GetAllGroups();
	foreach my $gname (keys %{$groupHash})
	{
		if($gname eq $groupname)
		{ return 0, "Group name already exist";}
		if($groupid == $groupHash->{$gname}->{'id'})
		{ return 0, "Group ID already in use by $gname";}

	}
	my $newgroup = "$groupname:x:$groupid:";
	push(@group, $newgroup);
	WriteConfFile($groupFile, @group);
	init();
	return 1;
	
};
# $1 = group name or gid
# this will remove the group from the group filo
sub RemoveGroup($)
{
	my $group = $_[0];
	initiated();
	my $gid=0;
	if($group =~ /^\d+$/)
	{ 
		$gid = $group;
		$group = "";
	}
	my $change =0;
	for (my $i=0;$i<=$#group;$i++) #using for since i want the number of the line
	{
		my @temp = split(/:/, $group[$i]);
		if($gid)
		{
			if($temp[2] == $gid)
			{
				splice(@group, $i);
				$change=1;
				last;
			}
		}
		elsif($temp[0] eq $group)
		{
			splice(@group, $i);
			$change =1;
			last;
		}
	}
	if($change)
	{ 
		WriteConfFile($groupFile, @group);
		init();
		return 1, "Deleted group";
	}
	return 0, "no Such group";
};
# $1 = username
# $2 = groupname
# returns 1 for success 
sub addUserToGroup($$)
{
	my ($username, $groupname) = @_;
	initiated();
	my $change =0;
	for (my $i=0;$i<=$#group;$i++) #using for since i want the number of the line
	{
		my @temp = split(/:/, $group[$i]);
		if($temp[0] eq $groupname)
		{ 
			chomp($group[$i]);
			$group[$i] .= ",$username\n";
			$change =1;
		}
	}
	if($change)
	{ 
		WriteConfFile($groupFile, @group);
		init();
		return 1, "added $username to $groupname";
	}
	return 0, "no Such group";
};
sub removeUserFromGroup($$)
{
	my ($username, $groupname) = @_;
	initiated();
	my $change =0;
	for (my $i=0;$i<=$#group;$i++) #using for since i want the number of the line
	{
		my @temp = split(/:/, $group[$i]);
		if($temp[0] eq $groupname)
		{ 
			$group[$i] =~ s/$username(,|$)//;
			$group[$i] =~ s/,,+//;
			$change =1;
		}
	}
	if($change)
	{ 
		WriteConfFile($groupFile, @group);
		init();
		return 1, "removed $username from $groupname";
	}
	return 0, "no Such group";
};

# $1 = $pathtofile 
# $2 = $array to write
# will move and than print out configuration file
# return 0 and message for error 1 for success
sub WriteConfFile($$)
{
	my ($path, @arr) = @_;
	if(-e "$path.old")
	{ unlink("$path.old");}
	if(!copy("$path", "$path.old"))
	{ return 0, "Failed to copy backup file";}
	if(!open(FILE, ">$path"))
	{ return 0, "Failed to open $path";}
	foreach my $line (@arr)
	{
		chomp($line);
		print FILE "$line\n";
	}
	close FILE;
	return 1;
};

1;

