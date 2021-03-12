Images are uploaded here:
https://hub.docker.com/repository/docker/srizzi/paraview-ospray

Article explaining how to squash docker images and reduce size
https://medium.com/@chamilad/docker-image-size-concerns-out-of-the-window-squash-with-confidence-796f7c48f5c6

Currently this container builds Paraview 5.9.0. The binaries are in /paraview/bin

This build needs to link dynamically to the native MPI libraries on the host.Specifically, pvserver and pvbatch need to link to libmpi.so.12 and libmpicxx.so.12. The user will need to bind the directories containing the dynamic libraries on the host system AND point LD_LIBRARY_PATH to them, perhaps also using symbolic links. Also note:
1. Those files may have different names on the host system, so symbolic links will be needed. For example, on Ubuntu I had to create the following symbolic links:
libmpi.so.12 -> /usr/lib/x86_64-linux-gnu/libmpich.so
libmpicxx.so.12 -> /usr/lib/x86_64-linux-gnu/libmpichcxx.so
2. Also, those libraries may have additional dependencies. On Ubuntu, fixing the two dependencies above trigger the additional dependence on libcr.so.0

  
