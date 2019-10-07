package DidbsInstaller;

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
    my $didbsExtractor = shift;
    my $didbsPatcher = shift;
    my $didbsConfigurator = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageDefsDir} = $packageDefsDir;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{installDir} = $installDir;
    $self->{pathToStage0Root} = $pathToStage0Root;
    $self->{didbsPackage} = $didbsPackage;
    $self->{didbsExtractor} = $didbsExtractor;
    $self->{didbsPatcher} = $didbsPatcher;
    $self->{didbsConfigurator} = $didbsConfigurator;

    return $self;
}

sub installit
{
    my $self = shift;
    my $packageId = $self->{packageId};
    didbsprint "Installing $packageId\n";

    my $builddir = "$self->{buildDir}/$self->{packageId}/$self->{didbsPackage}->{packageDir}";
    my $installdir = $self->{installDir};
    didbsprint "Build is in $builddir\n";
    my $extraargs;
    if( begins_with($packageId,"stage1") )
    {
#	$extraargs=$self->{pathToStage0Root};
	$extraargs="/usr/didbs/current";
    }
    else
    {
	$extraargs="";
    }
    my $packageDefDir = $self->{packageDefsDir} . "/" . $packageId;
    didbsprint "Changing directory to $packageDefDir\n";
    chdir $packageDefDir;

    my $installRecipe = "$self->{packageDefsDir}/$self->{packageId}/$self->{didbsPackage}->{installRecipe}";
    my $cmd = "$installRecipe $builddir $installdir $extraargs";
    didbsprint "About to execute $cmd\n";
    system($cmd) == 0 || die $!;

    return 1;
}

sub debug
{
    my $self = shift;
    didbsprint "DidbsInstaller constructed for $self->{packageId}\n";
}

1;
