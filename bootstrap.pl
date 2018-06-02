#!/usr/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib "$FindBin::Bin/lib";

use Getopt::ArgvFile qw(argvFile);

use Getopt::Long;

argvFile;

(my $configfile = basename($0)) =~ s/^(.*?)(?:\..*)?$/$1.conf/;
print "Configfile is $configfile\n";

if( -e "$Bin/$configfile")
{
    unshift @ARGV, '@'."$Bin/$configfile";
}

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

sub writeconfig
{
    my %options = @_;
    print "Would try and write out config\n";
}

print "didbs bootstrapper script\n";

print "TODO: Check for build prerequisites (7.4.4m, sed etc)\n";

GetOptions(\%options,
           "packagedir=s" => \$packagedir,
	   "builddir=s" => \$builddir,
	   "installdir=s" => \$installdir,
	   "verbose" => \$verbose)
    or usage(true);

if( !defined($packagedir) || !defined($builddir))
{
    usage(true);
}

# Write our config back out
writeconfig(%options);
