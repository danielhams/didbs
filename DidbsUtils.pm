package DidbsUtils;
use POSIX;
use Exporter;
use IO::Handle;

@ISA = ('Exporter');
@EXPORT=('mkdirp','sumfile','begins_with','didbsprint');

use File::Basename;

# Tweak to 1 to see date/time output
my $useTimestamps=0;
sub didbsprint
{
    my @args = @_;
    if($useTimestamps) {
	print strftime("%F %T",localtime) . " ";
    }
    print @args;
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
