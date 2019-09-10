package DidbsDependencyWriter;

use DidbsUtils;

sub new
{
    my $self = bless {}, shift;
    my $version = shift;
    my $scriptLocation = shift;
    my $foundPackagesRef = shift;
    my $packageStatesRef = shift;

    $self->{version} = $version;
    $self->{scriptLocation} = $scriptLocation;
    $self->{foundPackagesRef} = $foundPackagesRef;
    $self->{packageStatesRef} = $packageStatesRef;

    return $self;
}

sub writeDependencies
{
    my $self = shift;
    didbsprint "Writing dependency .dot and .csv\n";

    @foundPackages = @{$self->{foundPackagesRef}};
    %pkgStates = %{$self->{packageStatesRef}};

    # filter pass
    @filteredPackages =();

    %depsToIgnore = {};
    $depsToIgnore{"make"} = 1;
    $depsToIgnore{"tar"} = 1;
    $depsToIgnore{"bzip"} = 1;
    $depsToIgnore{"xz"} = 1;
    $depsToIgnore{"gzip"} = 1;

    foreach $pkgRef (@foundPackages)
    {
	my $pkg = ${$pkgRef};
	my $packageId = $pkg->{packageId};
	my $dependencies = $pkg->{dependenciesList};
	my $packageState = $pkgStates{$packageId};

	my @depIds = split(',',$dependencies);
	my $replDeps = "";
	foreach $depId (@depIds)
	{
	    if( 
		rindex($depId,"stage1",0) == -1 &&
		!defined($depsToIgnore{$depId})
	      )
	    {
		if( length($replDeps) > 0 )
		{
		    $replDeps = $replDeps . ",";
		}
		$replDeps = $replDeps . $depId;
	    }
	}
	$pkg->{dependenciesList} = $replDeps;
	if( rindex($packageId, "stage1",0) == -1 )
	{
	    push @filteredPackages, $pkgRef;
	}
    }

    open(DOT_OUT, '>'.$self->{scriptLocation}."/deps.dot") || die $!;
    my $didbsversion = $self->{version};
    printf DOT_OUT <<EOF_HEADER;
    strict digraph didbs_deps {
    graph [ ratio="0.7 compressed",
        rankdir="RL",
        ranksep=0.75,
        concentrate="false",
        remincross="true",
        fontname=helvetica
        fontsize=8
        ];
    node [ shape=box,
        style=filled,
        fillcolor=white,
        fontname=helvetica
        fontsize=8,
        fontcolor=black
        ];
    edge [
        ];

    subgraph "cluster_didbs" {
        label="Didbs $didbsversion";
        style=filled;
        color=ivory3;
EOF_HEADER
    foreach $pkgRef (@filteredPackages)
    {
	my $pkg = ${$pkgRef};
	my $packageId = $pkg->{packageId};
	my $dependencies = $pkg->{dependenciesList};
	my $packageState = $pkgStates{$packageId};

	printf DOT_OUT "\"$packageId\";\n";
	my @depIds = split(',',$dependencies);
	foreach $depId (@depIds)
	{
	    printf DOT_OUT "\"$packageId\" -> \"$depId\"\n";
	}
    }
    printf DOT_OUT <<EOF_FOOTER;
    }
}
EOF_FOOTER
    close(DOT_OUT);

    open(CSV_OUT, '>'.$self->{scriptLocation}."/deps.csv") || die $!;
    foreach $pkgRef (@filteredPackages)
    {
	my $pkg = ${$pkgRef};
	my $packageId = $pkg->{packageId};
	my $dependencies = $pkg->{dependenciesList};
	my $packageState = $pkgStates{$packageId};

	printf CSV_OUT "$packageId";
	my @depIds = split(',',$dependencies);
	foreach $depId (@depIds)
	{
	    printf CSV_OUT ",$depId";
	}
	printf CSV_OUT "\n";
    }
    close(CSV_OUT);
}

1;
