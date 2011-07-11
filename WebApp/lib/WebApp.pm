package WebApp;
use Dancer ':syntax';

require ProcessHandler;
our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};
get '/process' => sub {
	my @list = &ProcessHandler::proclist();
	template 'proc' ,{'proclist' => \@list};
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

true;
