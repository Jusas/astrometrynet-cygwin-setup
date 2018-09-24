@ECHO OFF
REM -- Automates cygwin installation

SETLOCAL

REM -- Change to the directory of the executing batch file
CD %~dp0

REM -- Configure our paths
SET SITE=http://mirrors.kernel.org/sourceware/cygwin/

SET /p LOCALDIR="Set Cygwin download temp dir: "
SET /p ROOTDIR="Set Cygwin installation dir: "



REM SET LOCALDIR=C:/cygwin-temp
REM SET ROOTDIR=C:/cygwintest
SET SETUP_URL=https://cygwin.com/setup-x86_64.exe
SET SETUP_EXE=setup-cygwin.exe

curl -o %SETUP_EXE% %SETUP_URL%

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=clang,wget,cmake,gcc-core,gsl,libX11-xcb-devel,libXdamage-devel,libXdamage1,libcairo-devel,libgsl-devel
SET PACKAGES=%PACKAGES%,libgsl0,libgsl19,libjpeg-devel,libjpeg8,libnetpbm-devel,libnetpbm10,libpcre-devel
SET PACKAGES=%PACKAGES%,libpixman1-devel,libxcb-glx-devel,libzip-devel,libzip2,make,netpbm,pkg-config,python2-devel
SET PACKAGES=%PACKAGES%,python2-numpy,swig,zlib-devel

REM -- Do it!
ECHO *** INSTALLING PACKAGES
%SETUP_EXE% -q -D -L -d -g -o -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -C Base -P %PACKAGES%

REM -- Show what we did
ECHO.
ECHO.
ECHO cygwin installation updated
ECHO  - %PACKAGES%
ECHO.

ENDLOCAL

PAUSE
EXIT /B 0