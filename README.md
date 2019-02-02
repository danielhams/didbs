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

* Edit the defaultenv.vars file to set the DIDBS_JOBS to number of CPUs + 1
* Run ./bootstrap.pl to set the directories it should use

./bootstrap.pl -p /pathforpackages -b /pathforbuilding -i /pathforinstall -v

* Run bootstrap.pl to build stage0 packages (it stops after this)
* Run bootstrap.pl again to build stage1 and the release packages

--

Suggested approach (do everything as your user, I do not recommend use of root or installing into /usr/local or other existing directories. If you have to do things as root, I consider that a bug!):

* Create /usr/didbs
* chown myuser:people /usr/didbs # (have to do this as root, of course)
* gunzip 0.0.3.tar
* tar xf 0.0.3.tar
* cd didbs-0.0.3
* nedit defaultenv.vars
* Set the DIDBS_JOBS to CPU+1, or just one if RAM is < 512Mb, save, exit
* ./bootstrap.pl -p /usr/didbs/packages -b /usr/didbs/build -i /usr/didbs -v # (this sets up paths)
* ./bootstrap.pl # (This builds the stage0 pieces)
* ./bootstrap.pl # (This builds the stage1 then release packages)

## Using the installed tools

You'll need to setup your environment to pull the right directories (bash example):

* export PATH=/usr/didbs/bin:$PATH
* export LD_LIBRARYN32_PATH=/usr/didbs/lib:$LD_LIBRARYN32_PATH
* export PKG_CONFIG_PATH=/usr/didbs/lib/pkgconfig:$PKG_CONFIG_PATH