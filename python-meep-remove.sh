# Set to _mpi if you used a mpi version, leave it empty if not
MPI=_mpi

# == Uninstall procedure == 
echo Removing locally compiled meep
rm /usr/local/bin/meep-mpi
rm /usr/local/include/meep.hpp
rm /usr/local/include/meep/mympi.hpp
rm /usr/local/include/meep/vec.hpp
rm /usr/local/lib/libmeep${MPI}.a
rm /usr/local/lib/libmeep${MPI}.la
rm /usr/local/lib/libmeep${MPI}.so*
rm /usr/local/lib/pkgconfig/meep${MPI}.pc
rm /usr/local/share/meep/casimir.scm
rm /usr/local/share/meep/meep-enums.scm
rm /usr/local/share/meep/meep.scm
echo 'Removing locally compiled python-meep (works for python 2.7)...'
rm /usr/local/lib/python2.7/dist-packages/_meep${MPI}.so
rm /usr/local/lib/python2.7/dist-packages/meep${MPI}.py
rm /usr/local/lib/python2.7/dist-packages/meep${MPI}.pyc
rm /usr/local/lib/python2.7/dist-packages/python_meep-1.4.egg-info
echo done.
