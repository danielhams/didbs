#!/bin/sh

DESTDIR=$1;
SOURCEURL=$2;
echo $DESTDIR;
echo $SOURCEURL;
cd $DESTDIR || exit -1;
$DCURL -q -O -J $SOURCEURL || exit -1;

exit 0;
