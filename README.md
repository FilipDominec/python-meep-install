# Overview of python-meep-install
Setting up the electromagnetic simulation environment based on MEEP (http://ab-initio.mit.edu/wiki/index.php/Meep) is not straightforward. Author has spend many days making the simulation work on different 64-bit systems, use HDF5 libraries, multiprocessing etc., and this experience has motivated the publication of this script.

It should automatically install MEEP, Python-meep and related programs/libraries at different linux distributions.

# Use
### Invocation 
You can simply run the 'python-meep-install.sh' script as root

If you wish to contribute with the installation output, use e.g.:
'''sudo ./python-meep-install.sh 2>&1 | tee your-system-version.log
The easiest way to upload the log is perhaps to paste it into a comment. Thank you!

If everything works and you can 'import meep_mpi' in your Python2 console, do not forget there are practical examples of its use at 
https://github.com/FilipDominec/python-meep-utils

### Settings 
By editing the 'python-meep-install.sh' script, you can choose
* whether multiprocessing is supported, and which implementation of the Message-Passing Protocol will be used (openmpi|mpich|mpich2|none)

# Supported systems
### Tested on:
* Ubuntu 12.10 14.10 15.04 15.10amd64 16.04amd64 17.04amd64
* Debian Jessie

### Experimental/partially working:
* Fedora (and other RPM-based systems)
  * (?) optional library 'harminv' is missing, can be manually compiled if needed
  * (?) dependency 'pkg-config' is missing,
* The eigenmode source requires the 'mpb-dev' package, which is not available in Ubuntu 15.04 or earlier. You can still download the source and compile MPB on older systems, but in such a case, make sure you use the '-fPIC' option to enable its use with MEEP.

### Known not to work on:

# Possible issues
* When installation crashes, it does at the end. You have to track what of the many steps failed.  
* Downloading of libctl-3.2.1.tar.gz seems to hang for several minutes sometimes (May 2017). Not a serious trouble.
* Sometimes the apt-get installer refuses to work, reporting either that "the dpkg database is locked" or that it "can not find the source code for ...". I guess this is due to the updater launching during the run of the installation script. It may help to re-run the script again.
