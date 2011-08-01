package ProcessHandler;
use Proc::ProcessTable; 
$PT= new Proc::ProcessTable;

sub proclist()
{
	my %list;
	my $procs= $PT->table();
	foreach my $process (@$procs)
	{
    		if($process->{'cmndline'}=~/proc/){	
		#print "$process->{'pid'}\t[$process->{'fname'}]\n";
		my $str= "$process->{'pid'}\t[$process->{'fname'}]";
		$list->{ $process->{'pid'}}="[$process->{'fname'}]";
		#print $list->{"$process->{'pid'}"},"\n";
		}
		else{
		#print "$process->{'pid'}\t$process->{'cmndline'}\n";
		my $str="$process->{'pid'}\t$process->{'cmndline'}";
		$list->{ $process->{'pid'} } ="$process->{'cmndline'}"
		}
	}
	return $list;
};
#for returning to gui - not for use internally in this module
sub get_fields()
{
	return $PT->fields();	
};
sub get_proc_by_name($){

	my $curr = $_[0];
	my $ret = 0;
	my $procs= $PT->table();
	foreach my $process (@$procs)
	{	
		if($process->{'cmndline'} =~/$curr/)
		{
			$ret = $process;
			last;
		}
	}
	return $ret;
};
sub get_proc_by_PID($){

	my $curr = $_[0];
	my $ret = 0;
	my $procs= $PT->table();
	foreach my $process (@$procs)
	{	
		if($process->{'pid'} == $curr)
		{
			$ret = $process;
			last;
		}
	}
	return $ret;
};

sub getDetails($){
	my $procid = $_[0];
	my $proc = get_proc_by_PID($procid);
	return $proc;
};
sub SetPriority($$){
	my ($pid,$priority) = @_;
	my $proc = get_proc_by_PID($pid);
	if($proc)
	{
		$proc->priority($priority);
		return 1;
	}
	return 0;
}

sub prockill($$){
	kill $_[1],$_[0];
};




1;
