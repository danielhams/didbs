#!/usr/didbs/current/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib ".";
use lib "..";
#use lib "$FindBin::Bin/../lib";

# Packages specific to the tooling
use DidbsStageChecker;
use DidbsDependencyEngine;
use DidbsPackage;
use DidbsPackageState;
use DidbsExtractor;
use DidbsPatcher;
use DidbsConfigurator;
use DidbsBuilder;
use DidbsInstaller;
use DidbsPackageShell;
use DidbsUtils;

STDERR->autoflush(1);
STDOUT->autoflush(1);

###
# TO RUN CHANGES AGAINST BOTH THE STAGE0
# AND REGULAR PACKAGES
# run with `DIDBS_STAGE=STAGE0 V=1 ./bulkmodifier.pl`
# then     `V=1 ./bulkmodifier.pl`

my $verbose = 0;
$verbose = $verbose || $ENV{"V"}=="1";

sub doTheChange {
    my $packageRef = shift;
    my $packageDir = shift;
    my $packageDefFile = shift;

    my $curpkg = ${$packageRef};
    my $pkgid = $curpkg->{packageId};

    my $packageDefFile = "$packageDir/$pkgid.packagedef";

    $verbose && didbsprint "Apply bulk transform for package '$pkgid'...\n";
    $verbose && didbsprint "in dir $packageDir with def file $packageDefFile\n";
    didbsprint "in dir $packageDir with def file $packageDefFile\n";
    # Example operation
#    my $cmd = "echo 'compilers=mipspro,gcc' >>$packageDefFile";
#    didbsprint "Would execute $cmd\n";
#    system($cmd) && die $_;
}

my $scriptLocation = "..";

# For stage0
#my $packageDefsDir = "../packages/stage0";
#$ENV{"DIDBS_STAGE"} = "STAGE0";

# For stage1 + regular
my $packageDefsDir = "../packages/stage0";

my $stageChecker = DidbsStageChecker->new( $scriptLocation,
					   $packageDefsDir,
					   "/tmp/builddir",
					   "/tmp/installdir" );
$stageChecker->modifyPathForCurrentStage();
$packageDefsDir = $stageChecker->getStageAdjustedPackageDefDir();

$verbose && didbsprint "Adjusted packageDefsDir=$packageDefsDir\n";

my $pkgDependencyEngine = DidbsDependencyEngine->new($verbose,
						     $scriptLocation,
						     $packageDefsDir);

my $foundPackagesRef = $pkgDependencyEngine->listPackages();
my $p2pRef = $pkgDependencyEngine->getPackageMap();
my %pkgidToPackageMap = %{$p2pRef};

foreach $pkg (@{$foundPackagesRef})
{
    my $curpkg = ${$pkg};
    my $pkgid = $curpkg->{packageId};
    
    my $directoryOfChange = "$packageDefsDir/$pkgid";

    doTheChange($pkg, $directoryOfChange, "$pkgid.packagedef");
}

exit 0;
