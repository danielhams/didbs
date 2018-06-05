#!/bin/sh

BUILDDIR=$1;
PREFIX=$2;
EXTRAARGS=$3;
echo $BUILDDIR;
echo $PREFIX;
echo $EXTRAARGS;
cd $BUILDDIR || exit -1;
./configure --prefix=$PREFIX $EXTRAARGS || exit -1;
exit 0;
