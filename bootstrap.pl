#!/usr/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib "$FindBin::Bin/lib";

# Packages specific to the tooling
use DidbsPackage;
use DidbsExtractor;

(my $configfile = basename($0)) =~ s/^(.*?)(?:\..*)?$/$1.conf/;
my $scriptlocation = $FindBin::Bin;
#print "Script location is $scriptlocation\n";
#print "Configfile is $configfile\n";

my $usingfoundconf = 0;

if( -e "$scriptlocation/$configfile")
{
    $usingfoundconf = 1;
    unshift(@ARGV, '@'.$scriptlocation."/".$configfile);
}

use Getopt::ArgvFile qw(argvFile);
argvFile();

use Getopt::Long;

my $packagedir = undef;
my $builddir = undef;
my $installdir = undef;
my $verbose = false;

sub getdefaultenv
{
    my $scriptdir = shift;
    open CFG, "<".$scriptdir."defaultenv.vars" || die $!;
    my @envvars = <CFG>;
    close CFG;

    my %values;
    foreach (@envvars) {
	chomp;
	s|#.+||;
	s|@(.+?)@|$1|g;
	s|\s||;
	my($key, $val) = split(/=/);
        $values{$key} = $val;
    }
    return %values;
}

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
#    print "Would try and write out config of $hash \n";
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
print"\n";

if( $usingfoundconf == 1 )
{
    print "Adding found config.\n To start fresh, rm $scriptlocation/$configfile\n";
}
print "TODO: Check for build prerequisites (7.4.4m, sed etc - see toolstocheckfor.txt)\n";

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

print"\n";
print "Used config: \n";
foreach $key (keys %options)
{
    print " $key \t=> $options{$key}\n";
}

# Write our config back out
writeconfig(\%options);

print"\n";
my(%envvars) = getdefaultenv($DIR);
foreach $var (keys %envvars)
{
    my $val = $envvars{$var};
    print " setting $var=$val\n";
    $ENV{$var} = $val;
}
print "Modify the above in defaultenv.vars\n";
print"\n";

my($packageid) = "tar";
#my($packageid) = "make";

my $firstpackage = DidbsPackage->new($packageid);
$firstpackage->readPackageDef($scriptlocation);
$firstpackage->debug();

# lets assume some dependency resolution occurs here
# so we end up with just one package in our dependency tree.

# At this point, we will:
# Check the package has been extracted (and when)
# Check the package has been patched (and when)
# Check the package has been configured (and when)
# Check the package has been built (and when)
# Check the package has been (manually) tested (and when)
# Check the package has been installed (and when)

my $firstpackageextractor = DidbsExtractor->new( $scriptlocation,
						 $packageid,
						 $packagedir,
						 $firstpackage );

$firstpackageextractor->debug();

if( !$firstpackageextractor->extractionSuccess() )
{
    if( !$firstpackageextractor->extractit() )
    {
	print "Unable to extract $firstpackage->{packageId}\n";
	exit(-1);
    }
}

print "WARN: Missing any patch functionality\n";

my $firstpackageconfigurator = DidbsConfigurator->new( $scriptlocation,
						       $packageid,
						       $packagedir,
						       $firstpackage,
						       $firstpackageextractor );

exit(0);
