FROM nvidia/cudagl:10.1-devel-centos7 AS pv-build

SHELL ["/bin/bash", "-c"]

##########################
# Install CentOS packages
##########################

run yum update -y 
run yum groupinstall -y "Development Tools"
run yum install -y epel-release
run yum install -y \
    curl \
    gcc g++ \
    mesa-libGL-devel \
    mesa-libOSMesa-devel \
    wget \
    git \
    sudo \
    vim \
    automake \
    openssl-devel \
    python3-devel \
    python3-numpy \
    tbb-devel \
    openssh-clients  
run yum autoremove -y

############################
# Build directory structure
############################

run mkdir /paraview \
 && mkdir /paraview/build \
 && mkdir /paraview/src \
 && mkdir /paraview/install 

###############
# CMake
###############

workdir /paraview/install
run wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4-Linux-x86_64.tar.gz \
 && tar xvzf cmake-3.18.4-Linux-x86_64.tar.gz \
 && rm cmake-3.18.4-Linux-x86_64.tar.gz \
 && mv cmake-3.18.4-Linux-x86_64 cmake

# add cmake binaries to the path
env PATH="/paraview/install/cmake/bin:$PATH"

##############
# Mpich 3.2.1
##############

workdir /paraview/src
run wget -q http://www.mpich.org/static/downloads/3.2.1/mpich-3.2.1.tar.gz \
 && tar xzf mpich-3.2.1.tar.gz \
 && rm mpich-3.2.1.tar.gz

run mkdir /paraview/build/mpich
workdir /paraview/build/mpich

# disable the addition of the RPATH to compiled executables
# this allows us to override the MPI libraries to use those
# found via LD_LIBRARY_PATH
run /paraview/src/mpich-3.2.1/configure --prefix=/paraview/install/mpich --disable-wrapper-rpath
run make -j8 \
 && make install

# add to local environment
env PATH="/paraview/install/mpich/bin:$PATH"
env LD_LIBRARY_PATH="/paraview/install/mpich/lib:$LD_LIBRARY_PATH"

# OSPRay Directly from GitHub
workdir /paraview/install
run wget "https://github.com/ospray/ospray/releases/download/v1.8.5/ospray-1.8.5.x86_64.linux.tar.gz" \
 && tar -xzf ospray-1.8.5.x86_64.linux.tar.gz \
 && mv ospray-1.8.5.x86_64.linux ospray

###
# ParaView build
###

# Fetch paraview repo
# COPY ParaView-src /ParaView-src
RUN cd /paraview/src \
 && git clone https://github.com/Kitware/ParaView 
workdir /paraview/src/ParaView
run git checkout v5.8.0 \
 && git submodule update --init --recursive

# build paraview
#env VisRTX_DIR="/sensei/install/visrtx"
env ospray_DIR="/paraview/install/ospray"
run mkdir /paraview/build/paraview \
 && cd /paraview/build/paraview \
 && cmake \
    -D CMAKE_INSTALL_PREFIX=/paraview/install/paraview \
    -D CMAKE_BUILD_TYPE=Release \
    -D PARAVIEW_BUILD_SHARED_LIBS=ON \
    -D BUILD_TESTING=OFF \
    -D VTK_PYTHON_VERSION=3 \
    -D PARAVIEW_BUILD_LEGACY_SILENT=ON \
    -D PARAVIEW_USE_MPI=ON \
    -D PARAVIEW_USE_PYTHON=ON \
    -D PARAVIEW_USE_QTHELP=OFF \
    -D PARAVIEW_ENABLE_WEB=OFF \
    -D PARAVIEW_ENABLE_RAYTRACING=ON \
    -D VTK_ENABLE_OSPRAY=ON \
    -D PARAVIEW_USE_QT=OFF \
    -D VTK_USE_X=OFF \
    -D CMAKE_SKIP_INSTALL_RPATH=TRUE \
    -D PARAVIEW_BUILD_SHARED_LIBS=ON \
    -D PARAVIEW_RELOCATABLE_INSTALL=OFF \
    -D VTK_OPENGL_HAS_OSMESA=ON \
    -D OSMESA_INCLUDE_DIR="/usr/include/GL/" \
    -D OSMESA_LIBRARY="/usr/lib64/libOSMesa.so" \
    -D PARAVIEW_BUILD_MESA_LAUNCHER=ON \
    /paraview/src/ParaView
RUN cd /paraview/build/paraview \
 && make -j8 \
 && make install

env LD_LIBRARY_PATH=/paraview/install/paraview/lib64/:/paraview/install/ospray/lib:/paraview/install/paraview/lib64/python3.6/site-packages/vtkmodules:$LD_LIBRARY_PATH
env PATH=/paraview/install/paraview/bin:$PATH

# delete sources
run rm -rf /paraview/src

#delete build files
run rm -rf /paraview/build

