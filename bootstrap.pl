#!/usr/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib ".";
use lib "$FindBin::Bin/lib";

# Packages specific to the tooling
use DidbsStageChecker;
use DidbsDependencyEngine;
use DidbsPackage;
use DidbsPackageState;
use DidbsExtractor;
use DidbsPatcher;
use DidbsConfigurator;
use DidbsBuilder;

my $argc = ($#ARGV + 1);
my $version = "0.0.1alpha1";

(my $configfile = basename($0)) =~ s/^(.*?)(?:\..*)?$/$1.conf/;
my $scriptLocation = $FindBin::Bin;
#print "Script location is $scriptLocation\n";
#print "Configfile is $configfile\n";

my $usingfoundconf = 0;

if( -e "$scriptLocation/$configfile")
{
    $usingfoundconf = 1;
    unshift(@ARGV, '@'.$scriptLocation."/".$configfile);
}

use Getopt::ArgvFile qw(argvFile);
argvFile();

use Getopt::Long;

my $packageDir = undef;
my $buildDir = undef;
my $installDir = undef;
my $verbose = 0;
my $clean = 0;
my $clean_all = 0;
my $stoponuntested = 0;

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
# this eats values with spaces in there....
#        s|\s||;
	next if $_ eq "";
        my($key, $val) = split(/=/);
        $values{$key} = $val;
    }
    return %values;
}

sub usage
{
    my $error = shift;
    print <<EOUSAGE
Setup: bootstrap.pl [maintenance options]
Run  : bootstrap.pl
Maintenance Options:
\t-p /pathforpackages\t--packagedir /pathforpackages
\t-b /pathforbuilding\t--builddir /pathforbuilding
\t-i /pathforinstall \t--installdir /pathforinstall
\t-v                 \t--verbose
\t                   \t--clean
\t                   \t--stoponuntested

On first run you must provide the package, build and installation directories
that this bootstrapper will use.

When running the script without arguments, the script will attempt to determine
and build currently missing packages. Using the --stoponuntested flag will halt
the bootstrap process on packages that have not yet been marked as passing
their built in checks.

The first run of the script will involve bootstrapping a minimum set of
packages from which the installation packages may be built.

Configuration specified on the command line gets stored in the bootstrap.conf
file - this can be overridden by specifying the parameters a second time.
EOUSAGE
;
    exit( $error ? -1 : 0 );
}

