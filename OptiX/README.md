# OptiX Adjacent Container Recipes

* `Dockerfile_ubuntu` is the current production-ready version of the container.
* `Dockerfile_justEGL` is a CentOS based container with only EGL, no IndeX or OptiX.
* `Dockerfile_NvidiaIndex` has both EGL and Nvidia IndeX (CentOS)
* `Dockerfile_sse3Errors` was the next progression to add OptiX to `Dockerfile_NvidiaIndex` but it had way too many errors and likely would not have worked.  This container was abandoned in favor of redoing everything and going with `Dockerfile_ubuntu`.
