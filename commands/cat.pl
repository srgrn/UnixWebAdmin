#!/usr/bin/perl

## this script is a copy of the cat command in linux
use Getopt::Std; # for simple flags
my ($linenumber,$markending)=0; ## global contorl variables for opts
my @inputpaths;
sub cat {
	parseargs();
	if($#inputpaths==-1)
	{
		printPath("");
	}
	foreach my $path (@inputpaths)
	{
		printPath($path);
	}
}

## parsing input arguments when all the non flags will be considered as paths
sub parseargs()
{
	my $validopts = "bEnh";
	if(!getopts($validopts) || $Getopt::Std::opt_h)
	{
		usage();
	}
	if($Getopt::Std::opt_b)
	{
		$linenumber="non_empty";
	}
	elsif($Getopt::Std::opt_n)
	{
		$linenumber="all";
	}
	if($Getopt::Std::opt_E)
	{
		$markending=1;
	}
	@inputpaths= @ARGV;
}
## printing usage and quits the program the text is copied from the documanttion for cat
sub usage()
{
	print "
	Usage: cat [OPTION] [FILE]...\n
	Concatenate FILE(s), or standard input, to standard output.\n
	\n
	 -b		number nonempty output lines, overrides -n\n
	 -E		display $ at end of each line\n
	 -n		number all output lines\n
	 With no FILE, or when FILE is -, read standard input.\n
	\n
	 Examples:\n
     cat f - g  Output f's contents, then standard input, then g's contents.\n
     cat        Copy standard input to standard output.\n
	";
	exit(0);
	# it is interesting that running the cat from the example (cat f - g) get stuck in the STDIN part 
	#just like when i try it in real unix cat command
}

## getting a path to a file and printing it.
sub printPath($)
{
	my $curr = $_[0];
	my $filehandle="";
	my $count=0;
	if($curr eq "-" || $curr eq "") # in case i want to read from STDIN
	{
		while(1){
		$filehandle = <STDIN>;
		if($linenumber eq "all") 
		{print "    ",++$count,"\t";}
		elsif($linenumber eq "non_empty" && $filehandle =~ /[a-zA-Z0-9]/)
		{print "    ",++$count,"\t";}
			if($markending)
			{
				chomp($filehandle);
				$filehandle.="\$\n";
			}
		print "$filehandle";
		}
	}
	else
	{
		if(!open($filehandle,"<",$curr))
		{
			print "$curr: No such file or directory\n";
			return(0);
		}
		foreach my $line (<$filehandle>)
		{
			if($linenumber eq "all") 
				{print "    ",++$count,"\t";}
			elsif($linenumber eq "non_empty" && $line =~ /[a-zA-Z0-9]/)
				{print "    ",++$count,"\t";}
			if($markending)
			{
				chomp($line);
				$line.="\$\n";
			}
			print "$line";
			
		}
	}
	
}
sub main()
{
	cat();
}
main();
