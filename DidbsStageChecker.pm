package DidbsStageChecker;

use constant PACKAGESTAGE => qw(STAGE0 BUILD);

sub new
{
    my $self = bless {}, shift;
    my $scriptLocation = shift;
    my $packageDir = shift;
    my $buildDir = shift;
    my $installDir = shift;

    $self->{scriptLocation} = $scriptLocation;
    $self->{packageDir} = $packageDir;
    $self->{buildDir} = $buildDir;
    $self->{installDir} = $installDir;

    # Check to see what certain "stage" files exist

    my $stageEnvString = $ENV{"DIDBS_STAGE"};
    $self->{stageString} = defined($stageEnvString) ? $stageEnvString : "BUILD";

    $self->{missingStageString} = $self->calcMissingStage();

    print "Setting missing stage to $self->{missingStageString}\n";

    return $self;
}

sub getStageAdjustedPackageDir
{
    my $self = shift;
    return $self->{packageDir};
}

sub getStageAdjustedBuildDir
{
    my $self = shift;
    if( $self->{stageString} eq STAGE0 )
    {
	return "$self->{buildDir}/stage0/build";
    }
    else
    {
	return $self->{buildDir};
    }
}

sub getStageAdjustedInstallDir
{
    my $self = shift;
    if( $self->{stageString} eq STAGE0 )
    {
	return "$self->{buildDir}/stage0/install";
    }
    else
    {
	return $self->{installDir};
    }
}

sub getStageAdjustedPackageDefDir()
{
    my $self = shift;
    if( $self->{stageString} eq STAGE0 )
    {
	return "$self->{scriptLocation}/packages/stage0";
    }
    else
    {
	return "$self->{scriptLocation}/packages";
    }
}

sub getPathToStage0Root
{
    my $self = shift;
    if( $self->{stageString} eq STAGE0 )
    {
	return "";
    }
    else
    {
	return "$self->{buildDir}/stage0/install";
    }
}

sub calcMissingStage
{
    my $self = shift;
    
    print "Checking if there is a missing stage...\n";

    my $currentStage = $ENV{"DIDBS_STAGE"};
    
    my $stage0finishedfile = "$self->{buildDir}/stage0/stage.finished";
    print "Looking for stage finished file at $stage0finishedfile\n";
    my $stage0missing = !(-e $stage0finishedfile);

    print "currentStage=$currentStage\n";
    print "stage0missing=$stage0missing\n";
#    exit;

    if( defined($currentStage) )
    {
	return undef;
    }
    elsif( $stage0missing && $currentStage ne STAGE0 )
    {
	return STAGE0;
    }

    return undef;
}

sub stagesMissing
{
    my $self = shift;

    return defined($self->{missingStageString});
}

sub callMissingStage
{
    my $self = shift;

    my $stageMissing = $self->{missingStageString};

    print "Attempting to call missing stage $stageMissing ...\n";

    if( $stageMissing eq STAGE0 )
    {
	$ENV{"DIDBS_STAGE"} = "STAGE0";
    }
    else
    {
	print "Unknown stage that is missing!\n";
	exit -1;
    }

    my $cmd = "$self->{scriptLocation}/bootstrap.pl";

    system($cmd) == 0 || die $!;

    print "Stage $stageMissing completed.\n";

    $cmd = "touch $self->{buildDir}/".
	lc($self->{missingStageString}).
	"/stage.finished";
    print "Touching stage complete file - $cmd\n";
    system($cmd) == 0 || die !$;
}

sub prependEnvVarPath
{
    my $self = shift;
    my $envVarName = shift;
    my $extraPath = shift;

    my $prevValue = $ENV{$envVarName};
    $ENV{$envVarName} = $extraPath . ":" . $prevValue;
    my $newValue = $ENV{$envVarName};

    
    print "Reset $envVarName from $prevValue to $newValue\n";
}

sub modifyPathForCurrentStage
{
    my $self = shift;
    my $envRef = shift;
    print "Would attempt to call modify path for stage '$self->{stageString}' ...\n";

    my $extraBinPath = $self->getStageAdjustedInstallDir() . "/bin";
    $self->prependEnvVarPath("PATH", $extraBinPath);
    my $extraLibPath = $self->getStageAdjustedInstallDir() . "/lib";
    $self->prependEnvVarPath("LD_LIBRARY_PATH", $extraLibPath);
    my $extraPkgConfigPath = $self->getStageAdjustedInstallDir() . "/lib/pkgconfig";
    $self->prependEnvVarPath("PKG_CONFIG_PATH", $extraPkgConfigPath);
}

1;
