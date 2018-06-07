package DidbsConfigurator;

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $installDir = shift;
    my $didbsPackage = shift;
    my $didbsExtractor = shift;
    my $didbsPatcher = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
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

    my $builddir = "$self->{packageDir}/$self->{packageId}/$self->{didbsPackage}->{packageDir}";
    print "Would build in $builddir\n";
    my $prefix = $self->{installDir};
    my $extraargs = "";
    print "WARN missing args processing\n";

    my $confhelperfp = "$self->{scriptLocation}/configurehelper.sh";
    my $cmd = "$confhelperfp $builddir $prefix $extraargs";
    print "About to execute $cmd\n";
    exit-1;
    system($cmd) == 0 || die $!;

    return 1;
}

sub debug
{
    my $self = shift;
    print "DidbsConfigurator constructed for $self->{packageId}\n";
}

1;