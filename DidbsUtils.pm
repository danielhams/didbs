package DidbsUtils;
use Exporter;
use IO::Handle;

@ISA = ('Exporter');
@EXPORT=('mkdirp','sumfile','begins_with','didbsprint');

use File::Basename;

# Just in cast at some point I want to add timestaps etc.
sub didbsprint
{
    printf @_;
}

sub mkdirp($)
{
    my $dir=shift;
    return if( -d $dir );
    mkdirp(dirname($dir));
    mkdir $dir, 0755 || die $!;
}

sub sumfile
{
    my $scriptLocation=shift;
    my $filename=shift;
    $dsum = "$scriptLocation/mips4tools/md5sum";

    my $digest = `$dsum $filename`;
    chomp($digest);

#    didbsprint "Digest result is $digest\n";
    (my $extracteddigest = $digest ) =~ s/^(\S+)\s+.*$/$1/g;
#    didbsprint "Pulled out $extracteddigest\n";

    return $extracteddigest;
}

sub begins_with
{
    return substr($_[0], 0, length($_[1])) eq $_[1];
}

1;
