#
CC=$DIDBS_CC
CXX=$DIDBS_CXX
CFLAGS="$DIDBS_ARCH_CFLAGS -I$INSTALLDIR/include -I$INSTALLDIR/include/nettle"
LDFLAGS="$DIDBS_ARCH_LDFLAGS -L$INSTALLDIR/$DIDBS_LIBDIR"
PERL=$INSTALLDIR/bin/perl
SHELL=$INSTALLDIR/bin/bash
CONFIG_SHELL=$INSTALLDIR/bin/bash
export CC CFLAGS LDFLAGS PERL SHELL CONFIG_SHELL
if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$INSTALLDIR/lib32"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$INSTALLDIR/lib64"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
