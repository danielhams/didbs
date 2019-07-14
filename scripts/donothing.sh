#!/bin/sh

DESTDIR=$1;
SOURCEARCHIVE=$2;
echo $DESTDIR;
echo $SOURCEARCHIVE;
cd $DESTDIR || exit -1;
cp $SOURCEARCHIVE $DESTDIR || exit -1
exit 0;
