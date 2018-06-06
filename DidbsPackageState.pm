package DidbsPackageState;

use constant PACKAGESTATE => qw(UNCHECKED UNFETCHED FETCHED SIGCHECKED EXTRACTED PATCHED CONFIGURED BUILT INSTALLED);

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $didbsPackage = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{didbsPackage} = $didbsPackage;

    $self->{packageState} = UNCHECKED;

    return $self;
}

sub debug
{
    my $self = shift;
    print "DidbsPackageState for $self->{packageId} is $self->{packageState}\n";
}

sub setState
{
    my $self = shift;
    my $newstate = shift;
    $self->{packageState} = $newstate;
    print "Package $self->{packageId} is now in state $newstate\n";
}

1;
