#!/bin/sh

DESTDIR=$1;
SOURCEARCHIVE=$2;
echo $DESTDIR;
echo $SOURCEARCHIVE;
cd $DESTDIR || exit -1;
unzip $SOURCEARCHIVE || exit -1;

exit 0;
