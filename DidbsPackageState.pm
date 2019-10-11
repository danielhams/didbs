package DidbsPackageState;

use File::Basename;

use DidbsUtils;
use DidbsPackageHasher;

use constant PACKAGESTATE => qw(UNCHECKED UNFETCHED FETCHED SIGCHECKED EXTRACTED PATCHED CONFIGURED BUILT INSTALLED OUTOFDATE);

my($useHashes)=1;

sub new
{
    my $self = bless {}, shift;
    my $verbose = shift;
    $self->{v} = $verbose;
    my $scriptLocation = shift;
    my $packageDefsDir = shift;
    my $didbsEnvHash = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $buildDir = shift;
    my $installDir = shift;
    my $didbsPackage = shift;
    my $foundPackageStatesRef = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{didbsEnvHash} = $didbsEnvHash;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{installDir} = $installDir;
    $self->{didbsPackage} = $didbsPackage;

    $self->{stateString} = UNCHECKED;

    my $packageDefPath = "$packageDefsDir/$packageId";
    my $packageDefFile = "$packageDefPath/$packageId.packagedef";

    my $packageDefDate = lastModTimestampOfPackage(
	$packageDefPath, $packageDefFile );

    my $installedFile = "$installDir/didbsversions/$packageId.installed";
    $self->{installedFileName} = $installedFile;

    my $installedDate = lastModTimestampOrZero( $installedFile );
    $self->{installedDate} = $installedDate;

    my $packageDefHash = DidbsPackageHasher::calculatePackageDefHash( $self->{v}, $packageDefPath );
    $self->{packageDefHash} = $packageDefHash;
    # Now build the "envPacDepHash" (environment, package, dependencies)
    # If this matches the value stored on the disk, this package is up
    # to date.
    # If it doesn't match, this package needs building.
    my @dependencyHashes = calculateDependencyHashes(
	$self,
	$didbsPackage,
	$foundPackageStatesRef );

#    for( @dependencyHashes )
#    {
#	print "Found a dependency hash: $_\n";
#	exit 1;
#    }
    my $envPacDepHash = DidbsPackageHasher::calculateEnvPacDepHash(
	$didbsEnvHash,
	$packageDefHash,
	\@dependencyHashes );

    $self->{envPacDepHash} = $envPacDepHash;

    my $mostRecentDependencyDate = calculateMostRecentDependencyDate(
	$self,
	$didbsPackage,
	$installedDate,
	$foundPackageStatesRef );

    (!$useHashes) && $self->{v} && didbsprint "Package def date is $packageDefDate\n";
    $self->{v} && didbsprint "Package def hash is $packageDefHash\n";
    $self->{v} && didbsprint "Package epdh     is $envPacDepHash\n";
    (!$useHashes) && $self->{v} && didbsprint "Package installed date is $installedDate\n";
    (!$useHashes) && $self->{v} && didbsprint "Package most recent dep date is $mostRecentDependencyDate\n";

    if( $useHashes ) {
	if (! -e $installedFile) {
	    $self->{v} && didbsprint "Package $packageId not yet installed.\n";
	    $self->{stateString} = UNFETCHED;
	}
	else {
	    my $installedEnvPacDepHash = readHashFromInstalledFile($installedFile);
#	    print "Read installed envpacdephash of $installedEnvPacDepHash\n";
	    if( $installedEnvPacDepHash eq $envPacDepHash ) {
		$self->{v} && didbsprint "Package $packageId is up to date.\n";
		$self->{stateString} = INSTALLED;
	    }
	    else {
		$self->{v} && didbsprint "Package $packageId out of date.\n";
		$self->{stateString} = OUTOFDATE;
	    }
	}
    }
    else {
	if( $installedDate == 0 )
	{
	    $self->{v} && didbsprint "Package $packageId not yet installed.\n";
	    $self->{stateString} = UNFETCHED;
	}
	elsif( $installedDate lt $packageDefDate ||
	       $installedDate lt $mostRecentDependencyDate )
	{
	    $self->{v} && didbsprint "Package $packageId out of date.\n";
	    $self->{stateString} = OUTOFDATE;
	}
	else
	{
	    $self->{v} && didbsprint "Package $packageId is up to date.\n";
	    $self->{stateString} = INSTALLED;
	}
    }

#    print "State is $self->{stateString}\n";
#    exit;

    return $self;
}

sub lastModTimestamp
{
    ( my $fn ) = (@_);

    if( ! -e $fn )
    {
	didbsprint "Expected file $fn missing.\n";
	exit 1;
    }

    return (stat($fn))[9];
}

