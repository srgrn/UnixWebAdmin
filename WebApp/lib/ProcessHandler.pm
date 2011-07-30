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

# paramaters 
# PID to kill at $_[0]
# kill signal or number at $_[1]
sub prockill($$){
	kill $_[1],$_[0];
};




1;
