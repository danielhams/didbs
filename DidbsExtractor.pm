package DidbsExtractor;

use DidbsUtils;
use DidbsPackageState;

use File::Path qw/rmtree/;

# Contents set up from values from the dbibsPackage
#
# downloadSuccessFilePath
# 

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageId = shift;
    my $packageDir = shift;
    my $buildDir = shift;
    my $didbsPackage = shift;
    my $packageState = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageId} = $packageId;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{didbsPackage} = $didbsPackage;
    $self->{packageState} = $packageState;

    return $self;
}

sub getState
{
    my $self = shift;
    return $self->{packageState}->getState();
}

sub setState
{
    my $self = shift;
    my $newState = shift;
    $self->{packageState}->setState($newState);
}

sub extractionSuccess
{
    my $self = shift;

    return $self->getState() eq EXTRACTED;
}

sub extractit
{
    my $self = shift;

    my $destdir = $self->{packageDir}."/srcballs";
    mkdirp($destdir);
    my $destfile = $self->{didbsPackage}->{packageFile};
    my $fulldestfile = $destdir."/".$destfile;

    if( $self->getState() ne FETCHED )
    {
        print "Unfetched package. Fetching.\n";
        mkdirp($destdir);
        my $destfile = $self->{didbsPackage}->{packageFile};
        my $fulldestfile = $destdir."/".$destfile;

        my $sourceurl = $self->{didbsPackage}->{packageSource};
        my $checksum = $self->{didbsPackage}->{packageChecksum};

        print "Package needs fetching from $sourceurl\n";
        my $fetchcmd = $self->{scriptLocation}."/wgethelper.sh ".$self->{scriptLocation}." $destdir $sourceurl";

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
		print "File exists ($fulldestfile)\n";
                $fileexistsgood = 1;
            }
        }

        if(!$fileexistsgood)
        {
            print "Fetching...\n";
            print "\n\n";

            system($fetchcmd) == 0 || die $!;
            $self->setState( FETCHED );
            if(!verifyChecksum($self,$fulldestfile,$checksum))
            {
                print "Second download attempt failed.\n";
                exit -1;
            }
        }

        # File is good
        print "Checksum match.\n";
        $self->setState(SIGCHECKED);
    }

    if( $self->getState() == SIGCHECKED )
    {
        my $extractdir = $self->{buildDir}."/".$self->{packageId};
        print "Removing any existing content at $extractdir\n";
        rmtree $extractdir || die $!;
        mkdirp( $extractdir );
        my $extractor = $self->{didbsPackage}->{packageExtraction};
        my $fullpathext = $self->{scriptLocation}."/".$extractor;
        print "Extracting to $extractdir using $fullpathext\n";
        my $cmd = "$fullpathext $extractdir $fulldestfile";
        print "Command is $cmd\n";
        system($cmd) == 0 || die $!;

        $self->setState(EXTRACTED);
    }

    return $self->getState() == EXTRACTED;
}

sub verifyChecksum
{
    my $self=shift;
    my $filename=shift;
    my $checksum=shift;
    #    print "Verifying checksum of $filename\n";
    
    my $calcchecksum = sumfile($self->{scriptLocation}, $filename);
    print "Expected($checksum) - received($calcchecksum)\n";

    return $calcchecksum eq $checksum;
}

sub debug
{
    my $self = shift;
    print "DibsExtractor constructed for $self->{packageId}\n";
    print "Status is " . $self->getState() ."\n";
}

1;
