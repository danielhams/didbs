#
CC=$DIDBS_CC
#CFLAGS="$DIDBS_ARCH_CFLAGS -O1"
CFLAGS="$DIDBS_ARCH_CFLAGS $DIDBS_O3_NOIPA_CFLAGS $DIDBS_NOWARN_CFLAGS"
LDFLAGS="$DIDBS_ARCH_LDFLAGS $DIDBS_NOWARN_LDFLAGS"
SHELL="$INSTALLDIR/bin/bash"
CONFIG_SHELL="$INSTALLDIR/bin/bash"
PERL="$INSTALLDIR/bin/perl"
#export CC CFLAGS LDFLAGS
export CC CFLAGS LDFLAGS SHELL CONFIG_SHELL PERL
