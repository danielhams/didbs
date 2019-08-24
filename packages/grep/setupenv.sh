#
CC=$DIDBS_CC
CPPFLAGS="-I$INSTALLDIR/include"
CFLAGS="$DIDBS_ARCH_CFLAGS $DIDBS_O3_IPA_CFLAGS $DIDBS_NOWARN_CFLAGS"
LDFLAGS="$DIDBS_ARCH_LDFLAGS $DIDBS_IPA_LDFLAGS $DIDBS_NOWARN_LDFLAGS -L$INSTALLDIR/$DIDBS_LIBDIR"
PERL=$INSTALLDIR/bin/perl
export CC CFLAGS LDFLAGS PERL
if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$INSTALLDIR/lib32"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$INSTALLDIR/lib64"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
