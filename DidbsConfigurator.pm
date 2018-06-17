package DidbsConfigurator;

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $buildDir = shift;
    my $installDir = shift;
    my $didbsPackage = shift;
    my $didbsExtractor = shift;
    my $didbsPatcher = shift;

    $self->{scriptLocation} = $scriptLocation;
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
    print "Configuring $self->{packageId}\n";

    my $builddir = "$self->{buildDir}/$self->{packageId}/$self->{didbsPackage}->{packageDir}";
    print "Would configure in $builddir\n";
    my $installdir = $self->{installDir};
    my $extraargs = "";
    print "WARN missing args processing\n";

    my $configureRecipe = "$self->{scriptLocation}/packages/$self->{packageId}/$self->{didbsPackage}->{configureRecipe}";
    my $cmd = "$configureRecipe $builddir $installdir $extraargs";
    print "About to execute $cmd\n";
    system($cmd) == 0 || die $!;

    return 1;
}

sub debug
{
    my $self = shift;
    print "DidbsConfigurator constructed for $self->{packageId}\n";
}

1;
