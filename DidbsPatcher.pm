package DidbsPatcher;

use File::Copy qw/cp/;

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $didbsPackage = shift;
    my $didbsExtractor = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{didbsPackage} = $didbsPackage;
    $self->{didbsExtractor} = $didbsExtractor;

    return $self;
}

sub patchit
{
    my $self = shift;

    my $sl = $self->{scriptLocation};
    my $patchfn = $self->{didbsPackage}->{packagePatch};
    my $fullpathpatch = "$sl/packages/$patchfn";
    my $patchdest = "$self->{packageDir}/$self->{packageId}";
    print "Copying patch file $fullpathpatch to $patchdest\n";
    cp($fullpathpatch,$patchdest) || die $!;

    my $patchcmd = "$sl/patchhelper.sh $patchdest $patchfn";
    print "patch command is $patchcmd\n";
    system($patchcmd) == 0 || die $!;

    return 1;
}

sub debug
{
    my $self = shift;
    print "DidbsPatcher constructed for $self->{packageId}\n";
}

1;
