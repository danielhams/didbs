package DidbsPackageHasher;

use Digest::SHA;
use File::Basename;

use DidbsUtils;

sub new
{
    my $self = bless{}, shift;
    my $verbose = shift;
    $self->{v} = $verbose;

    return $self;
}

sub calculateEnvHash
{
    my ($envFile, $supEnvFile, $elfwidth, $isa, $compiler) = (@_);

    # Compute a sha256 sum of the contents of the package def dir
    my $envSha = Digest::SHA->new("sha256");
    $envSha->addfile($envFile);
    $envSha->addfile($supEnvFile);
    $envSha->add($elfwidth);
    $envSha->add($isa);
    $envSha->add($compiler);
    return $envSha->b64digest;
}

sub calculatePackageDefHash
{
    my ($verbose, $packageDefDir) = (@_);

    # Compute a sha256 sum of the contents of the package def dir
    my $packageSha = Digest::SHA->new("sha256");
    my @PKGFILES = glob "$packageDefDir/*";
    chomp(@PKGFILES);
    for (@PKGFILES)
    {
	# I use emacs, it creates backup files named FILENAME~
	next if (m/.*\~$/);
	my $pkgHelperFile = basename($_);
	$packageSha->addfile($packageDefDir."/".$pkgHelperFile);
    }
#    (!$verbose) && print "#";

    return $packageSha->b64digest;
}

sub calculateEnvPacDepHash
{
    my ($envHash, $packageDefHash, $dependencyHashesRef) = (@_);
    my $packageSha = Digest::SHA->new("sha256");

    $packageSha->add($envHash);
    $packageSha->add($packageDefHash);
    for( @{$dependencyHashesRef} )
    {
	$packageSha->add($_);
    }

    return $packageSha->b64digest;
}

1;
