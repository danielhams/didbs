package DidbsDependencyEngine;

sub new
{
    my $self = bless{}, shift;
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
	print "Unable to find packages at $packageLocation\n";
	exit 1;
    }
    print "Looking for packages in $packageLocation\n";

    my @FOUNDPKGS = `ls $packageLocation/*.packagedef`;
    chomp(@FOUNDPKGS);
    if( length(@FOUNDPKGS) == 0 )
    {
	print "Unable to find packages at $packageLocation\n";
	exit 1;
    }
#    print "Have @FOUNDPKGS\n";
    my @knownPackages = ();

    foreach $foundpkg (@FOUNDPKGS)
    {
	(my $pkgname = $foundpkg) =~ s/.*\/(\S+)\.packagedef.*/$1/;
	my $dpkg = DidbsPackage->new($pkgname);
	$dpkg->readPackageDef($self->{scriptLocation},
	    $packageLocation);
	$dpkg->debug();
	push(@knownPackages, \$dpkg);
    }

    $self->{knownPackages} = \@knownPackages;

    my %pidToPackage = {};

    foreach $pkg (@{$self->{knownPackages}})
    {
	my $pkgid = ${$pkg}->{packageId};
	print "DE - Have a package '$pkgid'\n";
	$pidToPackage{$pkgid} = $pkg;
    }
    my %donePackages;

    print "Working out dependencies and order....\n";
    my $orderedRef = flattenAndSortDeps( \@knownPackages, \%pidToPackage, \%donePackages );
    print "Package order now know....\n";

    $self->{knownPackages} = $orderedRef;
}

sub listPackages
{
    my $self = shift;

    return $self->{knownPackages};
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

#	print "One done.\n";
#	foreach $pkgid (keys %{$donepRef})
#	{
#	    print "Done package: $pkgid\n";
#	}
    }

    # Sort
    my @ordered = sort { ${$a}->{sequenceNo} cmp ${$b}->{sequenceNo}} @{$knownPkgsRef};

    print "Sorted packages:\n";
    foreach $sortedpkgref (@ordered)
    {
	my $pkg = ${$sortedpkgref};
	$pkg->debug();
    }

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
    print "RecursiveFlattenDeps of $curPkgId\n";

    # Check if already handled
    if( ${$donepRef}{$curPkgId} ne "" )
    {
	print "Package $curPkgId is already complete.\n";
	return $curPkg->{sequenceNo};
    }

    # Check if package is already in the resolution stack
    # which means circular dependencies somewhere
    if( packageInResolutionStack( $pkgResolutionStackRef,
				  $curPkgId ) )
    {
	print "Dependency cycle detected with driving pkg: ".
	    ${$drivingPkgRef}->{packageId} . "!\n";
	foreach $deppkgid (@{$pkgResolutionStackRef})
	{
	    print "Pkgid: $deppkgid\n";
	}
	exit 1;
    }
    push @{$pkgResolutionStackRef}, $curPkgId;
    
    # For each dependency, find and add their dependencies
    my $deps = $curPkg->{dependenciesList};

    print "For package $curPkgId dependencies are $deps\n";

    my @depIds = split(',',$deps);
    my $sequenceNo = 0;

    foreach $depId (@depIds)
    {
	my $depRef = ${$p2pRef}{$depId};
	if( !defined($depRef) )
	{
	    print "Missing dependency: $depId for $curPkgId\n";
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
    print "Setting package $curPkgId as done\n";
    pop @{$pkgResolutionStackRef};

    return $curPkg->{sequenceNo};
}

1;
