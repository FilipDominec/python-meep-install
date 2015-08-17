# Overview of python-meep-install
Setting up the electromagnetic simulation environment based on MEEP (http://ab-initio.mit.edu/wiki/index.php/Meep) is not straightforward. Author has spend many days making the simulation work on different 64-bit systems, use HDF5 libraries, multiprocessing etc., and this experience has motivated the publication of this script.

It should automatically install MEEP, Python-meep and related programs/libraries at different linux distributions.

# Use
### Invocation 
You can simply run the 'python-meep-install.sh' script as root

If you wish to contribute with the installation output, use e.g.:
'''sudo ./python-meep-install.sh | tee your-system-version.log
The easiest way to upload the log is perhaps to paste it into a comment. Thank you!

If everything works and you can 'import meep_mpi' in your Python2 console, do not forget there are practical examples of its use at 
https://github.com/FilipDominec/python-meep-utils

### Settings 
By editing the 'python-meep-install.sh' script, you can choose
* whether multiprocessing is supported, and which implementation of the Message-Passing Protocol will be used (openmpi|mpich|mpich2|none)

# Supported systems
### Tested on:
* Ubuntu 12.10
* Ubuntu 14.10
* Ubuntu 15.04
* Debian Jessie

Note: The older version of the script on Debian Jessie, Ubuntu 14.10 or 15.04 could not find the relocated HDF5 libraries. At older systems, everything worked fine.
The error is first found in the ./autogen.sh output: '''checking for H5Pcreate in -lhdf5... no
After much trial and error, it was fixed by correct change in the CPPFLAGS and LDFLAGS variables.

### Experimental/partially working:
* Fedora 22  (and other RPM-based systems?)
  * optional library 'harminv' is missing, can be manually compiled if needed
  * dependency 'pkg-config' is missing,

### Known not to work on:

