# OptiX Adjacent Container Recipes

Flick's build configuration:
* Docker version 20.10.7, build f0df350
* For `Dockerfile_centos8`, folders containing mdl-2019.1.1 and optix-6.5 in the same directory as the Dockerfile.
* For `Dockerfile_ubuntu`, the whole directory structure courtesy of Nvidia (because I hadn't pared it down at that point).

Unknown status / in progress:
* `Dockerfile_centos8` is the state of work with porting the ubuntu container to centos and adding native MPI.  Could hypothetically work on systems with mpich or mvapich2, but I couldn't get bindings for OpenMPI to work on ThetaGPU.

Working (but without native MPI):
* `Dockerfile_ubuntu` is the current production-ready version of the container.  Works on ThetaGPU, but no native MPI.

Old:
* `Dockerfile_justEGL` is a CentOS based container with only EGL, no IndeX or OptiX.
* `Dockerfile_NvidiaIndex` has both EGL and Nvidia IndeX (CentOS)
* `Dockerfile_sse3Errors` was the next progression to add OptiX to `Dockerfile_NvidiaIndex` but it had way too many errors and likely would not have worked.  This container was abandoned in favor of redoing everything and going with `Dockerfile_ubuntu`.
