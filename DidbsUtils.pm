package DidbsUtils;
use Exporter;
@ISA = ('Exporter');
@EXPORT=('mkdirp','sha256file');

use File::Basename;
use Digest::SHA256;

sub mkdirp($)
{
    my $dir=shift;
    return if( -d $dir );
    mkdirp(dirname($dir));
    mkdir $dir, 0755 || die $!;
}

sub sha256file($)
{
    my $filename=shift;
    open CF, "<".$filename;

    # NB this is not "real" sha256, but it's good enough for
    # bootstrapping
    my $context = Digest::SHA256::new(256);
    $context->reset();
    $context->addfile(CF);

    my $digest = $context->hexdigest();

    close CF;

    $digest =~ s/\s//g;

    return $digest;
}

1;
