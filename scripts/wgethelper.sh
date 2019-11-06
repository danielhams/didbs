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

# wget currently broken in 0.1.7 - courtesy thor
# this can be worked around by using curl
#wget $SOURCEURL || exit -1;
curl -s -L -O $SOURCEURL || exit -1;

exit 0;
