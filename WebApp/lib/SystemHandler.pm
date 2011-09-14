package SystemHandler;

use Modern::Perl;
our $_caller = "Web";

sub GetMemoryDetails()
{
	open(MEMINFO, "<","/proc/meminfo" );
	my @meminfo = <MEMINFO>;
	close MEMINFO;
	return @meminfo;

};
sub GetCpuDetails()
{
	open(CPUINFO, "<","/proc/cpuinfo" );
	my @cpuinfo = <CPUINFO>;
	close CPUINFO;
	return @cpuinfo;
};
sub GetNetDetails()
{
    use Sys::Hostname;
    use IO::Interface::Simple;
	my $hash->{'host'} = hostname();
	my @interfaces = IO::Interface::Simple->interfaces;
	for my $if (@interfaces) 
	{
		$hash->{$if} = $if->address;
	}
	return $hash;
};
sub GetOtherDetails()
{
	my $hash;
	$hash->{'load_average'} = loadaverage();
	$hash->{'uptime'} = uptime();
	$hash->{'systemtime'} = localtime();
	return $hash;
};
sub loadaverage()
{
	open(LOAD, "<", "/proc/loadavg");
	my @temp = <LOAD>;
	close LOAD;
	my @loads = split(/\s+/, $temp[0]);
	return "$loads[0] $loads[1] $loads[2]";
};
sub uptime()
{
	open(UP, "<", "/proc/uptime");
	my $min=60;
	my $hour = $min*60;
	my @temp = <UP>;
	close UP;
	my ($uptime, $jnk) = split(/\s+/, $temp[0]);
	$uptime = int($uptime); 
	my $minutes = 0;
	my $hours = 0;
	my $seconds = $uptime;
	while ($seconds >= $min)
	{
		while ($seconds >= $hour)
		{
			$seconds -= $hour;
			++$hours;
		}
		$seconds -= $min;
		++$minutes;
	}
											 
	if($seconds < 10)
	{ $seconds = "0$seconds"; }
	if($minutes < 10)
	{ $minutes = "0$minutes"; }
	if($hours < 10)
	{ $hours = "0$hours"; }
	return "$hours:$minutes:$seconds";
};

1;
