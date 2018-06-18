#!/usr/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib ".";
use lib "$FindBin::Bin/lib";

# Packages specific to the tooling
use DidbsDependencyEngine;
use DidbsPackage;
use DidbsPackageState;
use DidbsExtractor;
use DidbsPatcher;
use DidbsConfigurator;
use DidbsBuilder;

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
    print("bootstrap.pl --packagedir /path/for/packages --buildir /path/forbuilding --installdir /path/for/install --verbose --stoponuntested\n");
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
           "stoponuntested" => \$stoponuntested )
    or usage(true);

if( !defined($packageDir) || !defined($buildDir) || !defined($installDir))
{
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

if( $clean )
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
my $origpath = $ENV{"PATH"};
$ENV{"PATH"} = "$installDir/bin:$origpath";
my $origPkgCpath = $ENV{"PKG_CONFIG_PATH"};
$ENV{"PKG_CONFIG_PATH"} = "$pkgConfigPath/lib/pkgconfig:$origPkgCpath";
$ENV{"DIDSB_INSTALL_DIR"} = $installDir;
print "Modify the above in defaultenv.vars\n";
print"\n";

my $packageDefsDir = "$scriptLocation/packages";

my $pkgDependencyEngine = DidbsDependencyEngine->new($scriptLocation,
						     $packageDefsDir );

my $foundPackagesRef = $pkgDependencyEngine->listPackages();

foreach $pkg (@{$foundPackagesRef})
{
    my $curpkg = ${$pkg};
    my $pkgid = $curpkg->{packageId};
    print "Checking package '$pkgid'...\n";

#    if( $pkgid eq "make" )
#    {
	doPackage( $pkg, $scriptLocation, $packageDir, $buildDir, $installDir );
#    }
}

exit 0;

sub doPackage
{
    my( $pkgRef, $scriptLocation, $packageDir, $buildDir, $installDir ) = @_;
    my $pkg = ${$pkgRef};

    my($packageId) = $pkg->{packageId};
    my($curpkg) = $pkg;

    my $curpkgstate = DidbsPackageState->new($scriptLocation,
					     $packageId,
					     $packageDir,
					     $buildDir,
					     $installDir,
					     $curpkg);

#    print "$curpkg->{passesChecksIndicator} $stoponuntested\n";

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
							 $packageId,
							 $packageDir,
							 $buildDir,
							 $installDir,
							 $curpkg,
							 $curpkgextractor,
							 $curpkgpatcher );


	if( !$curpkgconfigurator->configureit() )
	{
	    print "Failed during configure stage.\n";
	    exit -1;
	}

	my $curpkgbuilder = DidbsBuilder->new( $scriptLocation,
					       $packageId,
					       $packageDir,
					       $buildDir,
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
	print "Package $packageId complete.\n";

#	if( $stoponuntested && !($curpkg->{passesChecksIndicator}) )
#	{
#	    print "This package is marked untested, please do the tests.\n";
#	    exit 0;
#	}
#	else
#	{
	    $curpkgstate->setState(INSTALLED);
#	}
    }
}
