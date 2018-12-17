package DidbsPatcher;

use DidbsUtils;

use File::Copy qw/cp/;

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageDefsDir = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $buildDir = shift;
    my $didbsPackage = shift;
    my $didbsExtractor = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageDefsDir} = $packageDefsDir;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{didbsPackage} = $didbsPackage;
    $self->{didbsExtractor} = $didbsExtractor;

    return $self;
}

sub patchit
{
    my $self = shift;

    my $sl = $self->{scriptLocation};
    my $patchfn = $self->{didbsPackage}->{packagePatch};
    my $fullpathpatch = "$self->{packageDefsDir}/$self->{packageId}/$patchfn";
    my $patchdest = "$self->{buildDir}/$self->{packageId}";
    didbsprint "Copying patch file $fullpathpatch to $patchdest\n";
    cp($fullpathpatch,$patchdest) || die $!;

    my $patchcmd = "$sl/patchhelper.sh $patchdest $patchfn";
    didbsprint "patch command is $patchcmd\n";
    system($patchcmd) == 0 || die $!;

    return 1;
}

sub debug
{
    my $self = shift;
    didbsprint "DidbsPatcher constructed for $self->{packageId}\n";
}

1;
