#!/bin/sh

DESTDIR=$1;
SOURCEARCHIVE=$2;
echo $DESTDIR;
echo $SOURCEARCHIVE;
cd $DESTDIR || exit -1;
$DIDSB_INSTALL_DIR/bin/tar xf $SOURCEARCHIVE || exit -1;

exit 0;
