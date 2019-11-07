package DidbsStageChecker;

use DidbsUtils;

use constant PACKAGESTAGE => qw(BUILD);

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

    didbsprint "Setting missing stage to $self->{missingStageString}\n";

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
    return $self->{buildDir};
}

sub getStageAdjustedInstallDir
{
    my $self = shift;
    return $self->{installDir};
}

sub getStageAdjustedPackageDefDir()
{
    my $self = shift;
    return "$self->{scriptLocation}/packages";
}

sub calcMissingStage
{
    # We rely on a previous didbs release now for "stage0" binaries
    return undef;
}

sub stagesMissing
{
    my $self = shift;

    return defined($self->{missingStageString});
}

sub prependEnvVarPath
{
    my $self = shift;
    my $envVarName = shift;
    my $extraPath = shift;

    my $prevValue = $ENV{$envVarName};
    if( !defined($prevValue) )
	{
	    $ENV{$envVarName} = $extraPath;
	}
	else
	{
	    $ENV{$envVarName} = $extraPath . ":" . $prevValue;
	}
    my $newValue = $ENV{$envVarName};

    didbsprint "Reset $envVarName from $prevValue to $newValue\n";
}

sub modifyPathForCurrentStage
{
    my $self = shift;
    my $envRef = shift;
    didbsprint "Modifying path for stage '$self->{stageString}' ...\n";

    my $extraBinPath = $self->getStageAdjustedInstallDir() . "/bin";
    $self->prependEnvVarPath("PATH", $extraBinPath);
    my $extraLibPath;
    my $extraPkgConfigPath;

    if( $ENV{"DIDBS_LIBDIR"} eq "lib32" ) {
	$extraLibPath = $self->getStageAdjustedInstallDir() . "/lib32";
	$self->prependEnvVarPath("LD_LIBRARYN32_PATH", $extraLibPath);
	$extraPkgConfigPath = $self->getStageAdjustedInstallDir() . "/lib32/pkgconfig";
    }
    else {
	$extraLibPath = $self->getStageAdjustedInstallDir() . "/lib64";
	$self->prependEnvVarPath("LD_LIBRARYN64_PATH", $extraLibPath);
	$extraPkgConfigPath = $self->getStageAdjustedInstallDir() . "/lib64/pkgconfig";
    }
    $self->prependEnvVarPath("LD_LIBRARY_PATH", $extraLibPath);
    $self->prependEnvVarPath("PKG_CONFIG_PATH", $extraPkgConfigPath);
}

1;
