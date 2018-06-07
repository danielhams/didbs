#!/usr/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib ".";
use lib "$FindBin::Bin/lib";

# Packages specific to the tooling
use DidbsPackage;
use DidbsPackageState;
use DidbsExtractor;
use DidbsPatcher;
use DidbsConfigurator;
use DidbsBuilder;

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

my $packageDir = undef;
my $buildDir = undef;
my $installDir = undef;
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
           "packagedir|p=s" => \$packageDir,
           "builddir|b=s" => \$buildDir,
           "installdir|i=s" => \$installDir,
           "verbose|v" => \$verbose)
    or usage(true);

if( !defined($packageDir) || !defined($buildDir) || !defined($installDir))
{
    usage(true);
}

$options{"packagedir"} = $packageDir;
$options{"builddir"} = $buildDir;
$options{"installdir"} = $installDir;
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

my($packageId) = "tar";
#my($packageId) = "make";

my $curpkg = DidbsPackage->new($packageId);
$curpkg->readPackageDef($scriptlocation);
$curpkg->debug();

my $curpkgstate = DidbsPackageState->new($scriptlocation,
                                         $packageId,
                                         $packageDir,
                                         $didbsPackage);

print "Here2 ".$curpkgstate->debug()."\n";

# lets assume some dependency resolution occurs here
# so we end up with just one package in our dependency tree.

# At this point, we will:
# Check the package has been extracted (and when)
# Check the package has been patched (and when)
# Check the package has been configured (and when)
# Check the package has been built (and when)
# Check the package has been (manually) tested (and when)
# Check the package has been installed (and when)

my $curpkgextractor = DidbsExtractor->new( $scriptlocation,
                                           $packageId,
                                           $packageDir,
                                           $curpkg,
                                           $curpkgstate);

$curpkgextractor->debug();

if( !$curpkgextractor->extractionSuccess() )
{
    print "Package extraction not known.\n";
    if( !$curpkgextractor->extractit() )
    {
        print "Unable to extract $curpkg->{packageId}\n";
        exit -1;
    }
}

my $curpkgpatcher = undef;
if( defined($curpkg->{packagePatch}) &&
    $curpkgextractor->getState() ne PATCHED)
{
    $curpkgpatcher = DidbsPatcher->new( $scriptlocation,
                                        $packageId,
                                        $packageDir,
                                        $curpkg,
                                        $curpkgextractor );

    if( !$curpkgpatcher->patchit() )
    {
        print "Failed to patch $curpkg->{packageId}\n";
        exit -1;
    }
    $curpkgextractor->setState(PATCHED);
}

my $curpkgconfigurator = DidbsConfigurator->new( $scriptlocation,
                                                 $packageId,
                                                 $packageDir,
                                                 $installDir,
                                                 $curpkg,
                                                 $curpkgextractor,
                                                 $curpkgpatcher );

if( !$curpkgconfigurator->configureit() )
{
    print "Failed during configure stage.\n";
    exit -1;
}

my $curpkgbuilder = DidbsBuilder->new( $scriptlocation,
                                       $packageId,
                                       $packageDir,
                                       $installDir,
                                       $curpkg,
                                       $curpkgextractor,
                                       $curpkgpatcher,
                                       $curpkgconfigurator );
if( !$curpkgbuilder->buildit() )
{
    print "Failed during build step.\n";
    exit -1;
}

print "All done.\n";

exit(0);
