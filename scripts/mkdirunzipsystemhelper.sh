#!/bin/sh

DESTDIR=$1;
SOURCEARCHIVE=$2;
echo $DESTDIR;
echo $SOURCEARCHIVE;
cd $DESTDIR || exit -1;
name=`basename $SOURCEARCHIVE .zip`
echo "Name is $name"
mkdir $name || exit -1
cd $name || exit -1
unzip $SOURCEARCHIVE || exit -1;

exit 0;
