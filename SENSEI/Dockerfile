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
    mesa-libOSMesa-devel \
    wget \
    git \
    sudo \
    ncurses-devel \
    freeglut-devel \
    vim \
    automake \
    openssl-devel \
    epel-release \
    python3-devel \
    python3-numpy \
    tbb-devel \
    ninja-build \
    openssh-server \ 
    openssh-clients \
    libXt-devel

############################
# Build directory structure
############################

run mkdir /sensei \
 && mkdir /sensei/build \
 && mkdir /sensei/src \
 && mkdir /sensei/install
   
###############
# CMake
###############

workdir /sensei/install
run wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4-Linux-x86_64.tar.gz \
 && tar xvzf cmake-3.18.4-Linux-x86_64.tar.gz \
 && rm cmake-3.18.4-Linux-x86_64.tar.gz \
 && mv cmake-3.18.4-Linux-x86_64 cmake

# add cmake binaries to the path
#env PATH="/paraview/install/CMake/bin:$PATH"
env PATH="/sensei/install/cmake/bin:$PATH"
 
##############
# Mpich 3.2.1
##############

workdir /sensei/src
run wget -q http://www.mpich.org/static/downloads/3.2.1/mpich-3.2.1.tar.gz \
 && tar xzf mpich-3.2.1.tar.gz \
 && rm mpich-3.2.1.tar.gz

run mkdir /sensei/build/mpich
workdir /sensei/build/mpich

# disable the addition of the RPATH to compiled executables
# this allows us to override the MPI libraries to use those
# found via LD_LIBRARY_PATH
run /sensei/src/mpich-3.2.1/configure --prefix=/sensei/install/mpich --disable-wrapper-rpath
run make -j8 \
 && make install

# add to local environment
env PATH="/sensei/install/mpich/bin:$PATH"
env LD_LIBRARY_PATH="/sensei/install/mpich/lib:$LD_LIBRARY_PATH"

# VTK

run cd /sensei/src \
 && wget https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz \
 && tar xzf VTK-8.2.0.tar.gz \
 && rm VTK-8.2.0.tar.gz

run cd /sensei/build \
 && mkdir vtk \
 && cd vtk

run cmake \
     -DCMAKE_INSTALL_PREFIX=/sensei/install/vtk \
   /sensei/src/VTK-8.2.0
   
run make -j8 \
 && make install 
   
   
# SENSEI

run cd /sensei/src \
 && git clone https://gitlab.kitware.com/sensei/sensei.git \
 && cd sensei \
 && git checkout v2.1.1

run cd /sensei/build \
 && mkdir sensei \
 && cd sensei

workdir /sensei/build
run cmake \
     -DENABLE_SENSEI=ON \
     -DENABLE_ADIOS=OFF \
     -DENABLE_PARALLEL3D=OFF \
     -DENABLE_VTK_IO=ON \
     -DENABLE_VTK_MPI=OFF \
     -DCMAKE_INSTALL_PREFIX=/sensei/install/sensei \
     -DVTK_DIR=/sensei/install/vtk/lib64/cmake/vtk-8.2 \
   /sensei/src/sensei
   
run make -j8 \
 && make install

env PATH="$PATH:/sensei/install/sensei/bin"
env LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/sensei/install/vtk/lib64"

run rm -rf /sensei/build \
 && rm -rf /sensei/src


