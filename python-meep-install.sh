#!/bin/bash
"""
Setting up the electromagnetic simulation environment based on MEEP 
(http://ab-initio.mit.edu/wiki/index.php/Meep) is not straightforward. 
I have spent several days making the simulation work on different 
32/64-bit systems, use HDF5 libraries with multiprocessing support 
etc., and this experience has motivated the publication of this script.

It should automatically install MEEP, Python-meep and related 
programs/libraries at different linux distributions.  If you are 
interested in starting with python-meep, you may wish to try the example 
scripts: https://github.com/FilipDominec/python-meep-utils

(c) Filip Dominec 2013-2018, licensed under GPL-2.0
"""

## --- Settings ---------------------------------------------------------------
PYTHON="python"		# for python2, well tested on Ubuntu, not working on Fedora28 (scipy.weave missing)
#PYTHON="python3"		# for python3, fails on 'PyFile_Check was not declared in this scope' error, but the right way to go in the future

MPI="openmpi"
#MPI="mpich"
#MPI="mpich2"
#MPI="serial"        ## i.e. no multiprocessing used

## --- Preparation and build dependencies -------------------------------------
if [ "$MPI" = "openmpi" ] || [ "$MPI" = "mpich" ] || [ "$MPI" = "mpich2" ] ; then meep_opt="--with-mpi"; fi

debian=
redhat=
## Switch installation commands between Debian-based systems and RPM-based systems
if [ -d /etc/apt ]; then
	debian=1
	#Debian System - use apt-get package manager]
	echo "Selecting Debian Mode"
    INSTALL="sudo apt-get -y install"
    sudo apt-get update
fi 
if [ -e /etc/redhat-release ]; then 
	redhat=1
	#Override a possible mis-detection of the platform due to the presence 
	#of the /etc/apt folder on a red hat-based system
	#Red hat system - use either dnf (more recent) or yum (legacy) package managers
	echo "Selecting Red Hat Mode"
	if [ -d /etc/dnf ]; then
		INSTALL="sudo dnf -y install"
	else
		INSTALL="sudo yum -y install"
	fi
fi
if [ -z "$INSTALL" ]; then
	echo "ERROR IN PLATFORM DETECTION: Could not select correct package manager. Exiting." >&2 
	exit 1
fi

$INSTALL autoconf chrpath debhelper libtool swig wget 
$INSTALL git          ## on newer linux versions
$INSTALL git-core     ## for old ubuntu 10.04

if [ -n "$debian" ]; then 
    $INSTALL autotools-dev          g++    gfortran         
    $INSTALL h5utils 
    $INSTALL imagemagick            libatlas-base-dev libfftw3-dev libgsl0-dev liblapack-dev # mpb-dev  ## TODO mpb needs recomp w/ -fPIC
    $INSTALL libharminv-dev pkg-config  ## these are missing in RPM?
    $INSTALL zlib1g-dev
	## for newer linux versions -- or if fails -- for old ubuntu 10.04

	## guile 2.0.13 made meep-mpi fail (reported 2017-06-16 by J Weiner)
	$INSTALL guile-2.0-dev || $INSTALL guile-1.8-dev		## Experimental, may the repository version still be OK?
	#$INSTALL guile-2.0-dev=2.0.11* || $INSTALL guile-1.8-dev || compile_guile_manually=1	
	#if [ -n "$compile_guile_manually" ]; then 
		#echo "INSTALLING GUILE 2.0.11 FROM GIT REPOSITORY"
		#$INSTALL flex libgmp-dev libunistring-dev libltdl-dev libgc-dev libffi-dev libtool-bin texinfo
		#git clone https://github.com/cky/guile
		#pushd guile/
		#git checkout 972fb41 ## crucial: change to the commit when the 2.0.11 version was released
		#./autogen.sh 
		#./configure && make && make install
		#popd
	#fi

    $INSTALL $MPI-bin lib$MPI-dev libhdf5-$MPI-dev              
