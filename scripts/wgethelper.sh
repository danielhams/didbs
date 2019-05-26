#!/bin/sh

SCRIPTLOCATION=$1
DESTDIR=$2;
SOURCEURL=$3;
echo $SCRIPTLOCATION;
echo $DESTDIR;
echo $SOURCEURL;
cd $DESTDIR || exit -1;
# Don't check certificates, we don't have any CAs
# This is "good enough" for now (since we are checking the md5sum anyway)
$SCRIPTLOCATION/mips4tools/wget --no-check-certificate $SOURCEURL || exit -1;

exit 0;
