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

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{installDir} = $installDir;
    $self->{didbsPackage} = $didbsPackage;

    $self->{stateString} = UNCHECKED;

    my $packageDefFile = "$packageDefsDir/$packageId.packagedef";

    my $packageDefDate = lastModTimestamp( $packageDefFile );

    my $installedFile = "$buildDir/$packageId.installed";
    $self->{installedFileName} = $installedFile;

    my $installedDate = lastModTimestampOrZero( $installedFile );

    $self->{v} && didbsprint "Package def date is $packageDefDate\n";
    $self->{v} && didbsprint "Package installed date is $installedDate\n";

    if( $installedDate == 0 )
    {
	didbsprint "Package $packageId not yet installed.\n";
	$self->{stateString} = UNFETCHED;
    }
    elsif( $installedDate lt $packageDefDate )
    {
	didbsprint "Package $packageId out of date.\n";
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
    }

}

sub getState
{
    my $self = shift;
    return $self->{stateString};
}
1;
