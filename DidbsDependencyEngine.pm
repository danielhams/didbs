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
    print "Looking for packages in $packageLocation\n";

    my @FOUNDPKGS = `ls $packageLocation/*.packagedef`;
    chomp(@FOUNDPKGS);
    print "Have @FOUNDPKGS\n";
    my @tmpPackages = ();

    foreach $foundpkg (@FOUNDPKGS)
    {
	(my $pkgname = $foundpkg) =~ s/.*\/(\S+)\.packagedef.*/$1/;
	my $dpkg = DidbsPackage->new($pkgname);
	$dpkg->readPackageDef($self->{scriptLocation});
	$dpkg->debug();
	push(@tmpPackages, \$dpkg);
    }

    $self->{knownPackages} = \@tmpPackages;

    foreach $pkg (@{$self->{knownPackages}})
    {
	my $pkgid = ${$pkg}->{packageId};
	print "DE - Have a package '$pkgid'\n";
    }

}

sub listPackages
{
    my $self = shift;

    return $self->{knownPackages};
}


1;
