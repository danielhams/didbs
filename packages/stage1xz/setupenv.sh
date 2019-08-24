CC=$DIDBS_CC
CFLAGS="$DIDBS_ARCH_CFLAGS -O1"
LDFLAGS="$DIDBS_ARCH_LDFLAGS"
PATH=$INSTALLDIR/bin:$EXTRAARGS/bin:$PATH
export CC CFLAGS LDFLAGS PATH
if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$INSTALLDIR/lib32"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$INSTALLDIR/lib64"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
