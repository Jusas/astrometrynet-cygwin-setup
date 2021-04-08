#!/bin/bash

# Install astrometry.net deps and astrometry.net to Cygwin.

usage() { 
  echo
  echo "---------------------------------------"
  echo "astrometry.net Cygwin installer"
  echo "---------------------------------------"
  echo
  echo "Usage: $0 [-a <0|1>] [-i <string> -d <path>]"
  echo 
  echo "Alternatively: $0 \$(< argsfile)"
  echo
  echo "This script installs astrometry.net to your Cygwin"
  echo "installation. It downloads the needed dependencies,"
  echo "compiles what is needed and also downloads astrometry"
  echo "index files of your choosing and updates astrometry.net"
  echo "configuration accordingly."
  echo
  echo "Parameters:"
  echo "<0|1> means no/yes, ie. '-a 1' means 'install astrometry.net'"
  echo
  echo "  -a   install astrometry.net v0.85 and its dependencies."
  echo "         Optional. If omitted, it will not be installed."
  echo "  -i   download astrometry.net index files, a comma separated"
  echo "         string with index scale numbers, from 0 to 19,"
  echo "         eg. '-i 4,5,6,7,8'. Optional. If omitted, no"
  echo "         index files will be downloaded"
  echo "  -d   index file download directory, this path will also"
  echo "         be written to astrometry.cfg. If omitted, files"
  echo "         will be downloaded by default to ./indexes"
  echo
  echo "Index files (index-42xx.fits) in CCD FoV:"
  echo
  echo "19: [0.1 MB] 1400-2000 arcsec (23-33 deg)"
  echo "18: [0.2 MB] 1000-1400 arcsec (16-23 deg)"
  echo "17: [0.2 MB] 680-1000 arcsec (11-16 deg)"
  echo "16: [0.3 MB] 480-680 arcsec (8-11 deg)"
  echo "15: [0.6 MB] 340-480 arcsec (5.6-8.0 deg)"
  echo "14: [1.0 MB] 240-340 arcsec (4.0-5.6 deg)"
  echo "13: [2.1 MB] 170-240 arcsec (2.8-4.0 deg)"
  echo "12: [4.1 MB] 120-170 arcsec (2.0-2.8 deg)"
  echo "11: [7.8 MB] 85-120 arcsec (1.4-2.0 deg)"
  echo "10: [20.0 MB] 60-85 arcsec (1.0-1.4 deg)"
  echo " 9: [40.2 MB] 42-60 arcsec (0.7-1.0 deg)"
  echo " 8: [79.9 MB] 30-42 arcsec (0.5-0.7 deg)"
  echo " 7: [165.4 MB] 22-30 arcsec (0.4-0.5 deg)"
  echo " 6: [328.3 MB] 16-22 arcsec (0.3-0.4 deg)"
  echo " 5: [659.0 MB] 11-16 arcsec (0.2-0.3 deg)"
  echo " 4: [1.323 GB] 8-11 arcsec (0.1-0.2 deg)"
  echo " 3: [2.627 GB] 5.6-8.0 arcsec (0.09-0.1 deg)"
  echo " 2: [5.059 GB] 4.0-5.6 arcsec (0.07-0.09 deg)"
  echo " 1: [8.822 GB] 2.8-4.0 arcsec (0.05-0.07 deg)"
  echo " 0: [13.557 GB] 2.0-2.8 arcsec (0.03-0.05 deg)"
  echo
}

if [ "$1" == "--help" ]; then
  usage
  exit 0
fi

INST_ASTROMETRYNET=
INST_INDEXES=
INST_INDEXDIR="./indexes"

while getopts a:i:d: option
do
  case "${option}"
  in
    a) INST_ASTROMETRYNET=${OPTARG};;
    i) INST_INDEXES=${OPTARG};;
    d) INST_INDEXDIR=${OPTARG};;
    *) usage;;
  esac
done

# Make an array out of the comma separated list
IFS=','
INST_INDEXES_ARR=($INST_INDEXES)
unset IFS;

