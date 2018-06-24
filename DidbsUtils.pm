package DidbsUtils;
use Exporter;
@ISA = ('Exporter');
@EXPORT=('mkdirp','sumfile','begins_with');

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
    $dsum = $ENV{"DSUM"};
#    print "DSUM is $dsum\n";

    my $digest = `$dsum $filename`;
    chomp($digest);

#    print "Digest result is $digest\n";
    (my $extracteddigest = $digest ) =~ s/^(\S+)\s+.*$/$1/g;
#    print "Pulled out $extracteddigest\n";

    return $extracteddigest;
}

sub begins_with
{
    return substr($_[0], 0, length($_[1])) eq $_[1];
}

1;