sub lastModTimestampOrZero
{
    ( my $fn ) = (@_);

    if( ! -e $fn )
    {
	return 0;
    }

    return lastModTimestamp( $fn );
}

sub lastModTimestampOfPackage
{
    (my $pkgDefPath, $pkgDefFile ) = (@_);
    my $newestLastModTimestamp = lastModTimestamp($pkgDefFile);
    $self->{v} && didbsprint "For $pkgDefFile lmt = $newestLastModTimestamp\n";

    # Walk all files under the package def path
    # Checking if any are newer
    # Glob is _slightly_ quicker, and saves a fork/exec, too
#    my @PKGFILES = `ls $pkgDefPath`;
    my @PKGFILES = glob "$pkgDefPath/*";
    chomp(@PKGFILES);

    foreach $fullPathPkgHelperFile (@PKGFILES)
    {
	my $pkgHelperFile = basename($fullPathPkgHelperFile);
	my $pkgHelperLmt = lastModTimestamp($pkgDefPath."/".$pkgHelperFile);
	$self->{v} && didbsprint "For helper file $pkgHelperFile lmt = $pkgHelperLmt\n";
	if( $pkgHelperLmt gt $newestLastModTimestamp )
	{
	    $newestLastModTimestamp = $pkgHelperLmt;
	    $self->{v} && didbsprint "Helper file $pkgHelperFile is NEWER ($pkgHelperLmt).\n";
	}
    }
    $self->{v} && didbsprint "For $pkgDefFile returning $newestLastModTimestamp\n";

    return $newestLastModTimestamp;
}

sub debug
{
    my $self = shift;
    didbsprint "DidbsPackageState for $self->{packageId} is $self->{stateString}\n";
}

sub setState
{
    my $self = shift;
    my $newstate = shift;
    $self->{stateString} = $newstate;
    didbsprint "Package $self->{packageId} is now in state $newstate\n";

    if( $newstate eq INSTALLED )
    {
	my $installedFileName = $self->{installedFileName};
	didbsprint "Creating installed file: $installedFileName\n";
	open IFN, ">$installedFileName" || die $!;
	printf IFN "$self->{envPacDepHash}\n";
	close IFN;
	$self->{installedDate} = lastModTimestamp($installedFileName);
    }

}

sub fakeNewInstalledDate
{
    my $self = shift;
    $self->{stateString} = INSTALLED;
    $self->{installedDate} = time();
    (!$useHashes) && $self->{v} &&
	didbsprint "Fake set new installed date to " .
	$self->{installedDate} . "\n";
}

sub getState
{
    my $self = shift;
    return $self->{stateString};
}

sub calculateMostRecentDependencyDate
{
    (my $self, $didbsPackage, $installedDate, $foundPackageStatesRef ) = (@_);

    (!$useHashes) && $self->{v} && didbsprint "Looking for most recent dependency date for $didbsPackage->{packageId}\n";

    my @pkgDependencies = split(',',$didbsPackage->{dependenciesList});

    my $mostRecentDepDate = $installedDate;

    for $dep (@pkgDependencies)
    {
	my $depPkgState = ${$foundPackageStatesRef}{$dep};
	(!$useHashes) && $self->{v} && didbsprint "For dep $dep have pkgstate ".
	    $depPkgState->getState()."\n";
	my $pkgDepDate = $depPkgState->{installedDate};
	if( $pkgDepDate gt $installedDate )
	{
	    (!$useHashes) && $self->{v} && didbsprint "Dep $dep INCREASE of lmd to $pkgDepDate\n";
	    $installedDate = $pkgDepDate;
	}
    }

    return $installedDate;
}
sub calculateDependencyHashes
{
    (my $self, $didbsPackage, $foundPackageStatesRef ) = (@_);

    $self->{v} && didbsprint "Looking for dependency hashes for $didbsPackage->{packageId}\n";

    my @pkgDependencies = split(',',$didbsPackage->{dependenciesList});

    my $mostRecentDepDate = $installedDate;

    my @dependencyHashes = ();

    for $dep (@pkgDependencies)
    {
	my $depPkgState = ${$foundPackageStatesRef}{$dep};
	$self->{v} && didbsprint "For dep $dep have pkgstate ".
	    $depPkgState->getState()."\n";
	my $pkgEnvPacDepHash = $depPkgState->{envPacDepHash};
	push @dependencyHashes, $pkgEnvPacDepHash;
#	print "Have a dep hash: " . $pkgEnvPacDepHash . "\n";
#	exit;
    }

    return @dependencyHashes;
}

sub readHashFromInstalledFile {
    my( $filename ) = (@_);

    my $contents = do{local(@ARGV,$/)=$filename;<>};
    chomp($contents);
    return $contents;
}

1;
