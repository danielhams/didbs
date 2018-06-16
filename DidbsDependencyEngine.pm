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

    my @tmpPackages = {};

    $self->{knownPackages} = @tmpPackages;
}

sub listPackages
{
    my $self = shift;

    return \($self->{knownPackages});
}


1;
