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
    didbsprint "Building $packageId\n";

    my $builddir = "$self->{buildDir}/$self->{packageId}/$self->{didbsPackage}->{packageDir}";
    my $installdir = $self->{installDir};
    didbsprint "Would build in $builddir\n";
    my $extraargs;
    if( begins_with($packageId,"stage1") )
    {
	$extraargs="/usr/didbs/current";
    }
    else
    {
	$extraargs="";
    }
    my $packageDefDir = $self->{packageDefsDir} . "/" . $packageId;
    didbsprint "Changing directory to $packageDefDir\n";
    chdir $packageDefDir;

    my $buildRecipe = "$self->{packageDefsDir}/$self->{packageId}/$self->{didbsPackage}->{buildRecipe}";
    my $cmd = "$buildRecipe $builddir $installdir $extraargs";
    didbsprint "About to execute $cmd\n";
    if( system($cmd) != 0 )
    {
	didbsprint "Failed during build: $!\n";
	die $!;
    }

    return 1;
}

sub debug
{
    my $self = shift;
    didbsprint "DidbsBuilder constructed for $self->{packageId}\n";
}

1;
