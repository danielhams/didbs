# didbs

## Irix Development Bootstrapper

A perl script and some minimal supporting tools to allow bootstrapping of some recent open source tools on Irix 6.5.X, mips4.

Be aware - this build process will create the exact same content that may be found in the existing didbs releases! If you just want to "use" the software built by didbs - just go fetch an existing didbs release and skip this build. (See below for link).

## Needs

* Irix 6.5.X (6.5.30, 6.5.22 (see troubleshooting below) tested)
* Mips4 CPU (mips3 is a supported _target_ - but to build you need mips4)
* Mipspro 7.4.4m
* System perl (/usr/bin/perl)
* System tar (/sbin/tar)
* Roughly 20Gb diskspace
* Minimum of ~2Gb of RAM
* Beefy CPU if you want to build everything (2*600mhz min)
* A previously extracted didbs release >= 0.1.6-n32-m3mp (n32, mips3, MIPSpro)

If you are looking for an already built didbs release - didbs releases are posted on the SGUG (Silicon Graphics User Group) forums in the development section [here](https://forums.sgi.sh/).

Suggested approach:

(1) Do everything as your user, I do not recommend use of root or installing into /usr/local or other existing directories. If you have to do things as root, I consider that a bug!

(Example for n32, mips3, mipspro)
```
* As root
* Create /usr/didbs
* chown myuser:people /usr/didbs # (have to do this as root, of course)
* As your user
* Extract previous didbs release
* cd /usr/didbs; tar xf usr-didbs-0.1.6-n32m3mp.tar.gz
* Link up a "current"
* cd /usr/didbs; ln -s 0_1_6_n32_mips3_mp current
* (Setup paths to include the bin and lib32 of the above)
* cd ~; git clone https://github.com/danielhams/didbs.git
* cd ~/didbs
* echo "DIDBS_JOBS=N" >overrideenv.vars
* For above, set the DIDBS_JOBS to CPU+1, or just one if RAM is < 512Mb
* ./bootstrap.pl -p /usr/didbs/0_1_package -b /usr/didbs/0_*_*_n32_mips3_mp_build -i /usr/didbs/0_*_*_n32_mips3_mp -e n32 -a mips3 -c mipspro # (replace * - this sets up paths)
* ./bootstrap.pl # (This builds the stage1 then release packages)
```

## Using the installed tools

You'll need to setup your environment to pull the right directories (bash example):

```
* export PATH=/usr/didbs/0_*_*_n32_mips3_mp/bin:$PATH
* export LD_LIBRARYN32_PATH=/usr/didbs/0_*_*_n32_mips3_mp/lib32:$LD_LIBRARYN32_PATH
* export PKG_CONFIG_PATH=/usr/didbs/0_*_*_n32_mips3_mp/lib32/pkgconfig:$PKG_CONFIG_PATH

If you want to use the included gcc(4|5|8|9) - after building they may be found here (so add to PATH and LD_LIBRARYN32_PATH as well):

gcc4 actual -> /usr/didbs/0_*_*_n32_mips3_mp/gbs4_2

gcc5 actual -> /usr/didbs/0_*_*_n32_mips3_mp/gbs5_0
(gcc5 is a special case, and requires the gcc4 paths afterwards to pick up the binutils/gdb there)

gcc8 actual -> /usr/didbs/0_*_*_n32_mips3_mp/gbs8_1

gcc9 actual -> /usr/didbs/0_*_*_n32_mips3_mp/gbs9_1
```

## Troubleshooting

Getting a bunch of errors? If you have issues with headers, it's maybe a mismatch of version and you may need to regenerate the GCC "fixed" headers. If you are building on IRIX 6.5.22 you need to rebuild the headers for GCC since didbs was built on a 6.5.30 system. Once the headers are updated builds are fine on 6.5.22.

Info here: https://gcc.gnu.org/onlinedocs/gcc/Fixed-Headers.html

To find the mkheaders script a command like this (from /usr/didbs/current) will located them:

```
/usr/didbs/current $ find . -name mkheaders
./gbs4_2/libexec/gcc/mips-sgi-irix6.5/4.8.2/install-tools/mkheaders
./gbs5_0/libexec/gcc/mips-sgi-irix6.5/5.4.0/install-tools/mkheaders
./gbs8_1/libexec/gcc/mips-sgi-irix6.5/8.2.0/install-tools/mkheaders
./gbs9_1/libexec/gcc/mips-sgi-irix6.5/9.2.0/install-tools/mkheaders
/usr/didbs/current $ 

```
Now move into the gcc version you want to update and run the mkheaders script from the install-tools directory. Once it's done go building.

## How to Do Stuff

### Enable extra goodies in didbs.
* go to the package directory of the target goodie (in this sample say `sudo`)
* edit the sudo.packagedef file
* change disabled=1 to 0 (it should be a 1 to indicate not to build on bootstrap)
* save file
* back in the main didbs repo directory a `./boostrap.pl --dryrun` should indicate it will be built

```
2019-10-25 00:43:23.676 Checking status of package sudo...
2019-10-25 00:43:23.678 This package (sudo) is marked untested, please do the tests.
2019-10-25 00:43:23.679   Package needs building...
```

* execute the `bootstrap.pl` command to build and install your new package.



eof



