package UserHandler;

my $passwdFile="/etc/passwd";
my $shadowFile="/etc/shadow";
my $groupFile="/etc/group";
my (@passwd,@shadow,@group);
my $err = "";
my $state=0; # 0 for not init 1 for init 2 for future reference;
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
sub FindUser($)
{
	my $username = $_[0];
	if($state!=1)
	{ 
		if(init())
		{
			print "An error Occured: $err\n";
			exit(0);
		}	
	}
	foreach my $line (@passwd)
	{
		my @curr = split(/:/,$line);
		if ($curr[0] eq $username)
			{ return $line };
	}
	#print "No Such User";
	return 0;
};
sub VerifyPassword($$)
{
	my ($username,$pass) = @_;
	if($state!=1)
	{
		if(init())
		{
			print " an Error occured: $err\n";
			exit(0);
		}
	}
	my $userline = FindUser($username);
	my @temp = split(/:/,$userline);
	my $uid = $temp[2];
	my $pwd = (getpwuid(1000))[1];
	my $cryptpwd;
	foreach my $line (@shadow)
	{
		if($line=~/$username/)
		{ 
			@temp = split(/:/,$line);
			$cryptopwd = $temp[1];
			break;
		}
	}
	if($cryptopwd eq  crypt($pass, $pwd))
	{ return 1;}
	return 0;
}

1;