elif [ -n "$redhat" ]; then
	#h5utils, harminv, and meep(-non-mpi) can be installed from Fedora COPR on Fedora 22 or better
	#On Fedora 23: 
	#dnf copr enable hmaarrfk.meep
	#dnf install meep
	#dnf install h5utils
    $INSTALL automake autoconf     gcc-c++      gcc-gfortran     ## fixme: autoconf dupli?
    echo "TODO: h5utils must be compiled on Fedora!"
    $INSTALL ImageMagick        atlas-devel    fftw3-devel     gsl-devel lapack-devel		
    #echo "TODO: MPB devel libs must be (probably) compiled on Fedora!"    
	#$INSTALL mpb-devel   ## TODO mpb needs recomp w/ -fPIC,  but not tested on Fedora
    echo "TODO: harminv must be (probably) compiled on Fedora!"    
    $INSTALL pkgconfig	# already present in Fedora28?
    $INSTALL zlib-devel
    $INSTALL guile-devel
    $INSTALL $MPI $MPI-devel hdf5-$MPI-devel
else
    echo "Invalid Platform." >&2
    exit 1
fi

##   for Ubuntu 15.04: fresh libctl 3.2.2 is in repository and we can use it
# $INSTALL libctl-dev                            
## for Ubuntu <= 14.04, or other distros:  the version of `libctl-dev' in repository is too old, needs a fresh compile:
if [ ! -d "libctl-3.2.1" ]; then
	wget http://ab-initio.mit.edu/libctl/libctl-3.2.1.tar.gz
	tar xzf libctl-3.2.1.tar.gz
fi
cd libctl-3.2.1/
./configure LIBS=-lm  &&  make  &&  sudo make install
cd ..

## --- MEEP (now fresh from github!) --------------------------------------------
export CFLAGS=" -fPIC"; export CXXFLAGS=" -fPIC"; export FFLAGS=" -fPIC"  ## Position Independent Code, needed on 64-bit
if [ -d /etc/apt ]; then
    export CPPFLAGS="-I/usr/local/include -I/usr/include/hdf5/$MPI"
    export LDFLAGS="-L/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/hdf5/$MPI"
    export LD_RUN_PATH="/usr/local/lib"
else
    echo "TODO: enable HDF5 libraries for RPM distros"
    PATH=$PATH:/usr/local/bin
    export CPPFLAGS="-I/usr/local/include -I/usr/include/hdf5/$MPI"    
    export LDFLAGS="-L/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/hdf5/$MPI"
    export LD_RUN_PATH="/usr/local/lib:/usr/lib64/openmpi/lib"
fi

## Note: If the git version was unavailable, use the failsafe alternative below
if [ ! -d "meep" ]; then git clone https://github.com/filipdominec/meep; fi   ## FD's branch, see github
#if [ ! -d "meep" ]; then git clone https://github.com/stevengj/meep; fi      ## official branch
cd meep/
if [ -n "$debian" ] || [ "$MPI" = "serial" ]; then
	./autogen.sh $meep_opt --enable-maintainer-mode --enable-shared --prefix=/usr/local  # exits with 1 ?
else	
	#Fedora (at least) requires the MPI compiler definitions. 
	CC=/lib64/$MPI/bin/mpicc CXX=/lib64/$MPI/bin/mpicxx F77=/lib64/$MPI/bin/mpif77 ./autogen.sh $meep_opt --enable-maintainer-mode --enable-shared --prefix=/usr/local  # exits with 1 ?
fi

make  &&  sudo make install
cd ..

## failsafe alternative if git not working: download the 1.2.1 sources (somewhat obsoleted)
#if [ ! -d "meep" ]; then wget http://ab-initio.mit.edu/meep/meep-1.3.tar.gz && tar xzf meep-1.3.tar.gz && mv meep-1.3 meep; fi
#cd meep/
#./configure $meep_opt --enable-maintainer-mode --prefix=/usr/local  &&  make  &&  sudo make install
# # --enable-shared 
#cd ..

