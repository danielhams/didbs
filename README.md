# didbs

## Irix Development Bootstrapper

A perl script and some minimal supporting tools to allow bootstrapping of some recent open source tools on Irix 6.5.X, mips4.
## Needs

* Irix 6.5.X (6.5.30 tested)
* Mips4 CPU (mips3 is a supported _target_ - but to build you need mips4)
* Mipspro 7.4.4m
* System perl (/usr/bin/perl)
* System tar (/sbin/tar)
* Roughly 20Gb diskspace
* Minimum of ~2Gb of RAM
* Beefy CPU if you want to build everything (2*600mhz min)

Suggested approach:

(1) Do everything as your user, I do not recommend use of root or installing into /usr/local or other existing directories. If you have to do things as root, I consider that a bug!
(2) We have to dance a little due to way that github provides "release" tarballs/directories in them

(Example for n32, mips4, mipspro)
* As root
* Create /usr/didbs
* chown myuser:people /usr/didbs # (have to do this as root, of course)
* As your user
* mkdir /usr/didbs/0_1_1_n32_mips4_mp_build
* mkdir /usr/didbs/0_1_1_n32_mips4_mp_package
* mkdir /usr/didbs/0_1_1_n32_mips4_mp
* cd /usr/didbs/0_1_1_n32_mips4_mp_build
* mv /path/to/downloadedrelease/0.1.1.tar.gz ./
* gunzip 0.1.1.tar.gz
* tar xf 0.1.1.tar
* mv didbs-0.1.1/* ./
* mv didbs-0.1.1/.gitignore ./
* rmdir didbs-0.1.1
* rm 0.1.1.tar
* nedit defaultenv.vars
* Set the DIDBS_JOBS to CPU+1, or just one if RAM is < 512Mb, save, exit
* ./bootstrap.pl -p /usr/didbs/0_1_1_n32_mips4_mp_package -b /usr/didbs/0_1_1_n32_mips4_mp_build -i /usr/didbs/0_1_1_n32_mips4_mp -v # (this sets up paths)
* ./bootstrap.pl # (This builds the stage0 pieces)
* ./bootstrap.pl # (This builds the stage1 then release packages)

## Using the installed tools

You'll need to setup your environment to pull the right directories (bash example):

* export PATH=/usr/didbs/0_1_1_n32_mips4_mp/bin:$PATH
* export LD_LIBRARYN32_PATH=/usr/didbs/0_1_1_n32_mips4_mp/lib32:$LD_LIBRARYN32_PATH
* export PKG_CONFIG_PATH=/usr/didbs/0_1_1_n32_mips4_mp/lib32/pkgconfig:$PKG_CONFIG_PATH

If you want to use the included gcc4, gcc5 or gcc8, after building they may be found here (so add to PATH and LD_LIBRARYN32_PATH as well):

gcc4 actual -> /usr/didbs/0_1_1_n32_mips4_mp/gbs4_2

gcc5 actual -> /usr/didbs/0_1_1_n32_mips4_mp/gbs5_0
(gcc5 is a special case, and requires the gcc4 paths afterwards to pick up the binutils/gdb there)

gcc8 actual -> /usr/didbs/0_1_1_n32_mips4_mp/gbs8_1

Please note that the gcc compilers are a work-in-progress and for the moment we still expect breakage / teething issues, particularly on < 6.5.30 where headers may not match up.
