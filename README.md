# astrometrynet-cygwin-setup

A collection of Scripts to quickly install 64bit Cygwin with astrometry.net on it.

## scripts/installcygwin.bat

This script installs Cygwin with all prerequisite packages for compiling astrometry.net.
It prompts you for two parameters:

1. The download temp directory (where the setup downloads packages)
2. The Cygwin installation directory

The installation is then automatic.

__Note: the script uses curl which nowadays comes with Windows 10 to download the installer .exe, so if you're running an older Windows__
__you probably need to change it to use Powershell commands or something.__

## scripts/installastrometry.sh

Once you've got Cygwin installed, run this script after copying it to your cygwin home directory (or where ever you want).
It does several things:

1. It downloads all the required files.
2. It compiles/installs the prerequisite libraries that astrometry.net needs (namely CFITSIO, WCSLIB, astropy)
3. It compiles/installs astrometry.net from its source package.
4. It downloads the astrometry index files for the solver to actually work.

The script is run with the following arguments:

```
   Usage: ./installastrometry.sh [-a <0|1>] [-i <string> -d <path>]
   
   Alternatively: ./installastrometry.sh $(< argsfile)
  
   This script installs astrometry.net to your Cygwin
   installation. It downloads the needed dependencies,
   compiles what is needed and also downloads astrometry
   index files of your choosing and updates astrometry.net
   configuration accordingly.
  
   Parameters:
   <0|1> means no/yes, ie. '-a 1' means 'install astrometry.net'
  
     -a   install astrometry.net v0.76 and its dependencies.
            Optional. If omitted, it will not be installed.
     -i   download astrometry.net index files, a comma separated
            string with index scale numbers, from 0 to 19,
            eg. '-i 4,5,6,7,8'. Optional. If omitted, no
            index files will be downloaded
     -d   index file download directory, this path will also
            be written to astrometry.cfg
  
   Index files (index-42xx.fits) in CCD FoV:
  
   19: [0.1 MB] 1400-2000 arcsec (23-33 deg)
   18: [0.2 MB] 1000-1400 arcsec (16-23 deg)
   17: [0.2 MB] 680-1000 arcsec (11-16 deg)
   16: [0.3 MB] 480-680 arcsec (8-11 deg)
   15: [0.6 MB] 340-480 arcsec (5.6-8.0 deg)
   14: [1.0 MB] 240-340 arcsec (4.0-5.6 deg)
   13: [2.1 MB] 170-240 arcsec (2.8-4.0 deg)
   12: [4.1 MB] 120-170 arcsec (2.0-2.8 deg)
   11: [7.8 MB] 85-120 arcsec (1.4-2.0 deg)
   10: [20.0 MB] 60-85 arcsec (1.0-1.4 deg)
    9: [40.2 MB] 42-60 arcsec (0.7-1.0 deg)
    8: [79.9 MB] 30-42 arcsec (0.5-0.7 deg)
    7: [165.4 MB] 22-30 arcsec (0.4-0.5 deg)
    6: [328.3 MB] 16-22 arcsec (0.3-0.4 deg)
    5: [659.0 MB] 11-16 arcsec (0.2-0.3 deg)
    4: [1.323 GB] 8-11 arcsec (0.1-0.2 deg)
    3: [2.627 GB] 5.6-8.0 arcsec (0.09-0.1 deg)
    2: [5.059 GB] 4.0-5.6 arcsec (0.07-0.09 deg)
    1: [8.822 GB] 2.8-4.0 arcsec (0.05-0.07 deg)
    0: [13.557 GB] 2.0-2.8 arcsec (0.03-0.05 deg)
```

So for example, to install astrometry.net, and download indexes 9-19 to /opt/astrometry-indexes, you'd run:

```
   ./installastrometry.sh -a 1 -i 9,10,11,12,13,14,15,16,17,18,19 -d /opt/astrometry-indexes
```

Go grab a cup of coffee, the install will take a few minutes as it needs to compile the libraries
and the astrometry.net suite itself (and of course download the indexes).
Once it's all done, `solve-field` should run and plate solving can begin...

# Why?

Because there was no easy way to install it all before, and I wanted to make it happen.
With a little refinement these scripts can be used to install the plate solver in Windows for 
whatever purposes you like. If you don't want to distribute the whole shebang of 300+ MB of Cygwin
plus astrometry index files as a single package, now you don't necessarily have to.

This may later be refined to include an executable/installer that can do the whole thing graphically 
with just a few clicks.

# License

MIT license applies, have fun!
