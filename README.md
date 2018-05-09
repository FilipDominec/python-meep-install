# Important note:
As of 2017, the compilation script was reported to fail on Ubuntu 17.04 due to numpy API deprecation. 

I recommend to try the new official guide at https://meep.readthedocs.io/en/latest/Build_From_Source/#building-from-source

----	

# Overview of python-meep-install
Setting up the electromagnetic simulation environment based on MEEP (http://ab-initio.mit.edu/wiki/index.php/Meep) is not straightforward. Author has spent several days making the simulation work on different 32/64-bit systems, use HDF5 libraries with multiprocessing support etc., and this experience has motivated the publication of this script.

It should automatically install MEEP, Python-meep and related programs/libraries at different linux distributions. 

# Use
### Invocation 
On supported systems, you can simply run the 'python-meep-install.sh' script as root, and after 5-10 minutes you should get a working environment.

If everything works and you can 'import meep_mpi' in your Python2 console, do not forget there are practical examples of its use at https://github.com/FilipDominec/python-meep-utils

### Testing and debugging 
If you wish to file a bug report, it is important to record the whole output of the installation script. To this end, call it as such:

    sudo ./python-meep-install.sh 2>&1 | tee logs/`date +%y%m%d`-`lsb_release -sd | tr ' ' '_' `-`uname -m`.log

You may either attach the file to an e-mail to the author, or start a new issue on github. Your contribution will be welcome!

### User options 
By editing the ```--- Settings -----``` section in the 'python-meep-install.sh' script, you can choose which implementation of the MPI protocol will be used (```openmpi```, ```mpich```, ```mpich2```), or choose ```none``` to disable multiprocessing.

There is a good chance to make it compile python-meep for Python3 instead of the default Python2, but I did not test it thoroughly enough. 

# System compatibility:
### Tested to work fully on:
* _Ubuntu_: 12.10, 14.10, 15.04, 15.10 (64-bit)
* _Ubuntu_: 16.04, 16.10, 17.04 (amd64) (these versions had previously issues with guile and friends, they appear to work, however)
* _Debian_ Jessie

### Experimental/partially working:
* _Fedora_ (and other RPM-based systems)
  * (?) optional library 'harminv' is missing, can be manually compiled if needed
  * (?) dependency 'pkg-config' is missing (not known if this is serious)
* Python-meep works also perfectly on Ubuntu 16.04 (64-bit) and 17.04 (64-bit), but the ```meep``` scheme interpreter fails since it is compiled against "too new" version of ```guile``` 2.0.13 (see https://github.com/stevengj/meep/issues/57). Previous Ubuntu versions include ```guile``` 2.0.11 or older, with which ```meep``` (or ```meep-mpi```) work fine.

### Known not to work on:
* Windows+Cygwin: h5utils did not compile correctly due to libpng error? (reported June 2017, triaged)

# Possible issues
* When some installation step fails, you will perhaps notice it at the end of the whole procedure since Python-meep compilation will be missing some dependencies. You will have to compare your compilation output against the files in the ```log/``` directory. 
* The eigenmode source requires the 'mpb-dev' package, which is not available in Ubuntu 15.04 or earlier. You can still download the source and compile MPB on older systems, but in such a case, make sure you use the '-fPIC' compiler option.
* Downloading of libctl-3.2.1.tar.gz seems to hang for several minutes sometimes (May 2017). Not a serious trouble, wait for it.
* Sometimes the apt-get installer refuses to work, reporting either that "the dpkg database is locked" or that it "can not find the source code for ...". I guess this is due to the updater launching during the run of the installation script. It may help to re-run the script again.

