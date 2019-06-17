# didbs

## Irix Development Bootstrapper

A perl script and some minimal supporting tools to allow bootstrapping of some recent open source tools on Irix 6.5.X, mips4.
## Needs

* Irix 6.5.X (6.5.30 tested)
* Mips4 CPU
* Mipspro 7.4.4m
* System perl (/usr/bin/perl)
* System tar (/sbin/tar)
* Roughly 5Gb diskspace
* Minimum of ~512Mb of RAM (~2Gb if you want to build gcc8)

Suggested approach (do everything as your user, I do not recommend use of root or installing into /usr/local or other existing directories. If you have to do things as root, I consider that a bug!):

* Create /usr/didbs
* chown myuser:people /usr/didbs # (have to do this as root, of course)
* Create /usr/didbs/0.0.6 as your user
* gunzip 0.0.6.tar
* tar xf 0.0.6.tar
* cd didbs-0.0.6
* nedit defaultenv.vars
* Set the DIDBS_JOBS to CPU+1, or just one if RAM is < 512Mb, save, exit
* ./bootstrap.pl -p /usr/didbs/package -b /usr/didbs/build -i /usr/didbs/0.0.6 -v # (this sets up paths)
* ./bootstrap.pl # (This builds the stage0 pieces)
* ./bootstrap.pl # (This builds the stage1 then release packages)

## Using the installed tools

You'll need to setup your environment to pull the right directories (bash example):

* export PATH=/usr/didbs/0.0.6/bin:$PATH
* export LD_LIBRARYN32_PATH=/usr/didbs/0.0.6/lib:$LD_LIBRARYN32_PATH
* export PKG_CONFIG_PATH=/usr/didbs/0.0.6/lib/pkgconfig:$PKG_CONFIG_PATH

If you want to use the included gcc4 or gcc8, after building they may be found here (so add to PATH and LD_LIBRARYN32_PATH as well):

gcc4 actual -> /usr/didbs/0.0.6/gbs4_1

gcc8 actual -> /usr/didbs/0.0.6/gbs8_1

Please note that gcc8 is a work-in-progress (thanks to SGIDEV team) but seems to be pretty OK for compiling C.
