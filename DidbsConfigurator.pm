package DidbsConfigurator;

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
    my $didbsPackage = shift;
    my $didbsExtractor = shift;
    my $didbsPatcher = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageDefsDir} = $packageDefsDir;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{installDir} = $installDir;
    $self->{didbsPackage} = $didbsPackage;
    $self->{didbsExtractor} = $didbsExtractor;
    $self->{didbsPatcher} = $didbsPatcher;

    return $self;
}

sub configureit
{
    my $self = shift;
    my $packageId = $self->{packageId};
    didbsprint "Configuring $packageId\n";

    my $builddir = "$self->{buildDir}/$packageId/$self->{didbsPackage}->{packageDir}";
    didbsprint "Would configure in $builddir\n";
    my $installdir = $self->{installDir};
    my $extraargs;
    didbsprint "Checking if $packageId begins with stage1.\n";
    if( begins_with($packageId,"stage1") )
    {
	$extraargs="/usr/didbs/current";
    }
    else
    {
	$extraargs=$self->{scriptLocation};
    }
    my $packageDefDir = $self->{packageDefsDir} . "/" . $packageId;
    didbsprint "Changing directory to $packageDefDir\n";
    chdir $packageDefDir;

    my $configureRecipe = "$self->{packageDefsDir}/$packageId/$self->{didbsPackage}->{configureRecipe}";
    my $cmd = "$configureRecipe $builddir $installdir $extraargs";
    didbsprint "About to execute $cmd\n";
    system($cmd) == 0 || die $!;

    return 1;
}

sub debug
{
    my $self = shift;
    didbsprint "DidbsConfigurator constructed for $self->{packageId}\n";
}

1;
