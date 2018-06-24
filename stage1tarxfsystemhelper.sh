#!/bin/sh

DESTDIR=$1;
SOURCEARCHIVE=$2;
echo $DESTDIR;
echo $SOURCEARCHIVE;
echo $STAGE0ROOT;
cd $DESTDIR || exit -1;
$STAGE0ROOT/bin/tar xf $SOURCEARCHIVE || exit -1;

exit 0;
