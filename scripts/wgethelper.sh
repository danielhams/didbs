#!/bin/sh

SCRIPTLOCATION=$1
DESTDIR=$2;
SOURCEURL=$3;
echo $SCRIPTLOCATION;
echo $DESTDIR;
echo $SOURCEURL;
cd $DESTDIR || exit -1;
# We can use the "/usr/didbs/current/bin/wget" now,
# which includes recent cacerts, so now it will properly check.
# No more statically linked wget skipping certs.
wget $SOURCEURL || exit -1;

exit 0;
