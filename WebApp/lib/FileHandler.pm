package FileHandler;

$_caller = "Web";

# $1 = path to open
# if the path points to a file it will return the contents if its a dir it will return the files
# in it
sub ShowFile($)
{
	$path = $_[0];
	if(!-e $path)
	{ return 0, "Path does not exist";}
	if(-f $path && -T $path)
	{
		if(!open(FILE, "<", $path))
		{ 
			if($_caller eq "Web")
			{ return 0, "Cannot Open file";}
			else
			{ die("Cannot open file");}
		}
		my @contents = <FILE>;
		close(FILE);
		return @contents;
	}
	elsif(-d $path)
	{
		if(!opendir(DIR, $path))
		{
			if($_caller eq "Web")
			{ return 0, "Cannot Open file";}
			else
			{ die("Cannot open file");}
		}
		my @files = "";
		while(readdir DIR) {
			push(@files, "$_\n")
		}
		closedir DIR;
		return @files;
	}

};

# $1 = path 
# if a path is a file it removes the file otherwise 
# it removes the directory (recusrivly like rm -f)
sub RemovePath($)
{
	my $path = $_[0];
	if(-d $path)
	{
		opendir(DIR, $path);
		while(readdir(DIR))
		{
			if($_ ne "." && $_ ne ".." )
			{
				if(-d "$path/$_")
				{
					RemovePath("$path/$_");	
				}
				else
				{
					unlink("$path/$_");
				}
			}
		}
		closedir(DIR);
		rmdir($path);
	}
	else
	{
		unlink($path);
	}
	return 1;
};
# $1 array ref of file list
# $2 search term
# $3 eqievalant to -v in grep
sub grepFiles($$$)
{
	my($files, $term, $vflag) = @_;

}

1;
