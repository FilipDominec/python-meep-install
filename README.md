# python-meep-install
Setting up the electromagnetic simulation environment based on MEEP (http://ab-initio.mit.edu/wiki/index.php/Meep) is not straightforward.

This script should automatically install MEEP, Python-meep and related programs/libraries at different linux distributions.

It will hopefully be updated to reflect future changes in the linux distributions.


# Invocation 
You can simply run the 'python-meep-install.sh' script as root

If you wish to contribute with the installation output, use e.g.:
'''sudo ./python-meep-install.sh | tee your-system-version.log

The easiest way to upload the log is to open a new issue. Thank you!

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

