package DidbsPackageState;

use constant PACKAGESTATE => qw(UNCHECKED UNFETCHED FETCHED SIGCHECKED EXTRACTED PATCHED CONFIGURED BUILT INSTALLED);

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
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

    my $packageDefFile = "$scriptLocation/packages/$packageId.packagedef";

    my $packageDefDate = lastModTimestamp( $packageDefFile );

    my $installedFile = "$buildDir/$packageId.installed";
    $self->{installedFileName} = $installedFile;

    my $installedDate = lastModTimestampOrZero( $installedFile );

    print "Package def date is $packageDefDate\n";
    print "Package installed date is $installedDate\n";

    if( $installedDate lt $packageDefDate )
    {
	$self->{stateString} = UNFETCHED;
    }
    else
    {
	print "Package $packageId is up to date.\n";
	$self->{stateString} = INSTALLED;
    }

    return $self;
}

sub lastModTimestamp
{
    ( my $fn ) = (@_);

    if( ! -e $fn )
    {
	print "Expected file $fn missing.\n";
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
    print "DidbsPackageState for $self->{packageId} is $self->{stateString}\n";
}

sub setState
{
    my $self = shift;
    my $newstate = shift;
    $self->{stateString} = $newstate;
    print "Package $self->{packageId} is now in state $newstate\n";

    if( $newstate eq INSTALLED )
    {
	my $installedFileName = $self->{installedFileName};
	print "Creating installed file: $installedFileName";
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
