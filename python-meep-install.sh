#!/bin/bash
## This is a compilation procedure that worked for me to setup the python-meep 
## with some utilities on a Debian-based system.

## --- Settings ---------------------------------------------------------------
meep_opt="--with-mpi";			## comment out if no multiprocessing is used


## --- Build dependencies -----------------------------------------------------
## (list obtained from https://launchpad.net/ubuntu/quantal/+source/meep)
sudo apt-get update
sudo apt-get install -y autotools-dev autoconf chrpath debhelper gfortran \
    g++ git guile-2.0-dev h5utils imagemagick libatlas-base-dev libfftw3-dev libgsl0-dev \
    libharminv-dev libhdf5-openmpi-dev liblapack-dev libtool pkg-config swig  zlib1g-dev

## the version of `libctl-dev' from repository is too old (tested at Ubuntu 14.04, or older) 
wget http://ab-initio.mit.edu/libctl/libctl-3.2.1.tar.gz
tar xzf libctl* && cd libctl-3.2.1/
./configure LIBS=-lm  &&  make  &&  sudo make install
cd ..

## --- MEEP (now fresh from github!) --------------------------------------------
## Skip this line if no multiprocessing used (also install correct libhdf5-*-dev)
sudo apt-get -y install openmpi-bin libopenmpi-dev

export CFLAGS=" -fPIC"; export CXXFLAGS=" -fPIC"; export FFLAGS=" -fPIC"  ## Position Independent Code, needed on 64-bit
export CPPFLAGS="-I/usr/local/include"									 ## install everything into /usr/local to prevent overwrite
export LD_RUN_PATH="/usr/local/lib"

## Note: If the git version was unavailable, use the failsafe alternative below
#if [ ! -d "meep" ]; then git clone https://github.com/filipdominec/meep; fi   ## FD's branch, see github
if [ ! -d "meep" ]; then git clone https://github.com/stevengj/meep; fi
cd meep/
./autogen.sh $meep_opt --enable-maintainer-mode --enable-shared --prefix=/usr/local  # exits with 1 ?
make  &&  sudo make install
cd ..

## Failsafe alternative if git not working: download the 1.2.1 sources (somewhat obsoleted)
#if [ ! -d "meep" ]; then wget http://ab-initio.mit.edu/meep/meep-1.3.tar.gz && tar xzf meep-1.3.tar.gz && mv meep-1.3 meep; fi
#cd meep/
#./configure $meep_opt --enable-maintainer-mode --enable-shared --prefix=/usr/local  &&  make  &&  sudo make install
#cd ..

## --- PYTHON-MEEP ------------------------------------------------------------
## Install python-meep dependencies and SWIG
sudo apt-get install python-dev python-numpy python-scipy -y

## Get the latest source from green block at https://launchpad.net/python-meep/1.4
if [ ! -d "python-meep" ]; then
	wget https://launchpad.net/python-meep/1.4/1.4/+download/python-meep-1.4.2.tar
	tar xf python-meep-1.4.2.tar
fi

## If libmeep*.so was installed to /usr/local/lib, this scipt has to edit the installation scripts (aside
## from passing the "-I" and "-L" parameters to the build script).
cd python-meep/
pm_opt=`echo $meep_opt | sed 's/--with//g'`
sed -i -e 's:/usr/lib:/usr/local/lib:g' -e 's:/usr/include:/usr/local/include:g' ./setup${pm_opt}.py
sed -i -e '/custom.hpp/ a export LD_RUN_PATH=\/usr\/local\/lib' make${pm_opt}
sed -i -e 's/#global/global/g' -e 's/#DISABLE/DISABLE/g' -e 's/\t/    /g'  meep-site-init.py
sudo ./make${pm_opt} -I/usr/local/include -L/usr/local/lib

