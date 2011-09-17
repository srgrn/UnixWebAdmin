package FileHandler;

use Modern::Perl;
use File::Copy;
our $_caller = "Web";

# $1 = path to open
# if the path points to a file it will return the contents if its a dir it will return the files
# in it
sub ShowFile($)
{
	my $path = $_[0];
	$path =~ s/^/\//;
	$path =~ s/\*hidden\*_//;
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
sub ShowDir($)
{
	my $path = $_[0];
	$path =~ s/^/\//;
	$path =~ s/\*hidden\*_//;
	if(!-e $path)
	{ return 0, "Path does not exist";}
	if(!opendir(DIR, $path))
		{
			if($_caller eq "Web")
			{ return 0, "Cannot Open file";}
			else
			{ die("Cannot open file");}
		}
		my %files; 
		while(readdir DIR) {
			my $file = $_;
			my $isdir=0;
			if(-d "$path/$file")
			{$isdir = 1;}
			if($file eq ".." || $file eq ".")
			{ next;}
			$file =~ s/^\./*hidden*_./;
			$files{$file} = {'name' => "$file" , 'fullpath' => "$path/$file", 'dir'=> $isdir};
		}
		closedir DIR;
		return \%files;

};
# $1 = path 
# if a path is a file it removes the file otherwise 
# it removes the directory (recusrivly like rm -f)
sub RemovePath($)
{
	my $path = $_[0];
	$path =~ s/^/\//;
	$path =~ s/\*hidden\*_//;		
	if(-d $path)
	{
		opendir(my $handle, $path);
		while(readdir($handle))
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
		closedir($handle); #there is a bug here
		rmdir($path);
	}
	else
	{
		unlink($path);
	}
	return 1;
};
sub MovePath($$)
{
	my ($oldpath, $newpath) = @_;
	$oldpath =~ s/^\/*/\//;
	$oldpath =~ s/\*hidden\*_//;		
	$newpath =~ s/^\/*/\//;
	if(!-e $oldpath)
	{ return 0, "Oldpath not found to move"}
	move($oldpath, $newpath);
	return 1;
};
# $1 array ref of file list
# $2 search term
# $3 eqievalant to -v in grep
sub grepFiles($$$)
{
	my($location, $fileterm, $term) = @_;
	my @resultset;
	$location =~ s/^\/*/\//;
	$location =~ s/\*hidden\*_//;
	if(-f $location)
	{
		open(my $handle, "<", "$location");
		my $i=0;
		my @contents = <$handle>;
		close $handle;
		foreach my $line (@contents)
		{
			if($line =~ /$term/)
			{ push(@resultset, "$location:$i:$line")}
			$i++;
		}
		return @resultset;
	}
	elsif(-d "$location")
	{
		opendir(my $handle, "$location");
		while(readdir($handle))
		{
			my $file = $_;
			if($file eq "." || $file eq "..")
			{ next; }
			if($file =~ /$fileterm/)
			{
				push(@resultset, grepFiles("$location/$file", "", $term));
			}
		}
		closedir $handle;
		return @resultset;
	}
	else
	{
		return 0, "cannot find $location";
	}


};
sub replaceInFiles($$$$)
{
	my ($location, $fileterm, $searchterm, $replace) = @_;
	my @result = grepFiles($location, $fileterm, $searchterm);
	foreach my $line (@result)
	{
		my @temp = split(/:/, $line);
		open(my $handle, "<", $temp[0]);
		my @contents = <$handle>;
		close $handle;
		$contents[$temp[1]] =~ s/$searchterm/$replace/;
		UpdateFile($temp[0], join("", @contents));	
	}
};
sub UpdateFile($$)
{
	my ($path, $contents) = @_;
	if(!-f $path)
	{ return 0, "File Not Found";}
	if(!open(FILE, ">", $path))
	{ return 0, "cannot open File $path";}
	print FILE $contents;
	close FILE;
	return 1;

};
sub CreateFile($$)
{
	my ($path, $contents) = @_;
	if(-f $path)
	{ return 0, "File already exists";}
	open(FILE, ">", $path);
	print FILE $contents;
	close FILE;
	return 1;
};
sub CreateDir($)
{
	my $path = $_[0];
	if(-d $path || -f $path)
	{ return 0, "name already in use";}
	if(mkdir("$path"))
	{ return 1}
	return 0, "Failed to create Dir";
};
1;
