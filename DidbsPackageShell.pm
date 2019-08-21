package DidbsPackageShell;

use DidbsUtils;

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageDefsDir = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $buildDir = shift;
    my $installDir = shift;
    my $pathToStage0Root = shift;
    my $didbsPackage = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageDefsDir} = $packageDefsDir;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{installDir} = $installDir;
    $self->{pathToStage0Root} = $pathToStage0Root;
    $self->{didbsPackage} = $didbsPackage;

    return $self;
}

sub debug
{
    my $self = shift;
    didbsprint "DidbsPackageShell constructed for $self->{packageId}\n";
    didbsprint "scriptLocation $self->{scriptLocation}\n";
    didbsprint "packageDefsDir $self->{packageDefsDir}\n";
    didbsprint "packageId $self->{packageId}\n";
    didbsprint "packageDir $self->{packageDir}\n";
    didbsprint "buildDir $self->{buildDir}\n";
    didbsprint "installDir $self->{installDir}\n";
    didbsprint "pathToStage0Root $self->{pathToStage0Root}\n";
    didbsprint "didbsPackage $self->{didbsPackage}\n";
}

sub startshell
{
    my $self = shift;
    my $packageId = $self->{packageId};
    didbsprint "Package shell for $packageId\n";

    my $scriptLocation = $self->{scriptLocation};
    my $packageId = $self->{packageId};
    my $packageDirRoot = $self->{packageDir};
    my $didbsPackageDir = ${$self->{didbsPackage}}->{packageDir};
    my $packageDefsDir = $self->{packageDefsDir};
    my $packageDir = $packageDefsDir . "/" . $packageId;
    my $builddir = $self->{buildDir};
    my $packageBuildDir =
	$builddir .
	"/" .
	$packageId .
	"/" .
	$didbsPackageDir;

    my $installdir = $self->{installDir};

    my $envmodifs = $packageDir . "/" .
	${$self->{didbsPackage}}->{envModifs};
    didbsprint "scriptLocation is $scriptLocation\n";
    didbsprint "packageId is $packageId\n";
    didbsprint "packageDir is $packageDir\n";
    didbsprint "packageBuildDir is $packageBuildDir\n";
    didbsprint "didbsPackageDir is $didbsPackageDir\n";
    didbsprint "builddir is $builddir\n";
    didbsprint "installdir is $installdir\n";

    # Need
    # script path
    # root of didbs (scriptLocation)
    # packageID
    # path to dibs package config
    # path to root of package build
    # install path

    my $cmd = "$scriptLocation/scripts/buildshell.sh $scriptLocation $packageId $packageDir $packageBuildDir $installdir $envmodifs";
#    didbsprint "About to execute $cmd\n";
    if( system($cmd) != 0 )
    {
	didbsprint "Failed during shell invocation: $!\n";
	die $!;
    }

    return 1;
}

1;
