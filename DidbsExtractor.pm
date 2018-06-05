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
    my $scriptlocation = shift;
    my $packageId = shift;
    my $packagedir = shift;
    my $didbspackage = shift;

    $self->{scriptlocation} = $scriptlocation;
    $self->{packageId} = $packageId;
    $self->{packagedir} = $packagedir;
    $self->{didbspackage} = $didbspackage;

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

    my $destdir = $self->{packagedir}."/srcballs";
    mkdirp($destdir);
    my $destfile = $self->{didbspackage}->{packageFile};
    my $fulldestfile = $destdir."/".$destfile;

    if( $self->{extractionstate} eq UNFETCHED )
    {
	my $destdir = $self->{packagedir}."/srcballs";
	mkdirp($destdir);
	my $destfile = $self->{didbspackage}->{packageFile};
	my $fulldestfile = $destdir."/".$destfile;

	my $sourceurl = $self->{didbspackage}->{packageSource};
	my $checksum = $self->{didbspackage}->{packageChecksum};

	print "Package needs fetching from $sourceurl\n";
	my $fetchcmd = $self->{scriptlocation}."/curlhelper.sh $destdir $sourceurl";

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
	    $self->{extractionstate} = FETCHED;
	    if(!verifyChecksum($self,$fulldestfile,$checksum))
	    {
		print "Second download attempt failed.\n";
		exit -1;
	    }
	}

	# File is good
	print "Checksum match.\n";
	$self->{extractionstate} = SIGCHECKED;
    }

    if( $self->{extractionstate} == SIGCHECKED )
    {
	my $extractdir = $self->{packagedir}."/".$self->{packageId};
	mkdirp( $extractdir );
	my $extractor = $self->{didbspackage}->{packageExtraction};
	my $fullpathext = $self->{scriptlocation}."/".$extractor;
	print "Extracting to $extractdir using $fullpathext\n";
	my $cmd = "$fullpathext $extractdir $fulldestfile";
	print "Command is $cmd\n";
	system($cmd) == 0 || die $!;

	$self->{extractionstate} == EXTRACTED;
    }

    return 0;
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
