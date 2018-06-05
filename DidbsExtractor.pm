package DidbsExtractor;

use DidbsUtils;

# Contents set up from values from the dbibsPackage
#
# downloadSuccessFilePath
# 

use constant FETCHSTATE => qw(UNFETCHED FETCHED SIGCHECKED EXTRACTED);

#{
#    UNFETCHED   => 'Unfetched',
#    FETCHED     => 'Fetched',
#    SIGCHECKED  => 'SigChecked',
#    EXTRACTED   => 'Extracted',
#};

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $didbsPackage = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{didbsPackage} = $didbsPackage;

    $self->setupExtractionState();

    return $self;
}

sub setupExtractionState
{
    my $self = shift;
    $self->{extractionstate} = UNFETCHED;
}

sub extractionSuccess
{
    my $self = shift;

    return 0;
}

sub extractit
{
    my $self = shift;

    my $destdir = $self->{packageDir}."/srcballs";
    mkdirp($destdir);
    my $destfile = $self->{didbsPackage}->{packageFile};
    my $fulldestfile = $destdir."/".$destfile;

    if( $self->{extractionState} eq UNFETCHED )
    {
	my $destdir = $self->{packageDir}."/srcballs";
	mkdirp($destdir);
	my $destfile = $self->{didbsPackage}->{packageFile};
	my $fulldestfile = $destdir."/".$destfile;

	my $sourceurl = $self->{didbsPackage}->{packageSource};
	my $checksum = $self->{didbsPackage}->{packageChecksum};

	print "Package needs fetching from $sourceurl\n";
	my $fetchcmd = $self->{scriptLocation}."/curlhelper.sh $destdir $sourceurl";

	# If the file exists check the signature
	my $fileexistsgood = 0;
	if( -e $fulldestfile )
	{
	    if(!verifyChecksum($self,$fulldestfile,$checksum))
	    {
		print "Stale download at $fulldestfile.\n";
		print "Removing is commented out.\n";
		exit -1;
		unlink $fulldestfile;
	    }
	    else
	    {
		$fileexistsgood = 1;
	    }
	}

	if(!$fileexistsgood)
	{
	    print "Fetching...\n";
	    print "\n\n";

	    system($fetchcmd) ==0 || die $!;
	    $self->{extractionState} = FETCHED;
	    if(!verifyChecksum($self,$fulldestfile,$checksum))
	    {
		print "Second download attempt failed.\n";
		exit -1;
	    }
	}

	# File is good
	print "Checksum match.\n";
	$self->{extractionState} = SIGCHECKED;
    }

    if( $self->{extractionState} == SIGCHECKED )
    {
	my $extractdir = $self->{packageDir}."/".$self->{packageId};
	mkdirp( $extractdir );
	my $extractor = $self->{didbsPackage}->{packageExtraction};
	my $fullpathext = $self->{scriptLocation}."/".$extractor;
	print "Extracting to $extractdir using $fullpathext\n";
	my $cmd = "$fullpathext $extractdir $fulldestfile";
	print "Command is $cmd\n";
	system($cmd) == 0 || die $!;

	$self->{extractionState} = EXTRACTED;
    }

    return $self->{extractionState} == EXTRACTED;
}

sub verifyChecksum
{
    my $self=shift;
    my $filename=shift;
    my $checksum=shift;
#    print "Verifying checksum of $filename\n";
    
    my $calcchecksum = sha256file($filename);
    print "Expected($checksum) - received($calcchecksum)\n";

    return $calcchecksum eq $checksum;
}

sub debug
{
    my $self = shift;
    print "DibsExtractor constructed for $self->{packageId}\n";
}

1;
