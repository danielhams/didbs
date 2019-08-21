#
GBS9_0_INSTALL_DIR="$INSTALLDIR/gbs9_0"
GBS9_1_INSTALL_DIR="$INSTALLDIR/gbs9_1"

CPPFLAGS="$DIDBS_CPPFLAGS"

CC="gcc --std=c99 $DIDBS_CPPFLAGS"
CXX="g++"

#CFLAGS="$DIDBS_ARCH_CFLAGS"
#CXXFLAGS="$DIDBS_ARCH_CFLAGS"

#CC=$DIDBS_CC
#CXX=$DIDBS_CXX
##CFLAGS="$DIDBS_ARCH_CFLAGS $DIDBS_O3_IPA_CFLAGS $DIDBS_NOWARN_CFLAGS"
##LDFLAGS="$DIDBS_ARCH_LDFLAGS $DIDBS_IPA_LDFLAGS $DIDBS_NOWARN_LDFLAGS"
#CFLAGS="$DIDBS_ARCH_CFLAGS $DIDBS_O1_CFLAGS $DIDBS_NOWARN_CFLAGS"
#CXXFLAGS="$DIDBS_ARCH_CFLAGS $DIDBS_O1_CFLAGS $DIDBS_NOWARN_CFLAGS"
#LDFLAGS="$DIDBS_ARCH_LDFLAGS $DIDBS_NOWARN_LDFLAGS"

SHELL="$INSTALLDIR/bin/bash"
SHELL_PATH="$SHELL"
CONFIG_SHELL="$SHELL"
MAKE="$INSTALLDIR/bin/make"
PERL="$INSTALLDIR/bin/perl"
PERL_PATH="$INSTALLDIR/bin/perl"
PATH="$GBS9_0_INSTALL_DIR/bin:$PATH"
LD_LIBRARYN32_PATH="$GBS9_0_INSTALL_DIR/lib:$LD_LIBRARYN32_PATH"
LD_LIBRARY_PATH="$GBS9_0_INSTALL_DIR/lib:$LD_LIBRARY_PATH"
PKG_CONFIG_PATH="$GBS9_0_INSTALL_DIR/lib/pkgconfig:$INSTALLDIR/lib/pkgconfig"
#MAKEINFO=missing
export CC CFLAGS LDFLAGS SHELL SHELL_PATH CONFIG_SHELL MAKE PERL PERL_PATH PATH LD_LIBRARYN32_PATH LD_LIBRARY_PATH PKG_CONFIG_PATH GBS9_0_INSTALL_DIR GBS9_1_INSTALL_DIR MAKEINFO
