package DidbsPackageState;

use DidbsUtils;

use constant PACKAGESTATE => qw(UNCHECKED UNFETCHED FETCHED SIGCHECKED EXTRACTED PATCHED CONFIGURED BUILT INSTALLED OUTOFDATE);

sub new
{
    my $self = bless {}, shift;
    my $verbose = shift;
    $self->{v} = $verbose;
    my $scriptLocation = shift;
    my $packageDefsDir = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $buildDir = shift;
    my $installDir = shift;
    my $didbsPackage = shift;
    my $foundPackageStatesRef = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{installDir} = $installDir;
    $self->{didbsPackage} = $didbsPackage;

    $self->{stateString} = UNCHECKED;

    my $packageDefFile = "$packageDefsDir/$packageId.packagedef";
    my $packageDefPath = "$packageDefsDir/$packageId";

    my $packageDefDate = lastModTimestampOfPackage(
	$packageDefPath, $packageDefFile );

    my $installedFile = "$buildDir/$packageId.installed";
    $self->{installedFileName} = $installedFile;

    my $installedDate = lastModTimestampOrZero( $installedFile );
    $self->{installedDate} = $installedDate;

    my $mostRecentDependencyDate = calculateMostRecentDependencyDate(
	$self,
	$didbsPackage,
	$installedDate,
	$foundPackageStatesRef );

    $self->{v} && didbsprint "Package def date is $packageDefDate\n";
    $self->{v} && didbsprint "Package installed date is $installedDate\n";
    $self->{v} && didbsprint "Package most recent dep date is $mostRecentDependencyDate\n";

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
    my @PKGFILES = `ls $pkgDefPath`;
    chomp(@PKGFILES);
    foreach $pkgHelperFile (@PKGFILES)
    {
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
	printf IFN "$self->{didbsPackage}->{packageDir}\n";
	close IFN;
	$self->{installedDate} = lastModTimestamp($installedFileName);
    }

}

sub getState
{
    my $self = shift;
    return $self->{stateString};
}

sub calculateMostRecentDependencyDate
{
    (my $self, $didbsPackage, $installedDate, $foundPackageStatesRef ) = (@_);

    $self->{v} && didbsprint "Looking for most recent dependency date for $didbsPackage->{packageId}\n";

    my @pkgDependencies = split(',',$didbsPackage->{dependenciesList});

    my $mostRecentDepDate = $installedDate;

    for $dep (@pkgDependencies)
    {
	my $depPkgState = ${$foundPackageStatesRef}{$dep};
	$self->{v} && didbsprint "For dep $dep have pkgstate ".
	    $depPkgState->getState()."\n";
	my $pkgDepDate = $depPkgState->{installedDate};
	if( $pkgDepDate gt $installedDate )
	{
	    $self->{v} && didbsprint "Dep $dep INCREASE of lmd to $pkgDepDate\n";
	    $installedDate = $pkgDepDate;
	}
    }

    return $installedDate;
}

1;
