package DidbsDependencyEngine;

use DidbsUtils;

sub new
{
    my $self = bless{}, shift;
    my $verbose = shift;
    $self->{v} = $verbose;
    my $scriptLocation = shift;
    my $packageDefsDir = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageDefsDir} = $packageDefsDir;

    $self->findPackages();

    return $self;
}

sub findPackages
{
    my $self = shift;
    my $packageLocation = "$self->{packageDefsDir}";
    if( ! -e $packageLocation )
    {
	didbsprint "Unable to find packages at $packageLocation\n";
	exit 1;
    }
    didbsprint "Looking for packages in $packageLocation\n";

    my @FOUNDPKGS = `ls $packageLocation/*/*.packagedef`;
    chomp(@FOUNDPKGS);
    if( length(@FOUNDPKGS) == 0 )
    {
	didbsprint "Unable to find packages at $packageLocation\n";
	exit 1;
    }
#    didbsprint "Have @FOUNDPKGS\n";
    my @knownPackages = ();

    foreach $foundpkg (@FOUNDPKGS)
    {
	(my $pkgname = $foundpkg) =~ s/.*\/.+\/(\S+)\.packagedef.*/$1/;
	my $dpkg = DidbsPackage->new($self->{v},$pkgname);
	$dpkg->readPackageDef($self->{scriptLocation},
	    $packageLocation);
	$dpkg->debug();
	if( ! $dpkg->{disabled} )
	{
	    push(@knownPackages, \$dpkg);
	}
    }

    $self->{knownPackages} = \@knownPackages;

    my %pidToPackage = ();

    foreach $pkg (@{$self->{knownPackages}})
    {
	my $pkgid = ${$pkg}->{packageId};
#	didbsprint "DE - Have a package '$pkgid'\n";
	$pidToPackage{$pkgid} = $pkg;
    }

    $self->{pidToPackage} = \%pidToPackage;
    my %donePackages;

    $self->{v} && didbsprint "Working out dependencies and order....\n";
    my $orderedRef = flattenAndSortDeps( \@knownPackages, \%pidToPackage, \%donePackages );
    if( $self->{v} )
    {
	didbsprint "Package order as follows:\n";
	foreach $pkg (@{$orderedRef})
	{
	    my $curpkg = ${$pkg};
	    my $pkgid = $curpkg->{packageId};
	    my $sequenceNo = $curpkg->{sequenceNo};
	    didbsprint "Package: $pkgid => $sequenceNo\n";
	}
    }

    $self->{knownPackages} = $orderedRef;
}

sub listPackages
{
    my $self = shift;
    return $self->{knownPackages};
}

sub getPackageMap
{
    my $self = shift;
    return $self->{pidToPackage};
}

sub packageInResolutionStack
{
    my $pkgResolutionStackRef = shift;
    my $pkgId = shift;

    my %params = map { $_ => 1 } @{$pkgResolutionStackRef};

    return exists($params{$pkgId});
}

sub flattenAndSortDeps
{
    my $knownPkgsRef = shift;
    my $p2pRef = shift;
    my $donepRef = shift;

    # Set up deps
    for $pkgref (@{$knownPkgsRef})
    {
	my @pkgResolutionStack=();
	recursiveFlattenDeps( $pkgref,
			      $knownPkgsRef,
			      $p2pRef,
			      $donepRef,
			      $pkgref,
	                      \@pkgResolutionStack );

#	didbsprint "One done.\n";
#	foreach $pkgid (keys %{$donepRef})
#	{
#	    didbsprint "Done package: $pkgid\n";
#	}
    }

    # Sort (first on seq no, then on package ID)
    my @ordered = sort {
	${$a}->{sequenceNo} <=> ${$b}->{sequenceNo}
	||
	${$a}->{packageId} cmp ${$b}->{packageId}
    } @{$knownPkgsRef};

    # If having problem with dependency ordering
    # Uncomment this stuff to see what order is being used.
#    didbsprint "Sorted packages:\n";
#    foreach $sortedpkgref (@ordered)
#    {
#	my $pkg = ${$sortedpkgref};
#	didbsprint "Seq: $pkg->{sequenceNo}\t:\t $pkg->{packageId} \n";
#    }
#    exit;

    return \@ordered;
}

sub recursiveFlattenDeps
{
    my $drivingPkgRef = shift;
    my $knownPkgsRef = shift;
    my $p2pRef = shift;
    my $donepRef = shift;
    my $curpkgRef = shift;
    my $pkgResolutionStackRef = shift;

    my @knownPackages = @{$knownPkgsRef};
    my %pidToPackage = %{$p2pRef};
    my %donePackages = %{$donepRef};
    my $curPkg = ${$curpkgRef};

    my $curPkgId = $curPkg->{packageId};
#    didbsprint "RecursiveFlattenDeps of $curPkgId\n";

    # Check if already handled
    if( ${$donepRef}{$curPkgId} ne "" )
    {
#	didbsprint "Package $curPkgId is already complete.\n";
	return $curPkg->{sequenceNo};
    }

    # Check if package is already in the resolution stack
    # which means circular dependencies somewhere
    if( packageInResolutionStack( $pkgResolutionStackRef,
				  $curPkgId ) )
    {
	didbsprint "Dependency cycle detected with driving pkg: ".
	    ${$drivingPkgRef}->{packageId} . "!\n";
	foreach $deppkgid (@{$pkgResolutionStackRef})
	{
	    didbsprint "Pkgid: $deppkgid\n";
	}
	exit 1;
    }
    push @{$pkgResolutionStackRef}, $curPkgId;
    
    # For each dependency, find and add their dependencies
    my $deps = $curPkg->{dependenciesList};

#    didbsprint "For package $curPkgId dependencies are $deps\n";

    my @depIds = split(',',$deps);
    my $sequenceNo = 0;

    foreach $depId (@depIds)
    {
	my $depRef = ${$p2pRef}{$depId};
	if( !defined($depRef) )
	{
	    didbsprint "Missing dependency: $depId for $curPkgId\n";
	    exit 1;
	}
	my $childSeqNo = recursiveFlattenDeps( $drivingPkgRef,
					       $knownPkgsRef,
					       $p2pRef,
					       $donepRef,
					       $depRef,
					       $pkgResolutionStackRef );

	my $tmpSeqNo = $childSeqNo + 1;

	if( $tmpSeqNo > $sequenceNo )
	{
	    $sequenceNo = $tmpSeqNo;
	}
    }

    $curPkg->{sequenceNo} = $sequenceNo;

    ${$donepRef}{$curPkgId} = "done";
    ${$pkgsInCurrentResolveRef}{$curPkgId} = "done";
#    didbsprint "Setting package $curPkgId as done\n";
    pop @{$pkgResolutionStackRef};

    return $curPkg->{sequenceNo};
}

1;
