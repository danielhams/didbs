#
CC=$DIDBS_CC
CXX=$DIDBS_CXX
CFLAGS="$DIDBS_ARCH_CFLAGS -I$INSTALLDIR/include -I$INSTALLDIR/include/nettle"
LDFLAGS="$DIDBS_ARCH_LDFLAGS -L$INSTALLDIR/lib"
PATH=$INSTALLDIR/bin:$EXTRAARGS/bin:$PATH
LD_LIBRARYN32_PATH=$INSTALLDIR/lib:$EXTRAARGS/lib:$LD_LIBRARYN32_PATH
export CC CXX CFLAGS LDFLAGS PATH LD_LIBRARYN32_PATH PKG_CONFIG_PATH