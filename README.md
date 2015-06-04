# python-meep-install
Experiments with the installation of latest MEEP and python-meep, failing to compile with HDF5 on 2014+ linux

# The problem
Compilation of MEEP on Debian Jessie, Ubuntu 14.10 or 15.04 can not bind to the HDF5 libraries. At older systems, everything worked fine.

The error is first found in the ./autogen.sh output:
'''checking for H5Pcreate in -lhdf5... no

# Invocation 
Please log the compilation output, e.g.:
'''sudo ./python-meep-install.sh | tee ubuntu-vivid.log

Then you can commit all files to take a record of both the input stript and its output.
