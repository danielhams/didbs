# didbs

## Irix Development Bootstrapper

A perl script and some minimal supporting tools to allow bootstrapping of some recent open source tools on Irix 6.5.X, mips4.
## Needs

* Irix 6.5.X (6.5.30 tested)
* Mips4 CPU
* Mipspro 7.4.4m
* System perl (/usr/bin/perl)
* System tar (/sbin/tar)
* Roughly 2Gb diskspace
* Minimum of ~512Mb of RAM

## How to run it

* Edit the defaultenv.vars file to set the DIDBS_JIBS to number of CPUs + 1
* Run ./bootstrap.pl to set the directories it should use

./bootstrap.pl -p /pathforpackages -b /pathforbuilding -i /pathforinstall -v

* Once configuration run bootstrap.pl to build stage0 packages
* Run bootstrap.pl again to build stage1 and the release packages
