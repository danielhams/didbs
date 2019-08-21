#!/usr/bin/perl
use File::Basename qw/basename/;
use FindBin;
use lib ".";
use lib "..";
use lib "$FindBin::Bin/../lib";

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
}

my $scriptLocation = "..";
my $packageDefsDir = "../packages";

my $stageChecker = DidbsStageChecker->new( $scriptLocation,
					   $packageDir,
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
