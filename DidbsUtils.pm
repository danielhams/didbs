package DidbsUtils;
use Exporter;
@ISA = ('Exporter');
@EXPORT=('mkdirp','sumfile');

use File::Basename;

sub mkdirp($)
{
    my $dir=shift;
    return if( -d $dir );
    mkdirp(dirname($dir));
    mkdir $dir, 0755 || die $!;
}

sub sumfile($)
{
    my $filename=shift;

    my $digest = `sum $filename`;

    print "Got back a sum of $digest\n";
    $digest =~ s/\s//g;

    return $digest;
}

1;
