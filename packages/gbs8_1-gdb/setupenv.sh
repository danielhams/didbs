#
GBS8_1_INSTALL_DIR="$INSTALLDIR/gbs8_1"

CC=gcc
CXX=g++
CPPFLAGS="-D_SGI_SOURCE=1 -D_SGI_REENTRANT_FUNCTIONS=1 -I$INSTALLDIR/include -I$INSTALLDIR/include/ncurses"
CFLAGS="$DIDBS_ISA_SWITCH"
CXXFLAGS="$CFLAGS"
LDFLAGS="-L$INSTALLDIR/$DIDBS_LIBDIR"
SHELL="$INSTALLDIR/bin/bash"
CONFIG_SHELL="$INSTALLDIR/bin/bash"
SHELL_PATH="$INSTALLDIR/bin/bash"
PERL="$INSTALLDIR/bin/perl"
PERL_PATH="$INSTALLDIR/bin/perl"
PATH="$GBS8_1_INSTALL_DIR/bin:$PATH"
export CC CXX CPPFLAGS CFLAGS CXXFLAGS LDFLAGS SHELL CONFIG_SHELL SHELL_PATH PERL PERL_PATH GBS8_1_INSTALL_DIR PATH

if [ "ne$DIDBS_LIBDIR" == "nelib32" ]; then
    LD_LIBRARYN32_PATH="$GBS8_1_INSTALL_DIR/$DIDBS_LIBDIR:$INSTALLDIR/lib32"
    PKG_CONFIG_PATH="$INSTALLDIR/lib32/pkgconfig"
    export LD_LIBRARYN32_PATH PKG_CONFIG_PATH
else
    LD_LIBRARYN64_PATH="$GBS8_1_INSTALL_DIR/$DIDBS_LIBDIR:$INSTALLDIR/lib64"
    PKG_CONFIG_PATH="$INSTALLDIR/lib64/pkgconfig"
    export LD_LIBRARYN64_PATH PKG_CONFIG_PATH
fi
