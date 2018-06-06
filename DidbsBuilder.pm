package DidbsBuilder;

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $didbsPackage = shift;
    my $didbsExtractor = shift;
    my $didbsPatcher = shift;
    my $didbsConfigurator = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{didbsPackage} = $didbsPackage;
    $self->{didbsExtractor} = $didbsExtractor;
    $self->{didbsPatcher} = $didbsPatcher;
    $self->{didbsConfigurator} = $didbsConfigurator;

    return $self;
}

sub buildit
{
    my $self = shift;
    print "Building $self->{packageId}\n";

    return 1;
}

sub debug
{
    my $self = shift;
    print "DidbsBuilder constructed for $self->{packageId}\n";
}

1;
