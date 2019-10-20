#!/usr/didbs/current/bin/perl

use File::Basename qw/basename/;
use FindBin;
use lib ".";
#use lib "$FindBin::Bin/lib";

# Packages specific to the tooling
use DidbsStageChecker;
use DidbsDependencyEngine;
use DidbsPackage;
use DidbsPackageState;
use DidbsExtractor;
use DidbsPatcher;
use DidbsConfigurator;
use DidbsBuilder;
use DidbsInstaller;
use DidbsPackageShell;
use DidbsUtils;
use DidbsDependencyWriter;

STDERR->autoflush(1);
STDOUT->autoflush(1);

my $argc = ($#ARGV + 1);
my $version = "0.1.6";

(my $configfile = basename($0)) =~ s/^(.*?)(?:\..*)?$/$1.conf/;
my $scriptLocation = $FindBin::Bin;
#didbsprint "Script location is $scriptLocation\n";
#didbsprint "Configfile is $configfile\n";

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
my $didbselfwidth = "n32";
my $didbsisa = "mips3";
my $didbscompiler = "mipspro";
my $verbose = 0;
my $clean = 0;
my $clean_all = 0;
my $stoponuntested = 0;
my $dryrun = 0;
my $buildpackage = undef;
my $buildshellpackage = undef;

sub supressenv
{
    my $scriptdir = shift;
    open CFG, "<".$scriptdir."suppressenv.vars" || die $!;
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
	delete $ENV{$_};
	if($verbose)
	{
		didbsprint " Supressing environment $_\n";
	}
    }
}

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
	my $firstEqualPos = index($_,"=");
	my $key = substr($_, 0, $firstEqualPos);
	my $val = substr($_, $firstEqualPos+1);
#	print "Found $key->$val\n";
        $values{$key} = $val;
    }
#    exit -1;
    return %values;
}

sub getoverrideenv
{
    my $scriptdir = shift;
    my $overridefile = $scriptdir."overrideenv.vars";
    if( -e $overridefile ) {
	open CFG, "<".$scriptdir."overrideenv.vars" || die $!;
	my @envvars = <CFG>;
	close CFG;

	my %values;
	foreach (@envvars) {
	    chomp;
	    s|#.+||;
	    s|@(.+?)@|$1|g;
            # this eats values with spaces in there....
#	    s|\s||;
	    next if $_ eq "";
	    my $firstEqualPos = index($_,"=");
	    my $key = substr($_, 0, $firstEqualPos);
	    my $val = substr($_, $firstEqualPos+1);
#	    print "Found $key->$val\n";
	    $values{$key} = $val;
	}
#	exit -1;
	return %values;
    }
    return {};
}

sub usage
{
    my $error = shift;
    print <<EOUSAGE
Setup: bootstrap.pl [maintenance options]
Run  : bootstrap.pl
Maintenance Options: (# = not yet working)
\t-p /pathforpackages\t--packagedir /pathforpackages
\t-b /pathforbuilding\t--builddir /pathforbuilding
\t-i /pathforinstall \t--installdir /pathforinstall
\t-e n32/64          \t--elfwidth n32/64      (n32)
\t-a mips3/mips4     \t--isa mips3/mips4      (mips3)
\t-c mipspro/gcc     \t--compiler mipspro/gcc (mipspro)
\t-v                 \t--verbose
\t                   \t--clean                (non-stage0 builds)
\t                   \t--clean-all            (builds + installs)
\t                   \t--stoponuntested
\t                   \t--dryrun
#\t                   \t--build PACKAGENAME
\t                   \t--buildshell PACKAGENAME
#\t                   \t--release RELEASEID    (create tooling .inst)

On first run you must provide the package, build and installation directories
that this bootstrapper will use. If not specified, didbs will default to n32,
mips3, mipspro.

Didbs bootstrap building relies on the use of a previous didbs release
extracted and symbolically linked to '/usr/didbs/current'. This tooling must be
the "n32" "mips3" "mipspro" release to allow building any variation.

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
    $verbose && didbsprint "Will write config to $cfname\n";
    open(FH, '>'.$cfname) || die $!;

    foreach my $key (keys %hash)
    {
        if( $key eq "packagedir" ||
            $key eq "builddir" ||
            $key eq "installdir" ||
	    $key eq "elfwidth" ||
	    $key eq "isa" ||
	    $key eq "compiler")
        {
            printf FH "--".$key . " " . $hash{$key} . "\n";
        }
#	elsif( $key eq "abi" )
#	{
#	    printf FH "--".$key . " " . $hash{$key} . "\n";
#	}
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
            didbsprint "Unhandled option: $key\n";
            exit(-1);
        }
    }
    close(FH);
}

