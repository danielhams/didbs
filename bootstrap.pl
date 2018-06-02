#!/usr/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib "$FindBin::Bin/lib";


(my $configfile = basename($0)) =~ s/^(.*?)(?:\..*)?$/$1.conf/;
my $scriptlocation = $FindBin::Bin;
#print "Script location is $scriptlocation\n";
#print "Configfile is $configfile\n";

if( -e "$scriptlocation/$configfile")
{
    print "Adding found config. To start fresh, rm $scriptlocation/$configfile\n";
    unshift(@ARGV, '@'.$scriptlocation."/".$configfile);
}

#foreach $v (@ARGV)
#{
#    print "1Have an arg $v\n";
#}

use Getopt::ArgvFile qw(argvFile);
argvFile();

#foreach $v (@ARGV)
#{
#    print "2Have an arg $v\n";
#}

use Getopt::Long;

my $packagedir = undef;
my $builddir = undef;
my $installdir = undef;
my $verbose = false;

sub usage
{
    my $error = shift;
    print("bootstrap.pl --packagedir /path/for/packages --buildir /path/forbuilding --installdir /path/for/install --verbose=true\n");
    exit( $error ? -1 : 0 );
}

sub writeconfig
{
    my $hash_ref = shift;
    my %hash = %{ $hash_ref };

    my $cfname = "$scriptlocation/$configfile";
#    print "Will write config to $cfname\n";
    open(FH, '>'.$cfname) || die $!;
    print "Would try and write out config of $hash \n";
    foreach my $key (keys %hash)
    {
	if( $key eq "packagedir" ||
	    $key eq "builddir" ||
	    $key eq "installdir" )
	{
	    printf FH "--".$key . " " . $hash{$key} . "\n";
	}
	elsif( $key eq "verbose" )
	{
	    if( $hash{$key} eq 1 )
	    {
		printf FH "--verbose\n";
	    }
	}
	else
	{
	    print "Unhandled option: $key\n";
	    exit(-1);
	}
    }
    close(FH);
}

print "didbs bootstrapper script\n";

print "TODO: Check for build prerequisites (7.4.4m, sed etc)\n";

my %options = ();

GetOptions(\%options,
           "packagedir|p=s" => \$packagedir,
	   "builddir|b=s" => \$builddir,
	   "installdir|i=s" => \$installdir,
	   "verbose|v" => \$verbose)
    or usage(true);

if( !defined($packagedir) || !defined($builddir))
{
    usage(true);
}

$options{"packagedir"} = $packagedir;
$options{"builddir"} = $builddir;
$options{"installdir"} = $installdir;
$options{"verbose"} = $verbose;

print "Going ahead with: \n";
foreach $key (keys %options)
{
    print " $key \t=> $options{$key}\n";
}

# Write our config back out
writeconfig(\%options);
