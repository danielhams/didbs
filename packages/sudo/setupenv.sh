#
CC="$DIDBS_CC"
CPPFLAGS="$DIDBS_CPPFLAGS"
if [ "ne$DIDBS_CC" == "negcc" ]; then
    CFLAGS="$DIDBS_ARCH_CFLAGS $DIDBS_GCC_OPT_SWITCH"
    LDFLAGS="$DIDBS_ARCH_LDFLAGS -L$INSTALLDIR/$DIDBS_LIBDIR"
else
    CFLAGS="$DIDBS_ARCH_CFLAGS $DIDBS_O1_CFLAGS $DIDBS_NOWARN_CFLAGS"
    LDFLAGS="$DIDBS_ARCH_LDFLAGS $DIDBS_NOWARN_LDFLAGS -L$INSTALLDIR/$DIDBS_LIBDIR"
fi
CXXFLAGS="$CFLAGS"
PERL="$INSTALLDIR/bin/perl"
TEST_SHELL="$INSTALLDIR/bin/bash"
SHELL="$INSTALLDIR/bin/bash"
export CC CPPFLAGS CFLAGS CXXFLAGS LDFLAGS PERL TEST_SHELL SHELL
if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$INSTALLDIR/lib32"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$INSTALLDIR/lib64"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