didbsprint "didbs bootstrapper script version $version\n";
didbsprint "\n";

if( $usingfoundconf == 1 )
{
    didbsprint "Adding found config.\n To start fresh, rm $scriptLocation/$configfile\n";
}

my %options = ();

GetOptions(\%options,
           "packagedir|p=s" => \$packageDir,
           "builddir|b=s" => \$buildDir,
           "installdir|i=s" => \$installDir,
	   "elfwidth|e=s" => \$didbselfwidth,
	   "isa|a=s" => \$didbsisa,
	   "compiler|c=s" => \$didbscompiler,
           "verbose|v" => \$verbose,
           "clean" => \$clean,
           "clean-all" => \$clean_all,
           "stoponuntested" => \$stoponuntested,
           "dryrun" => \$dryrun,
	   "build=s" => \$buildpackage,
           "buildshell=s" => \$buildshellpackage )
    or usage(true);

$verbose = $verbose || $ENV{"V"}=="1";

#if( !defined($packageDir) || !defined($buildDir) || !defined($installDir)
#    || !defined($didbsabi))
if( !defined($packageDir) || !defined($buildDir) || !defined($installDir)
 || !defined($didbselfwidth) || !defined($didbsisa) || !defined($didbscompiler)
  )
{
    $verbose && didbsprint "packageDir=$packageDir\n";
    $verbose && didbsprint "buildDir=$buildDir\n";
    $verbose && didbsprint "installDir=$installDir\n";
    $verbose && didbsprint "elfwidth=$didbselfwidth\n";
    $verbose && didbsprint "isa=$didbsisa\n";
    $verbose && didbsprint "compiler=$didbscompiler\n";
    usage(true);
}

my $compatibleDidbsCurrent = compatibledidbscurrent($verbose,$version);
if( !$compatibleDidbsCurrent )
{
    print <<EOINCOMPATIBLEDIDBSCURRENT
ERROR
Starting with 0.1.6alpha, running bootstrap requires an existing compatible
didbs release behind a symbolic link at /usr/didbs/current.
Unable to continue.
EOINCOMPATIBLEDIDBSCURRENT
;
    exit -1;
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
    didbsprint "\n";
    return lc($answer) eq 'y';
}