## --- ${PYTHON}-meep ------------------------------------------------------------
## note: if you are interested in the scheme interface of meep only, you may 
## make the compilation a bit faster by deleting all following lines

## install ${PYTHON}-meep dependencies and swig
if [ -n "$debian" ]; then
	$INSTALL ${PYTHON}-dev	${PYTHON}-numpy ${PYTHON}-scipy ${PYTHON}-matplotlib ${PYTHON}-argparse
else
	$INSTALL ${PYTHON}-devel ${PYTHON}-numpy ${PYTHON}-scipy ${PYTHON}-matplotlib redhat-rpm-config
	# based on some searching, argparse appears to be included in the default python3 package on fedora? ${PYTHON}-argparse
	sudo ldconfig /usr/lib64/openmpi/lib/
fi

## Get the latest source from green block at https://launchpad.net/${PYTHON}-meep/1.4
if [ ! -d "python-meep" ]; then
    if [ ! -f "python-meep-1.4.2.tar" ]; then
	    wget https://launchpad.net/python-meep/1.4/1.4/+download/python-meep-1.4.2.tar
    fi
    tar xf python-meep-1.4.2.tar
fi

## Since we chose to install libmeep*.so to /usr/local/lib, this script has to modify the installation scripts (aside
## from passing the "-I" and "-L" parameters to the build script).
cd python-meep/
pm_opt=`echo $meep_opt | sed 's/--with//g'`

## Remove dependencies required for access of the LDOS computation so they are not added multiple times (Diego Caraffini)
## suggested by https://github.com/bonderado/python-meep-install/commit/e1dfc7adfdc4d6a1d80be0f7bc3f5f935dc0f57e
sed -i -e '/^\t/d'  `echo ./meep${pm_opt}.i | sed s/-/_/`

## Add dependencies required for access of the LDOS computation (this may require further fixes to yield useful data) TODO test this again?
sed -i -e '/meep-site-init/i\
	%include "cpointer.i"\
	%pointer_functions(double ,doubleP) \/* added by FDominec to enable access to LDOS computation results *\/\
	%include "carrays.i"\
	%array_functions(double, doubleArray); ' `echo ./meep${pm_opt}.i | sed s/-/_/`

sed -i -e 's:MPI:non-MPI:g' ./meep.i ## this was a clear bug in python-meep
sed -i -e 's:/usr/lib:/usr/local/lib:g' -e 's:/usr/include:/usr/local/include:g' ./setup${pm_opt}.py
sed -i -e '/custom.hpp/ a export LD_RUN_PATH=$LD_RUN_PATH:\/usr\/local\/lib' make${pm_opt}
sed -i -e 's/#global/global/g' -e 's/#DISABLE/DISABLE/g' -e 's/\t/    /g'  meep-site-init.py
## Newer versions of SWIG changed syntax rules and complained about "Unknown SWIG preprocessor directive" if the comment was left 
sed -i -e '/initialisations/d' meep-site-init.py

## TODO for pyhton3  adapt:
##   1) make, make-mpi				with:   s/^\./python3 ./g
##   2) setup.py, setup-mpi.py		with:   s/print \(.*)/print(\1)/g
if [ "$PYTHON"  -e  "python3" ]; then
	sed -i -e 's/^\./python3 ./g' ./make			## TODO test effect of this with py3
	sed -i -e 's/^\./python3 ./g' ./make-mpi		## TODO test effect of this with py3
	sed -i -e 's/print \(.*)/print(\1)/g' ./setup.py			## TODO test effect of this with py3
	sed -i -e 's/print \(.*)/print(\1)/g' ./setup-mpi.py		## TODO test effect of this with py3
fi 
## TODO   3) for py3 fix another error:  meep_mpi_wrap.cpp:4474:9: error: 'PyFile_Check' was not declared in this scope
##			 see also 

sudo ./make${pm_opt} -I/usr/local/include -L/usr/local/lib 

