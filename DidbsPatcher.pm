package DidbsPatcher;

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

sub debug
{
    my $self = shift;
    print "DidbsPatcher constructed for $self->{packageId}\n";
}

1;
