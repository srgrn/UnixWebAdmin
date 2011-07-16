package ProcessHandler;
use Proc::ProcessTable; 
$PT= new Proc::ProcessTable;

sub proclist()
{
	my %list;
	my $procs= $PT->table();
	foreach $f ($PT->fields()){
	#print $f,"\t"	;
	}
	#print "\n";
	foreach my $process (@$procs)
	{
    		if($process->{'cmndline'}=~/proc/){	
		#print "$process->{'pid'}\t[$process->{'fname'}]\n";
		my $str= "$process->{'pid'}\t[$process->{'fname'}]";
		$list[$process->{'pid'}]="[$process->{'fname'}]";
		}
		else{
		#print "$process->{'pid'}\t$process->{'cmndline'}\n";
		my $str="$process->{'pid'}\t$process->{'cmndline'}";
		$list[$process->{'pid'}]="$process->{'cmndline'}"
		}
	}
	return %list;
};

sub fullProcDetails($){

	my $curr = $_[0];
	my $ret = "";
	foreach $f ($PT->fields)
	{
		$ret.= $curr->{$f}. "\t";
	}
	return $ret;
};

sub prockill($){
	kill 15,$_[0];
};




1;
