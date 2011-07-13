#!/usr/bin/perl
use Getopt::Std; # for simple flags
use Getopt::Long; # for flags with --
my %options;

sub main {
parseargs();

}
sub parseargs()
{
	my $validopts = "bEn";
	getopt($validopt,\%options) or usage();
	print "hello\n";
}
sub usage()
{
	print "
	Usage: cat [OPTION] [FILE]...\n
	Concatenate FILE(s), or standard input, to standard output.\n
	\n
	 -b, --number-nonblank    number nonempty output lines, overrides -n\n
	 -E, --show-ends          display $ at end of each line\n
	 -n, --number             number all output lines\n
	 With no FILE, or when FILE is -, read standard input.\n
	\n
	 Examples:\n
     cat f - g  Output f's contents, then standard input, then g's contents.\n
     cat        Copy standard input to standard output.\n
	";
	exit(0);

}


main();
