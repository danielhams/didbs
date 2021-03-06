#
CC=$DIDBS_CC
CXX=$DIDBS_CXX
CFLAGS="$DIDBS_ARCH_CFLAGS -I$INSTALLDIR/include -I$INSTALLDIR/include/nettle"
LDFLAGS="$DIDBS_ARCH_LDFLAGS -L$INSTALLDIR/$DIDBS_LIBDIR"
PATH=$INSTALLDIR/bin:$EXTRAARGS/bin:$PATH
export CC CXX CFLAGS LDFLAGS PATH
if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$INSTALLDIR/lib32:$LD_LIBRARYN32_PATH"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$INSTALLDIR/lib64:$LD_LIBRARYN64_PATH"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