function install_astrometry() {

  echo "Installing astrometry.net..."
  echo "- will install PIP"
  echo "- will install CFITSIO"
  echo "- will install WCSLIB"
  echo "- will install astrometry.net"

  export NETPBM_LIB="-L/usr/lib -lnetpbm"
  export NETPBM_INC="-I/usr/include/netpbm"

  # PIP and astropy
  curl https://bootstrap.pypa.io/get-pip.py | python
  pip install astropy

  # CFITSIO
  curl -L -o cfitsio.tgz http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3450.tar.gz
  tar zxvf cfitsio.tgz
  ( cd cfitsio && ./configure --prefix=/usr && make && make install )

  # WCSLIB  
  curl -L -o wcslib.tar.bz2 ftp://ftp.atnf.csiro.au/pub/software/wcslib/wcslib-5.19.1.tar.bz2
  tar xf wcslib.tar.bz2
  ( cd wcslib-5.19.1 && ./configure LIBS="-pthread -lm" --without-pgplot --disable-fortran --prefix=/usr && make && make check && make install )

  # Astrometry.net
  curl -L -o astrometry.tgz http://astrometry.net/downloads/astrometry.net-0.85.tar.gz
  tar zxvf astrometry.tgz
  ( cd astrometry.net-0.85 && make && make py && make extra && make install INSTALL_DIR=/usr )

}

function download_indexes() {
  
  echo "Installing astrometry indexes..."
  echo "- Downloading astrometry.net indexes to:"
  echo "    ${INST_INDEXDIR}"
  echo "- Indexes to download:"
  for i in "${INST_INDEXES_ARR[@]}"
  do
    printf "    index-42%02d*.fits\n" $i
  done
  echo "- Will update /usr/etc/astrometry.cfg"

  # indexes 8-19 = 1 file each
  # indexes 5-7 = 12 files each
  # indexes 0-4 = 48 files each
  data_url="http://data.astrometry.net/4200"
  totalFileCount=0

  echo "Ensuring directory ${INST_INDEXDIR} exists..."
  mkdir -p "${INST_INDEXDIR}"

  for i in "${INST_INDEXES_ARR[@]}"
  do
    if [ "$i" -ge "8" ]; then
      totalFileCount=$((totalFileCount+1))
    fi
    if [ "$i" -ge "5" ] && [ "$i" -le "7" ]; then
      totalFileCount=$((totalFileCount+12))
    fi
    if [ "$i" -ge "0" ] && [ "$i" -le "4" ]; then
      totalFileCount=$((totalFileCount+48))
    fi
  done

  echo "Total files to download: ${totalFileCount}"
  echo
  fcount=0

  for i in "${INST_INDEXES_ARR[@]}"
  do
    idx=$(printf %02d ${i})
    if [ "$i" -ge "8" ]; then
      fcount=$((fcount+1))
      fits="${data_url}/index-42${idx}.fits";
      echo "(${fcount}/${totalFileCount}) Downloading ${fits}"
      if ! output=$(wget -q --show-progress -P ${INST_INDEXDIR} -c ${fits}); then
        echo "WARNING: download of an index file failed - continuing"
      fi
    fi
    if [ "$i" -ge "5" ] && [ "$i" -le "7" ]; then
      idx_list=($(seq -s" " -w 0 11))
      for n in "${idx_list[@]}"
      do
        fcount=$((fcount+1))
        fits="${data_url}/index-42${idx}-${n}.fits";
        echo "(${fcount}/${totalFileCount}) Downloading ${fits}"
        if ! output=$(wget -q --show-progress -P ${INST_INDEXDIR} -c ${fits}); then
          echo "WARNING: download of an index file failed - continuing"
        fi
      done
    fi
    if [ "$i" -ge "0" ] && [ "$i" -le "4" ]; then
      idx_list=($(seq -s" " -w 0 47))
      for n in "${idx_list[@]}"
      do
        fcount=$((fcount+1))
        fits="${data_url}/index-42${idx}-${n}.fits";
        echo "(${fcount}/${totalFileCount}) Downloading ${fits}"
        if ! output=$(wget -q --show-progress -P ${INST_INDEXDIR} -c ${fits}); then
          echo "WARNING: download of an index file failed - continuing"
        fi
      done
    fi
  done

  added_paths=($(sed -n '/add_path/p' /usr/etc/astrometry.cfg))
  index_path_added=0
  index_path="${INST_INDEXDIR}"
  for path in "${added_paths[@]}"
  do
    if [ "$path" == "$index_path" ]; then
      index_path_added=1
      break
    fi
  done

  if [ "$index_path_added" == "0" ]; then
    echo "Adding index path to /usr/etc/astrometry.cfg"
    echo "add_path ${index_path}" >> /usr/etc/astrometry.cfg
  fi

  echo "Download of indexes complete"
}


## Do stuff

if [ "${INST_ASTROMETRYNET}" == "1" ]; then
  install_astrometry
fi

if [ ! -z "${INST_INDEXES}" ]; then
  download_indexes
fi
