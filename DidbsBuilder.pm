package DidbsBuilder;

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

sub buildit
{
    my $self = shift;
    my $packageId = $self->{packageId};
    print "Building $packageId\n";

    my $builddir = "$self->{buildDir}/$self->{packageId}/$self->{didbsPackage}->{packageDir}";
    my $installdir = $self->{installDir};
    print "Would build in $builddir\n";
    my $extraargs;
    if( begins_with($packageId,"stage1") )
    {
	$extraargs=$self->{pathToStage0Root};
    }
    else
    {
	$extraargs="";
    }

    my $buildRecipe = "$self->{packageDefsDir}/$self->{packageId}/$self->{didbsPackage}->{buildRecipe}";
    my $cmd = "$buildRecipe $builddir $installdir $extraargs";
#    print "About to execute $cmd\n";
    system($cmd) == 0 || die $!;

    return 1;
}

sub debug
{
    my $self = shift;
    print "DidbsBuilder constructed for $self->{packageId}\n";
}

1;