sub writeconfig
{
    my $hash_ref = shift;
    my %hash = %{ $hash_ref };

    my $cfname = "$scriptLocation/$configfile";
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
        elsif( $key eq "stoponuntested" )
        {
            if( $hash{$key} eq 1 )
            {
                printf FH "--stoponuntested\n";
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

print "didbs bootstrapper script version $version\n";
print"\n";

if( $usingfoundconf == 1 )
{
    print "Adding found config.\n To start fresh, rm $scriptLocation/$configfile\n";
}
print "TODO: Check for build prerequisites (7.4.4m, sed etc - see toolstocheckfor.txt)\n";

my %options = ();

GetOptions(\%options,
           "packagedir|p=s" => \$packageDir,
           "builddir|b=s" => \$buildDir,
           "installdir|i=s" => \$installDir,
           "verbose|v" => \$verbose,
           "clean" => \$clean,
           "clean_all" => \$clean_all,
           "stoponuntested" => \$stoponuntested )
    or usage(true);

if( !defined($packageDir) || !defined($buildDir) || !defined($installDir))
{
    print "packageDir=$packageDir\n";
    print "buildDir=$buildDir\n";
    print "installDir=$installDir\n";
    usage(true);
}

sub prompt
{
    my( $query ) = @_;
    local $| = 1;
    print $query;
    chomp(my $answer = <STDIN>);
    return $answer;
}

sub prompt_yn
{
    my( $query ) = @_;
    my $answer = prompt("$query (y/n): ");
    print "\n";
    return lc($answer) eq 'y';
}

sub prompt_before_delete
{
    my( $dirtodelete ) = @_;
    if( $dirtodelete ne "" && $dirtodelete ne "/")
    {
	print "About to delete $dirtodelete/*\n";
	if( prompt_yn("Are you sure") )
	{
	    system("rm -rf $dirtodelete/*");
#	    print "rm -rf $dirtodelete/*";
	}
	else
	{
	    exit 0;
	}
    }
}

sub prompt_before_delete_non_stage0
{
    my( $dirtodelete ) = @_;
    print "About to delete $dirtodelete/*.installed and related directories\n";
    if( prompt_yn("Are you sure") )
    {
	system("rm -rf $dirtodelete/*.installed");
	my $cmd = "find $dirtodelete/* -type d -prune|grep -v stage0";
	my @dirstodelete = `$cmd`;
	chomp(@dirstodelete);
	foreach $subdirtodelete (@dirstodelete)
	{
	    my $sbcmd = "rm -rf $subdirtodelete";
#	    print "About to remove subdir with $sbcmd\n";
	    system($sbcmd);
	}
	exit 0;
    }
    else
    {
	exit 0;
    }
}

if( $clean )
{
    print "This will delete all non-stage0 content...\n";
    # For now leave the packages there
    prompt_before_delete_non_stage0($buildDir);
    prompt_before_delete($installDir);
    exit 0;
}

if( $clean_all )
{
    print "This will delete all content...\n";
    # For now leave the packages there
#    prompt_before_delete($packageDir);
    prompt_before_delete($buildDir);
    prompt_before_delete($installDir);
    exit 0;
}

$options{"packagedir"} = $packageDir;
$options{"builddir"} = $buildDir;
$options{"installdir"} = $installDir;
$options{"verbose"} = $verbose;
$options{"stoponuntested"} = $stoponuntested;

print"\n";
print "Used config: \n";
foreach $key (keys %options)
{
    print " $key \t=> $options{$key}\n";
}

my $parametersUpdated = $userfoundconf eq 0 || $argc >= 1;

my $shouldWriteConfig = 0;
if( -e "$scriptLocation/$configfile" &&
    $parametersUpdated &&
    !defined($ENV{"DIDBS_STAGE"}) )
{
    if( prompt_yn("This will overwrite existing config - are you sure?") )
    {
	$shouldWriteConfig = 1;
    }
    else
    {
	exit 0;
    }
}

if( $shouldWriteConfig )
{
    # Write our config back out
    writeconfig(\%options);
}

if( $parametersUpdated )
{
    print "\n";
    print "Parameters updated. Now try running bootstrap.pl alone.\n";
    exit 0;
}

# Default environment vars
print"\n";
my(%envvars) = getdefaultenv($DIR);
foreach $var (keys %envvars)
{
    my $val = $envvars{$var};
    print " setting $var=$val\n";
    $ENV{$var} = $val;
}

# Check if the stage0 (stage1?) builds
# are already complete
my $stageChecker = DidbsStageChecker->new( $scriptLocation,
					   $packageDir,
					   $buildDir,
					   $installDir );

if( $stageChecker->stagesMissing() )
{
    print "Needed stages are missing..\n";
    $stageChecker->callMissingStage();
    exit 0;
}
else
{
    # Only do this once per run of the script to keep things sane
    print "Modifying current path for this stage..\n";
    $stageChecker->modifyPathForCurrentStage();
}

my $origpath = $ENV{"PATH"};
$ENV{"PATH"} = "$installDir/bin:$origpath";
my $origPkgCpath = $ENV{"PKG_CONFIG_PATH"};
$ENV{"PKG_CONFIG_PATH"} = "$pkgConfigPath/lib/pkgconfig:$origPkgCpath";
$ENV{"DIDSB_INSTALL_DIR"} = $installDir;
print "Modify the above in defaultenv.vars\n";
print"\n";

my $packageDefsDir = $stageChecker->getStageAdjustedPackageDefDir();

my $pkgDependencyEngine = DidbsDependencyEngine->new($scriptLocation,
						     $packageDefsDir );

my $foundPackagesRef = $pkgDependencyEngine->listPackages();

my $sapd = $stageChecker->getStageAdjustedPackageDir();
my $sabd = $stageChecker->getStageAdjustedBuildDir();
my $said = $stageChecker->getStageAdjustedInstallDir();
my $pathToStage0Root = $stageChecker->getPathToStage0Root();
$ENV{"STAGE0ROOT"}=$pathToStage0Root;

foreach $pkg (@{$foundPackagesRef})
{
    my $curpkg = ${$pkg};
    my $pkgid = $curpkg->{packageId};
    print "Treating package '$pkgid'...\n";

#    if( $pkgid eq "make" )
#    {
#        print "Have the stage0root of $pathToStage0Root\n";
#        exit 1;
	doPackage( $pkg, $scriptLocation, $packageDefsDir,
		   $sapd, $sabd, $said,
		   $pathToStage0Root );
#    }
}

exit 0;

sub doPackage
{
    my( $pkgRef, $scriptLocation, $packageDefsDir,
	$packageDir, $buildDir, $installDir,
	$pathToStage0Root ) = @_;
    my $pkg = ${$pkgRef};

    my($packageId) = $pkg->{packageId};
    my($curpkg) = $pkg;

    my $curpkgstate = DidbsPackageState->new($scriptLocation,
					     $packageDefsDir,
					     $packageId,
					     $packageDir,
					     $buildDir,
					     $installDir,
					     $curpkg);

    print "$curpkg->{passesChecksIndicator} $stoponuntested\n";

    if( !$curpkg->{passesChecksIndicator} && !$stoponuntested)
    {
	print "Skipping untested package: $packageId\n";
	return;
    }

    if( $curpkgstate->getState() ne INSTALLED )
    {
	my $curpkgextractor = DidbsExtractor->new( $scriptLocation,
						   $packageId,
						   $packageDir,
						   $buildDir,
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
	    $curpkgpatcher = DidbsPatcher->new( $scriptLocation,
						$packageDefsDir,
						$packageId,
						$packageDir,
						$buildDir,
						$curpkg,
						$curpkgextractor );

	    if( !$curpkgpatcher->patchit() )
	    {
		print "Failed to patch $curpkg->{packageId}\n";
		exit -1;
	    }
	    $curpkgextractor->setState(PATCHED);
	}

	my $curpkgconfigurator = DidbsConfigurator->new( $scriptLocation,
							 $packageDefsDir,
							 $packageId,
							 $packageDir,
							 $buildDir,
							 $installDir,
							 $pathToStage0Root,
							 $curpkg,
							 $curpkgextractor,
							 $curpkgpatcher );


	if( !$curpkgconfigurator->configureit() )
	{
	    print "Failed during configure stage.\n";
	    exit -1;
	}

	my $curpkgbuilder = DidbsBuilder->new( $scriptLocation,
					       $packageDefsDir,
					       $packageId,
					       $packageDir,
					       $buildDir,
					       $installDir,
					       $pathToStage0Root,
					       $curpkg,
					       $curpkgextractor,
					       $curpkgpatcher,
					       $curpkgconfigurator );
	if( !$curpkgbuilder->buildit() )
	{
	    print "Failed during build step.\n";
	    exit -1;
	}
	print "Package $packageId complete.\n";

	if( $stoponuntested && !($curpkg->{passesChecksIndicator}) )
	{
	    print "This package is marked untested, please do the tests.\n";
	    exit 0;
	}
	else
	{
	    $curpkgstate->setState(INSTALLED);
	}
    }
}
