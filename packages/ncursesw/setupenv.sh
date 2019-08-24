#
CC=$DIDBS_CC
CXX=$DIDBS_CXX
CFLAGS="$DIDBS_ARCH_CFLAGS -O1 -I${INSTALLDIR}/include"
CXXFLAGS="$DIDBS_ARCH_CXXFLAGS -O1 -I${INSTALLDIR}/include"
LDFLAGS="$DIDBS_ARCH_LDFLAGS -L${INSTALLDIR}/$DIDBS_LIBDIR"
export CC CXX CFLAGS CXXFLAGS LDFLAGS
if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$INSTALLDIR/lib32"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$INSTALLDIR/lib64"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
