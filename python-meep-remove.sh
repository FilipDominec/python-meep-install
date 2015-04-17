# == Uninstall procedure ==
echo Removing locally compiled meep
rm /usr/local/bin/meep-mpi
rm /usr/local/include/meep.hpp
rm /usr/local/include/meep/mympi.hpp
rm /usr/local/include/meep/vec.hpp
rm /usr/local/lib/libmeep_mpi.a
rm /usr/local/lib/libmeep_mpi.la
rm /usr/local/lib/libmeep_mpi.so*
rm /usr/local/lib/pkgconfig/meep_mpi.pc
rm /usr/local/share/meep/casimir.scm
rm /usr/local/share/meep/meep-enums.scm
rm /usr/local/share/meep/meep.scm
echo 'Removing locally compiled python-meep (works for python 2.7)...'
rm /usr/local/lib/python2.7/dist-packages/_meep_mpi.so
rm /usr/local/lib/python2.7/dist-packages/meep_mpi.py
rm /usr/local/lib/python2.7/dist-packages/meep_mpi.pyc
rm /usr/local/lib/python2.7/dist-packages/python_meep-1.4.egg-info
echo done.
