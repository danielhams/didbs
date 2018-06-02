#!/usr/bin/perl

use Getopt::Long;

my $config = "config.dat";
my $packagedir = undef;
my $builddir = undef;
my $installdir = undef;
my $verbose = true;

sub usage
{
    my $error = shift(@$);
    print("bootstrap.pl --packagedir /path/for/packages --buildir /path/forbuilding --installdir /path/for/install --verbose=true\n");
    exit( $error ? -1 : 0 );
}

print "didbs bootstrapper script\n";

print "TODO: Check for build prerequisites (7.4.4m, sed etc)\n";

print "Checking for previous config..\n";

GetOptions("packagedir=s" => \$packagedir,
	   "builddir=s" => \$builddir,
	   "installdir=s" => \$installdir,
	   "verbose" => \$verbose)
    or usage(true);

if( !defined($packagedir) || !defined($builddir))
{
    usage(true);
}
