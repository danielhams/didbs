package DidbsPackage;

use DidbsUtils;

# Contents read from packages/packageId.packagedef - contains:
#
# packageId
# packageSource (fetchable link for the package)
# packageFile (resulting file name after fetch)
# packageChecksum (a least a little signature check)
# packageExtraction (how to extract)
# packageDir (what directory gets created by extraction)
# packagePatch (patch to apply)
# expectedToolsList (can show which "sed" we use)
# dependenciesList (which other bootstrapped packages we depend on)
# envModifs (which env vars have to be set)
# configureRecipe (how to launch the configure step)
# buildRecipe (how to launch the build step)
# passesChecksIndicator (human set flag to warn when make check hasn't passed)

sub new
{
    my $self = bless {}, shift;
    my $packageId = shift;
    $self->{packageId} = $packageId;
    return $self;
}

sub debug
{
    my $self = shift;
    printf "DidbsPackage:          \t   ".$self->{packageId}."\n";
    printf " packageSource:        \t=> ".$self->{packageSource}."\n";
    printf " packageFile:          \t=> ".$self->{packageFile}."\n";
    printf " packageChecksum:      \t=> ".$self->{packageChecksum}."\n";
    printf " packageExtraction:    \t=> ".$self->{packageExtraction}."\n";
    printf " packageDir:           \t=> ".$self->{packageDir}."\n";
    printf " packagePatch:         \t=> ".$self->{packagePatch}."\n";
    printf " expectedToolList:     \t=> ".$self->{expectedToolList}."\n";
    printf " dependenciesList:     \t=> ".$self->{dependenciesList}."\n";
    printf " envModifs:            \t=> ".$self->{envModifs}."\n";
    printf " configureRecipe:      \t=> ".$self->{configureRecipe}."\n";
    printf " buildRecipe:          \t=> ".$self->{buildRecipe}."\n";
    printf " passesChecksIndicator:\t=> ".$self->{passesChecksIndicator}."\n";
    printf " sequenceNo:           \t=> ".$self->{sequenceNo}."\n";
}

sub readPackageDef
{
    my $self = shift;
    my $scriptLocation = shift;
    my $packageDefDir = shift;
    my $packageDef = $packageDefDir ."/".$self->{packageId}.".packagedef";
    if( !( -e $packageDef ) )
    {
	die "No such package definition: $packageDef\n";
    }
    printf "Reading from $packageDef\n";

    open PKG, "<".$packageDef || die $!;
    my @lines = <PKG>;
    close PKG;

    my %values;
    foreach (@lines) {
	chomp;
	s|#.+||;
	s|@(.+?)@|$1|g;
	s|\s||;
	my($key, $val) = split(/=/);
        $values{$key} = $val;
    }

    $self->{packageSource} = $values{"packageSource"};
    $self->{packageFile} = $values{"packageFile"};
    $self->{packageChecksum} = $values{"packageChecksum"};
    $self->{packageExtraction} = $values{"packageExtraction"};
    $self->{packageDir} = $values{"packageDir"};
    $self->{packagePatch} = $values{"packagePatch"};
    $self->{expectedToolList} = $values{"expectedToolList"};
    $self->{dependenciesList} = $values{"dependenciesList"};
    $self->{envModifs} = $values{"envModifs"};
    $self->{configureRecipe} = $values{"configureRecipe"};
    $self->{buildRecipe} = $values{"buildRecipe"};
    $self->{passesChecksIndicator} = $values{"passesChecksIndicator"};

}

1;
