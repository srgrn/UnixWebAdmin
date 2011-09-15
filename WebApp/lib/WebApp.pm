package WebApp;
use Dancer ':syntax';
use Modern::Perl;

require ProcessHandler;
require UserHandler;
require SystemHandler;
our $VERSION = '0.4';
our $flash = "";
set 'username' => 'admin';
set 'password' => 'password';
before_template sub {
   my $tokens = shift;
   $tokens->{'css_url'} = request->base . 'css/style.css';
   $tokens->{'login_url'} = uri_for('/login');
   $tokens->{'logout_url'} = uri_for('/logout');
};
get '/' => sub {
   my $network = &SystemHandler::GetNetDetails();
   my @cpu = &SystemHandler::GetCpuDetails();
   my @memory = &SystemHandler::GetMemoryDetails();
   my $other = &SystemHandler::GetOtherDetails();
   template 'index', 
	{
		'net' => $network, 
		'cpu' => \@cpu, 
		'memory' => \@memory, 
		'other' => $other
	}; 
};
get '/process' => sub {
	my $list = &ProcessHandler::proclist();
	template 'proc' ,
	{
		'proclist' => $list, 
		'title' => "Process Table", 
		'infotext' => "Here you can see the process that are currently running"
	};
};

get '/verify/:name' => sub {
	my $name = params->{name};
	if($name =~ /amir/i)
	{
		return "Get into continue on your own";
	}
	return "Welcome to my starter project $name"; 
};
get '/kill/:id' => sub {
	if(request->referer =~ /process/)
	{
		my $procid = params->{id};
		&ProcessHandler::prockill($procid, 15);
		set_flash('Killed process with PID $procid');
   		my $list = &ProcessHandler::proclist();
		template 'proc' ,
		{
			'proclist' => $list, 
			'title' => "Process Table", 
			'infotext' => "Killed process with PID $procid"
		};
	}
};
get '/users' => sub {
	my @list = &UserHandler::getAllUsers();
	template 'AllUsers' ,
	{
		'list' => \@list, 
		'title' => "All Users", 
		'infotext' => "Showing all users in the system"
	};
};
get '/groups' => sub {
	my $groupsref = &UserHandler::GetAllGroups();
	template 'AllGroups', 
	{
		'list' => $groupsref, 
		'title' => "All Groups", 
		'infotext' => "Showing all groups in the system"
	};
};
get '/adduser' => sub {
	template 'adduser', 
	{
		'title' => "Create New user", 
		'infotext' => "Create new user to the system"
	};
};
post '/adduser' => sub {
	my $username = params->{username};
	my $password = params->{password};
	my $uid = params->{uid};
	my ($ret, $infotext) = &UserHandler::AddNewUser($username, $password, $uid);
	if(!$ret)
	{
		template 'adduser', 
		{
			'title' => "User creation failed", 
			'infotext' => $infotext
		};
	}
	else
	{
		redirect "/edituser/$username";
	}
};
get '/addgroup' => sub {
	template 'addgroup', 
	{
		'title' => "Create New Group", 
		'infotext' => "Create new group in the system"
	};
};
post '/addgroup' => sub {
	my $name = params->{name};
	my $gid = params->{gid};
	my ($ret, $infotext) = &UserHandler::AddNewGroup($name, $gid);
	if(!$ret)
	{
		template 'addgroup', 
		{
			'title' => "Group creation failed", 
			'infotext' => $infotext
		};
	}
	else
	{
		redirect "/groups";
	}
};

get '/edituser/:user' => sub {
	my $user = params->{user};
	my $details= &UserHandler::userDetails($user);
	my @usergroups = &UserHandler::getUserGroups($user);
	template 'edituser' , 
	{
		'details' => $details,
		'groups' => \@usergroups, 
		'title' => "Edit User $user", 
		'infotext' => "Showing $user details"
	};

};
post '/edituser/:username' => sub {
	my $hashref = params;
	my $username = params->{username};
	my $newgroup = params->{newgroup};
	my $infotext = "";
	foreach my $key (keys %$hashref)
	{
		if($key !~ "newgroup" && $key !~ "submit")
		{ 
			my ($output, $string) = &UserHandler::removeUserFromGroup($username, $key);
			if($output)
			{$infotext .= $string;}
		}
	}
	if($newgroup)
	{ 
		my ($output, $string) = &UserHandler::addUserToGroup($username, $newgroup);
		if($output)
		{$infotext .= $string;}
	}
	if($infotext eq "")
	{ $infotext = "User $username was not changed";}
	my @list = &UserHandler::getAllUsers();
	template 'AllUsers' ,
	{
		'list' => \@list, 
		'title' => "All Users", 
		'infotext' => $infotext
	};


};
get '/deleteUser/:username' => sub {
	my $username = param 'username';
	my ($output, $infotext) = &UserHandler::RemoveUser($username);
	if(!$output)
	{ $infotext = "Failed to delete user or no such user";}
	my @list = &UserHandler::getAllUsers();
	template 'AllUsers' ,
	{
		'list' => \@list, 
		'title' => "All Users", 
		'infotext' => $infotext
	};
};
get '/deleteGroup/:group' => sub {
	my $group = param 'group';
	my ($output, $infotext) = &UserHandler::RemoveGroup($group);
	if(!$output)
	{ $infotext = "Failed to delete group or no such group";}
	my $groupsref = &UserHandler::GetAllGroups();
	template 'AllGroups', 
	{
		'list' => $groupsref, 
		'title' => "All Groups", 
		'infotext' => $infotext
	};
};

any ['get', 'post' ] => '/priority' => sub {
	my $pid = params->{pid};
	my $pri = params->{pri};
	if(&ProcessHandler::SetPriority($pid, $pri))
	{
		redirect "/details/$pid";
	}
	redirect '/process';
};
get '/details/:id' => sub {
	my $procid = params->{id};
	my $specific = &ProcessHandler::getDetails($procid);
	my @fields = &ProcessHandler::get_fields();
	template 'ProcDetails' , 
	{ 'fields'=> \@fields, 
	'curr' => $specific 
	};
};
any ['get', 'post'] => '/login' => sub {
   my $err;
   if ( request->method() eq "POST" ) {
     # process form input
     if (!&UserHandler::FindUser(params->{'username'} ) ) {
       $err = "Invalid username";
     }
     elsif (!&UserHandler::VerifyPassword(params->{'username'},params->{'password'}) ) {
       $err = "Invalid password";
     }
     else {
       session 'logged_in' => true;
       session 'username' => params->{'username'};
	   set_flash('You are logged in.');
       redirect '/';
     }
  }

  # display login form
  template 'login', { 
    'err' => $err,
  };
};
get '/logout' => sub {
   session->destroy;
   set_flash('You are logged out.');
   redirect '/';
};
 sub set_flash { $flash = shift; };
 sub get_flash { my $msg = $flash; $flash = ""; return $msg; }; 
true;
