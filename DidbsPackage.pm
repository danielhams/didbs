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
    my $verbose = shift;
    $self->{v} = $verbose;
    my $packageId = shift;
    $self->{packageId} = $packageId;
    return $self;
}

sub debug
{
    my $self = shift;
    if( $self->{v} )
    {
	didbsprint "DidbsPackage:          \t   ".$self->{packageId}."\n";
	didbsprint " packageSource:        \t=> ".$self->{packageSource}."\n";
	didbsprint " packageFile:          \t=> ".$self->{packageFile}."\n";
	didbsprint " packageChecksum:      \t=> ".$self->{packageChecksum}."\n";
	didbsprint " packageExtraction:    \t=> ".$self->{packageExtraction}."\n";
	didbsprint " packageDir:           \t=> ".$self->{packageDir}."\n";
	didbsprint " packagePatch:         \t=> ".$self->{packagePatch}."\n";
	didbsprint " expectedToolList:     \t=> ".$self->{expectedToolList}."\n";
	didbsprint " dependenciesList:     \t=> ".$self->{dependenciesList}."\n";
	didbsprint " envModifs:            \t=> ".$self->{envModifs}."\n";
	didbsprint " configureRecipe:      \t=> ".$self->{configureRecipe}."\n";
	didbsprint " buildRecipe:          \t=> ".$self->{buildRecipe}."\n";
	didbsprint " installRecipe:        \t=> ".$self->{installRecipe}."\n";
	didbsprint " passesChecksIndicator:\t=> ".$self->{passesChecksIndicator}."\n";
	didbsprint " sequenceNo:           \t=> ".$self->{sequenceNo}."\n";
    }
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
    $verbose && didbsprint "Reading from $packageDef\n";

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
    $self->{installRecipe} = $values{"installRecipe"};
    $self->{passesChecksIndicator} = $values{"passesChecksIndicator"};

    if( length($self->{configureRecipe}) == 0
	||
	length($self->{buildRecipe}) == 0
	||
	length($self->{installRecipe}) == 0 )
    {
	die "configureRecipe, buildRecipe, installRecipe must be filled for $packageDef.";
    }
}

1;
