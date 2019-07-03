#
GBSTEST_INSTALL_DIR="$INSTALLDIR/gbstest"
GBS8_1_INSTALL_DIR="$INSTALLDIR/gbs8_1"

CC=gcc
CXX=g++
CPPFLAGS="-D_SGI_SOURCE=1 -D_SGI_REENTRANT_FUNCTIONS=1 -I$INSTALLDIR/include -I$INSTALLDIR/include/ncurses"
CFLAGS="--std=c99 -mips4 -I$INSTALLDIR/include -I$INSTALLDIR/include/ncurses -L$INSTALLDIR/lib"
CXXFLAGS="-mips4"
LDFLAGS="-L$INSTALLDIR/lib"
SHELL="$INSTALLDIR/bin/bash"
CONFIG_SHELL="$INSTALLDIR/bin/bash"
SHELL_PATH="$INSTALLDIR/bin/bash"
PERL="$INSTALLDIR/bin/perl"
PERL_PATH="$INSTALLDIR/bin/perl"
PATH="$GBS8_1_INSTALL_DIR/bin:$GBSTEST_INSTALL_DIR/bin:$PATH"
LD_LIBRARYN32_PATH="$GBS8_1_INSTALL_DIR/lib:$GBSTEST_INSTALL_DIR/lib:$LD_LIBRARYN32_PATH"
LD_LIBRARY_PATH="$GBS8_1_INSTALL_DIR/lib:$GBSTEST_INSTALL_DIR/lib:$LD_LIBRARY_PATH"
export CC CXX CPPFLAGS CFLAGS CXXFLAGS LDFLAGS SHELL CONFIG_SHELL SHELL_PATH PERL PERL_PATH GBS8_1_INSTALL_DIR GBSTEST_INSTALL_DIR LD_LIBRARYN32_PATH LD_LIBRARY_PATH PATH
