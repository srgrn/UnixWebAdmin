package WebApp;
use Dancer ':syntax';

require ProcessHandler;
our $VERSION = '0.2';
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
   template 'index'; 
};
get '/process' => sub {
	my %list = &ProcessHandler::proclist();
	template 'proc' ,{'proclist' => \%list};
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
	my $procid = params->{id};
	&ProcessHandler::prockill($procid);
	return "killed Proccess";
};
any ['get', 'post'] => '/login' => sub {
   my $err;

   if ( request->method() eq "POST" ) {
     # process form input
     if ( params->{'username'} ne setting('username') ) {
       $err = "Invalid username";
     }
     elsif ( params->{'password'} ne setting('password') ) {
       $err = "Invalid password";
     }
     else {
       session 'logged_in' => true;
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
