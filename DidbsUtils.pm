package DidbsUtils;
use POSIX;
use Exporter;
use IO::Handle;
use Cwd 'abs_path';

use Time::HiRes qw(gettimeofday);

@ISA = ('Exporter');
@EXPORT=('mkdirp','sumfile','begins_with','didbsprint','compatibledidbscurrent');

use File::Basename;

# Tweak to 1 to see date/time output
my $useTimestamps=1;

sub didbsprint
{
    my @args = @_;
    if($useTimestamps) {
	my @ts = gettimeofday();
	my $microst = $ts[1] %1000000;
	my $millis = floor($microst/1000);
	my $micros = $microst%1000;
#	my $subsecstr = sprintf ".%0.3d.%0.3d", $millis, $micros;
	my $subsecstr = sprintf ".%0.3d", $millis;
	print strftime("%F %T",localtime) . $subsecstr . " ";
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
    # This should use the md5sum from /usr/didbs/current/bin
    $dsum = "md5sum";

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

# Verify that an existing didbs versions is installed and available
# as /usr/didbs/current
# So we verify that
# (1) /usr/didbs/current _is_ a symbolic link
# (2) That the underlying directory is version >= 0.1.3 < current version
# (3) That it is an "n32" and "mips3" installation
# (4) That all the gccs we expect are present (makes sure it is didbs)
sub compatibledidbscurrent
{
    my $retVal=1;
    my $verbose=shift;
    my $version=shift;
    my($scriptMajVer,$scriptGenVer,$scriptMinVer) =
	    $version =~ m/(\d)\.(\d)\.(\d)(.*)/;
    $verbose && didbsprint "Checking for /usr/didbs/current symbolic link..";
    my $linkIsOk = (-e '/usr/didbs/current' && -l '/usr/didbs/current');
    $verbose && print "$linkIsOk\n";
    $retVal = $retVal && $linkIsOk;
    if( !$linkIsOk ) {
	return $retVal;
    }
    $verbose && didbsprint "Checking underlying dir is compatible version..";
    my $dirBehindLink = abs_path('/usr/didbs/current');
    my $dirIsOk=0;
    if( defined($dirBehindLink) && -e $dirBehindLink ) {
	$verbose && didbsprint "dirBehindLink is $dirBehindLink\n";
	my($dirMajVer,$dirGenVer,$dirMinVer,$dirRest) =
	    $dirBehindLink =~ m/(\d)_(\d)_(\d)[^_]*(_.+)/;
	$verbose && didbsprint "Matched $dirMajVer $dirGenVer $dirMinVer $dirRest\n";
	if( $dirRest == "_n32_mips3_mp" ) {
	    $verbose && didbsprint "Elf width, ISA + compiler OK\n";
	    # Version check min is 0.1.6 (starting from 0.1.6)
	    # due to the need for a particular didbs perl version.
	    # max is current script minus one
	    if( ($dirMajVer > 0)
		||
		($dirGenVer > 1)
		||
		($dirMinVer >= 6 ) ) {
#		didbsprint "Min version check ok\n";
		# Check the version is less or the same
		if( ($dirMajVer < $scriptMajVer)
		    ||
		    ($dirMajVer == $scriptMajVer && $dirGenVer < $scriptGenVer)
		    ||
		    ($dirMajVer == $scriptMajVer && $dirGenVer == $scriptGenVer && $dirMinVer <= $scriptMinVer ) ) {
#		    didbsprint "Max version check ok\n";
		    $dirIsOk=1;
		}
		else {
		    $verbose && didbsprint "Max version test failure!\n";
		}
	    }
	    else {
		$verbose && didbsprint "Min version test failure!\n";
	    }
	}
    }
    $verbose && print "$dirIsOk\n";
    $retVal = $retVal && $dirIsOk;
    if( !$dirIsOk ) {
	return $retVal;
    }
    # Final check, is it really didbs there...
    # Check there are gccs under the right dirs
    $verbose && didbsprint "Checking for needed gccs..";
    my $gccsAreOk=0;
    if(
	-e '/usr/didbs/current/gbs4_2/bin/gcc'
	&&
	-e '/usr/didbs/current/gbs5_0/bin/gcc'
	&&
	-e '/usr/didbs/current/gbs8_1/bin/gcc'
	&&
	-e '/usr/didbs/current/gbs9_1/bin/gcc'
	) {
	$gccsAreOk=1;
    }
    $verbose && print "$gccsAreOk\n";
    $retVal = $retVal && $gccsAreOk;
    return $retVal;
}

1;