sub prompt_before_delete
{
    my( $dirtodelete ) = @_;
    if( $dirtodelete ne "" && $dirtodelete ne "/")
    {
	didbsprint "About to delete $dirtodelete/*\n";
	if( prompt_yn("Are you sure") )
	{
	    system("rm -rf $dirtodelete/*");
#	    didbsprint "rm -rf $dirtodelete/*";
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
    didbsprint "About to delete $dirtodelete/*.installed and related directories\n";
    if( prompt_yn("Are you sure") )
    {
	system("rm -rf $dirtodelete/*.installed");
	my $cmd = "find $dirtodelete/* -type d -prune|grep -v stage0";
	my @dirstodelete = `$cmd`;
	chomp(@dirstodelete);
	foreach $subdirtodelete (@dirstodelete)
	{
	    my $sbcmd = "rm -rf $subdirtodelete";
#	    didbsprint "About to remove subdir with $sbcmd\n";
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
    didbsprint "This will delete all non-stage0 content...\n";
    # For now leave the packages there
    prompt_before_delete_non_stage0($buildDir);
    prompt_before_delete($installDir);
    exit 0;
}

if( $clean_all )
{
    didbsprint "This will delete all content...\n";
    # For now leave the packages there
#    prompt_before_delete($packageDir);
    prompt_before_delete($buildDir);
    prompt_before_delete($installDir);
    exit 0;
}

$options{"packagedir"} = $packageDir;
$options{"builddir"} = $buildDir;
$options{"installdir"} = $installDir;
$options{"elfwidth"} = $didbselfwidth;
$options{"isa"} = $didbsisa;
$options{"compiler"} = $didbscompiler;
$options{"verbose"} = $verbose;
$options{"stoponuntested"} = $stoponuntested;

print"\n";
if($verbose)
{
    didbsprint "Used config: \n";
    foreach $key (keys %options)
    {
	didbsprint " $key \t=> $options{$key}\n";
    }
}

my $onlyDryrunArguments = (($argc == 1) && ($dryrun == 1)) ? 1 : 0;
my $nonDestructiveParameters = ($onlyDryrunArguments || ($buildshellpackage ne "")) ? 1 : 0;

my $parametersUpdated = ($usingfoundconf == 0 || $argc >= 1) && ($nonDestructiveParameters == 0)
    ? 1 : 0;

if($verbose)
{
    didbsprint "usingfoundconf=$usingfoundconf\n";
    didbsprint "argc=$argc\n";
    didbsprint "dryrun=$dryrun\n";
    didbsprint "onlyDryrunArguments=$onlyDryrunArguments\n";
    didbsprint "nonDestructiveParameters=$nonDestructiveParameters\n";
    didbsprint "parametersUpdated=$parametersUpdated\n";
}

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
else
{
    $shouldWriteConfig = $parametersUpdated;
}

if( $shouldWriteConfig )
{
    # Write our config back out
    writeconfig(\%options);
}
elsif($verbose)
{
    didbsprint "Not updating configuration file\n";
}

if( $parametersUpdated )
{
    didbsprint "\n";
    didbsprint "Parameters updated. Now try running bootstrap.pl alone.\n";
    exit 0;
}

# Default environment vars
print"\n";
supressenv($DIR);
my(%envvars) = getdefaultenv($DIR);
foreach $var (keys %envvars)
{
    my $val = $envvars{$var};
    $verbose && didbsprint " setting $var=$val\n";
    $ENV{$var} = $val;
}
# And an env var to allow GCC versions to reflect the didbs version
$ENV{"DIDBS_VERSION"} = $version;

# A hash of the default env, suppressed env and params for the build
my $didbsenvhash=DidbsPackageHasher::calculateEnvHash(
    $scriptdir."defaultenv.vars",
    $scriptdir."suppressenv.vars",
    $didbselfwidth,
    $didbsisa,
    $didbscompiler );

my(%envvars) = getoverrideenv($DIR);
foreach $var (keys %envvars)
{
    my $val = $envvars{$var};
    $verbose && didbsprint " override of $var=$val\n";
    $ENV{$var} = $val;
}

# And set up the necessary env vars computed from
# the elfwidth,isa and compiler
my $didbsarchcflags="";
my $didbsarchldflags="";
my $didbslibdir="";
if( $didbscompiler eq "mipspro" ) {
    if( $didbsisa eq "mips3" ) {
	$didbsarchcflags .= "-mips3 ";
	$didbsarchldflags .= "-mips3 ";
    }
    elsif( $didbsisa eq "mips4" ) {
	$didbsarchcflags .= "-mips4 ";
	$didbsarchldflags .= "-mips4 ";
    }
    else {
	didbsprint "Error: unknown isa:$didbselfwidth\n";
	exit(1);
    }

    if( $didbselfwidth eq "n32" ) {
	$didbsarchcflags .= "-n32 ";
	$didbsarchldflags .= "-n32 ";
	$didbslibdir = "lib32";
    } elsif ( $didbselfwidth eq "n64" ) {
	$didbsarchcflags .= "-64 ";
	$didbsarchldflags .= "-64 ";
	$didbslibdir = "lib64";
	didbsprint "Error: 64 bit compile not yet supported\n";
	exit(1);
    }
    else {
	didbsprint "Error: unknown elfwidth:$didbselfwidth\n";
	exit(1);
    }

    $ENV{"DIDBS_CC"}=$ENV{"DIDBS_MP_CC"};
    $ENV{"DIDBS_CXX"}=$ENV{"DIDBS_MP_CXX"};
}
else
{
    # GCC setup here....
    if( $didbsisa eq "mips3" ) {
	$didbsarchcflags .= "-mips3 ";
	$didbsarchldflags .= "-mips3 ";
    }
    elsif( $didbsisa eq "mips4" ) {
	$didbsarchcflags .= "-mips4 ";
	$didbsarchldflags .= "-mips4 ";
    }
    else {
	didbsprint "Error: unknown isa:$didbselfwidth\n";
	exit(1);
    }

    if( $didbselfwidth eq "n32" ) {
#	$didbsarchcflags .= "-n32 ";
#	$didbsarchldflags .= "-n32 ";
	$didbslibdir = "lib32";
    } elsif ( $didbselfwidth eq "n64" ) {
#	$didbsarchcflags .= "-64 ";
#	$didbsarchldflags .= "-64 ";
	$didbslibdir = "lib64";
	didbsprint "Error: 64 bit compile not yet supported\n";
	exit(1);
    }
    else {
	didbsprint "Error: unknown elfwidth:$didbselfwidth\n";
	exit(1);
    }

    $ENV{"DIDBS_CC"}=$ENV{"DIDBS_GCC_CC"};
    $ENV{"DIDBS_CXX"}=$ENV{"DIDBS_GCC_CXX"};

    # Add in additional paths needed for GCC tooling
    $ENV{"PATH"}=$ENV{"DIDBS_GCC_PATH"}.":".$ENV{"PATH"};
    $ENV{"LD_LIBRARYN32_PATH"}=$ENV{"DIDBS_GCC_LD_LIBRARYN32_PATH"}.":".$ENV{"LD_LIBRARYN32_PATH"};
    $ENV{"LD_LIBRARYN64_PATH"}=$ENV{"DIDBS_GCC_LD_LIBRARYN64_PATH"}.":".$ENV{"LD_LIBRARYN64_PATH"};
}

$ENV{"DIDBS_ARCH_CFLAGS"} = $didbsarchcflags;
$ENV{"DIDBS_ARCH_CXXFLAGS"} = $didbsarchcflags;
$ENV{"DIDBS_ARCH_LDFLAGS"} = $didbsarchldflags;
$ENV{"DIDBS_LIBDIR"} = $didbslibdir;

if( $verbose ) {
    didbsprint "CC            = '".$ENV{"DIDBS_CC"}."'\n";
    didbsprint "CXX           = '".$ENV{"DIDBS_CXX"}."'\n";
    didbsprint "arch CFLAGS   = '$didbsarchcflags'\n";
    didbsprint "arch CXXFLAGS = '$didbsarchcflags'\n";
    didbsprint "arch LDFLAGS  = '$didbsarchldflags'\n";
    didbsprint "libdir        = '$didbslibdir'\n";
    didbsprint "env hash      = '$didbsenvhash'\n";
}

# Check if the stage0 (stage1?) builds
# are already complete
my $stageChecker = DidbsStageChecker->new( $scriptLocation,
					   $packageDir,
					   $buildDir,
					   $installDir );

if( !defined($buildshellpackage) && $stageChecker->stagesMissing() )
{
    $verbose && didbsprint "Needed stages are missing..\n";
    $stageChecker->callMissingStage();
    exit 0;
}
else
{
    # Only do this once per run of the script to keep things sane
    $verbose && didbsprint "Modifying current path for this stage..\n";
    $stageChecker->modifyPathForCurrentStage();
}

my $origpath = $ENV{"PATH"};
$ENV{"PATH"} = "$installDir/bin:$origpath";
my $origPkgCpath = $ENV{"PKG_CONFIG_PATH"};
$ENV{"PKG_CONFIG_PATH"} = "$pkgConfigPath/lib/pkgconfig:$origPkgCpath";
$ENV{"DIDBS_INSTALL_DIR"} = $installDir;
$ENV{"DIDBS_ISA"} = $didbsisa;
$ENV{"DIDBS_ISA_SWITCH"} = "-$didbsisa";

didbsprint "Modify the above in defaultenv.vars\n";
print"\n";

my $packageDefsDir = $stageChecker->getStageAdjustedPackageDefDir();

my $pkgDependencyEngine = DidbsDependencyEngine->new($verbose,
						     $scriptLocation,
						     $packageDefsDir,
						     $didbscompiler);

my $foundPackagesRef = $pkgDependencyEngine->listPackages();
my $p2pRef = $pkgDependencyEngine->getPackageMap();

my %pkgidToPackageMap = %{$p2pRef};

my $sapd = $stageChecker->getStageAdjustedPackageDir();
my $sabd = $stageChecker->getStageAdjustedBuildDir();
my $said = $stageChecker->getStageAdjustedInstallDir();
my $pathToStage0Root = $stageChecker->getPathToStage0Root();
$ENV{"STAGE0ROOT"}=$pathToStage0Root;

#didbsprint "packageDefsDir=$packageDefsDir\n";
#didbsprint "sapd=$sapd\n";
#didbsprint "pathToStage0Root=$pathToStage0Root\n";

# Fast quit for buildshell
if( $buildshellpackage )
{
    my $bsPackage = $pkgidToPackageMap{$buildshellpackage};
    if( $bsPackage == undef)
    {
	didbsprint "Couldn't find package $buildshellpackage.\n";
	exit -1;
    }
#    didbsprint "Would launch build shell of $buildshellpackage here.\n";
    my $curpkgshell = DidbsPackageShell->new( $scriptLocation,
					      $packageDefsDir,
					      $buildshellpackage,
					      $packageDir,
					      $sabd,
					      $said,
					      $pathToStage0Root,
					      $bsPackage );

    if( $verbose )
    {
	$curpkgshell->debug();
    }

    $curpkgshell->startshell();

    exit 0;
}

# Ensure our "didbsversions" directory exists
if( !$dryrun )
{
    my $didbsVersionsDir = "$installDir/didbsversions";
    if( ! -e $didbsVersionsDir ) {
	mkdirp("$didbsVersionsDir") || die "Unable to create versions dir: $!";
    }
}

my %foundPackageStates = ();

# Full tree build
didbsprint "Checking for outdated/missing packages...\n";
foreach $pkg (@{$foundPackagesRef})
{
    my $curpkg = ${$pkg};
    my $pkgid = $curpkg->{packageId};
    $verbose && didbsprint "Checking status of package '$pkgid'...\n";

    checkPackage( $didbsenvhash,
		  $pkg,
		  $scriptLocation,
		  $packageDefsDir,
		  $sapd,
		  $sabd,
		  $said,
		  $pathToStage0Root,
		  \$pkgDependencyEngine,
		  \%foundPackageStates );
}

didbsprint "Processed ".@{$foundPackagesRef}." packages.\n";

#if( $verbose )
#{
    my $dependenciesWriter = DidbsDependencyWriter->new($version,
							$scriptLocation,
							$foundPackagesRef,
							\%foundPackageStates);
    $dependenciesWriter->writeDependencies();
#}

exit 0;

sub checkPackage
{
    my( $didbsenvhash,
	$pkgRef,
	$scriptLocation,
	$packageDefsDir,
	$packageDir,
	$buildDir,
	$installDir,
	$pathToStage0Root,
	$pkgDependencyEngineRef,
	$foundPackageStatesRef ) = @_;

    my $pkg = ${$pkgRef};
    my $pkgDependencyEngine = ${$pkgDependencyEngineRef};

    my($packageId) = $pkg->{packageId};
    my($curpkg) = $pkg;

    my $curpkgstate = DidbsPackageState->new($verbose,
					     $scriptLocation,
					     $packageDefsDir,
					     $didbsenvhash,
					     $packageId,
					     $packageDir,
					     $buildDir,
					     $installDir,
					     $curpkg,
					     $foundPackageStatesRef );

#    didbsprint "$curpkg->{passesChecksIndicator} $stoponuntested\n";
    ${$foundPackageStatesRef}{$packageId} = $curpkgstate;
    $verbose && didbsprint "Set the package state for $packageId\n";

    my $pkgPci = $curpkg->{passesChecksIndicator};
    $verbose && didbsprint "Package pci=$pkgPci and sou=$stoponuntested\n";

    if( !$pkgPci && !$stoponuntested)
    {
	$verbose && didbsprint "Skipping untested package: $packageId\n";
	return;
    }

    if( $curpkgstate->getState() ne INSTALLED )
    {
	didbsprint "Checking status of package $packageId...\n";
	# Wait for a return
	#<STDIN>;

	my $curpkgextractor = DidbsExtractor->new( $scriptLocation,
						   $packageId,
						   $packageDir,
						   $buildDir,
						   $curpkg,
						   $curpkgstate);


	if( $verbose )
	{
	    $curpkgextractor->debug();
	}

	if( !$dryrun )
	{

	    if( !$curpkgextractor->extractionSuccess() )
	    {
		$verbose && didbsprint "Package extraction not complete.\n";
		if( !$curpkgextractor->extractit() )
		{
		    didbsprint "Unable to extract $curpkg->{packageId}\n";
		    exit -1;
		}
	    }
	}

	my $curpkgpatcher = undef;

	if( !$dryrun )
	{
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
		    didbsprint "Failed to patch $curpkg->{packageId}\n";
		    exit -1;
		}
		$curpkgextractor->setState(PATCHED);
	    }
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


	if( !$dryrun )
	{
	    if( !$curpkgconfigurator->configureit() )
	    {
		didbsprint "Failed during configure stage.\n";
		exit -1;
	    }
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

	if( !$dryrun )
	{
	    if( !$curpkgbuilder->buildit() )
	    {
		didbsprint "Failed during build step.\n";
		exit -1;
	    }
	}
	$verbose && didbsprint "Package $packageId complete.\n";

	if( $stoponuntested && !($curpkg->{passesChecksIndicator}) )
	{
	    didbsprint "This package ($packageId) is marked untested, please do the tests.\n";
	    # Only stop if we aren't dry running (pretend)
	    if( !$dryrun )
	    {
		exit 0;
	    }
	}

	my $curpkginstaller = DidbsInstaller->new( $scriptLocation,
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

	if( !$dryrun )
	{
	    if( !$curpkginstaller->installit() )
	    {
		didbsprint "Failed during install step.\n";
		exit -1;
	    }
	    $curpkgstate->setState(INSTALLED);
	}
	else
	{
	    didbsprint "  Package needs building...\n";
	    $curpkgstate->fakeNewInstalledDate();
	}
    }
}
