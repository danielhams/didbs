#
CC=$DIDBS_CC
CFLAGS="$DIDBS_ARCH_CFLAGS -O1 -I$INSTALLDIR/include"
#CFLAGS="$DIDBS_ARCH_CFLAGS -O3 -OPT:Olimit=7000"
LDFLAGS="$DIDBS_ARCH_LDFLAGS -L$INSTALLDIR/$DIDBS_LIBDIR"
export CC CFLAGS LDFLAGS
if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$INSTALLDIR/lib32"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$INSTALLDIR/lib64"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
