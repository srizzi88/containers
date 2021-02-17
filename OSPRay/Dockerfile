FROM centos:centos7

SHELL ["/bin/bash", "-c"]

##########################
# Install CentOS packages
##########################

run yum update -y 
run yum groupinstall -y "Development Tools"
run yum install -y epel-release
run yum install -y \
    curl \
    gcc gcc-c++ \
    wget \
    git \
    sudo \
    vim \
    automake \
    openssl-devel \
    python3-devel \
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

# gcc 4.8.5 in Centos 7 is too old
# and causes problems
# We build our own GCC 9.2.0

###############
# GCC 9.2.0
# from https://gist.github.com/nchaigne/ad06bc867f911a3c0d32939f1e930a11
###############

workdir /paraview/src
run export GCC_VERSION=9.2.0 \
 && wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz \
 && tar xzvf gcc-${GCC_VERSION}.tar.gz \
 && rm gcc-${GCC_VERSION}.tar.gz \
 && cd gcc-${GCC_VERSION} \
 && ./contrib/download_prerequisites \
 && cd /paraview/build \
 && mkdir gcc \
 && cd gcc \
 && /paraview/src/gcc-${GCC_VERSION}/configure --disable-multilib --enable-languages=c,c++ --prefix=/paraview/install/gcc \
 && make -j 8 \
 && make install

# add to local environment
env PATH="/paraview/install/gcc/bin:$PATH"
env LD_LIBRARY_PATH="/paraview/install/gcc/lib64:$LD_LIBRARY_PATH"

# remove previous versions of gcc because
# they create conflicts with some paraview
# dependencies

run yum remove -y gcc gcc-c++

# but now libtool and libtoolize are also
# removed, so we need to build our own

workdir /paraview/src
run wget https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz \
 && tar xvf libtool-2.4.6.tar.gz \
 && rm libtool-2.4.6.tar.gz
run mkdir /paraview/build/libtool
workdir /paraview/build/libtool
run /paraview/src/libtool-2.4.6/configure --prefix=/paraview/install/libtool
run make -j8
run make install

env PATH="/paraview/install/libtool/bin:$PATH"
env LD_LIBRARY_PATH="/paraview/install/libtool/lib:$LD_LIBRARY_PATH"

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

run /paraview/src/mpich-3.2.1/configure --prefix=/paraview/install/mpich --disable-wrapper-rpath --disable-fortran
run make -j8 \
 && make install

# add to local environment
env PATH="/paraview/install/mpich/bin:$PATH"
env LD_LIBRARY_PATH="/paraview/install/mpich/lib:$LD_LIBRARY_PATH"

######################
# ParaView superbuild
######################

run cd /paraview/src \
 && git clone --recursive https://gitlab.kitware.com/paraview/paraview-superbuild.git 

workdir /paraview/src
run cmake -B /paraview/build/paraview -S /paraview/src/paraview-superbuild \
  -DCMAKE_BUILD_TYPE_paraview=Release \
  -DCMAKE_INSTALL_PREFIX="/paraview/install/paraview" \
  -DCMAKE_CXX_COMPILER="/paraview/install/gcc/bin/g++" \
  -DCMAKE_C_COMPILER="/paraview/install/gcc/bin/gcc" \
  -DENABLE_cxx11=ON \
  -Dparaview_SOURCE_SELECTION:STRING=git \
  -Dparaview_GIT_TAG="v5.9.0" \
  -DENABLE_zfp:BOOL=OFF \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DENABLE_netcdf:BOOL=OFF \
  -DENABLE_visitbridge:BOOL=OFF \
  -DENABLE_ffmpeg:BOOL=OFF \
  -DENABLE_qt5:BOOL=OFF \
  -DENABLE_mpi:BOOL=ON \
  -DUSE_SYSTEM_mpi:BOOL=ON \
  -DENABLE_paraview:BOOL=ON \
  -DENABLE_paraviewsdk:BOOL=ON \
  -DENABLE_xdmf3:BOOL=OFF \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DENABLE_vtkm:BOOL=OFF \
  -DENABLE_python3:BOOL=ON \
  -DUSE_SYSTEM_python3:BOOL=OFF \
  -DENABLE_pybind11:BOOL=OFF \
  -DENABLE_numpy:BOOL=ON \
  -DUSE_SYSTEM_numpy:BOOL=OFF \
  -DENABLE_scipy:BOOL=OFF \
  -DENABLE_matplotlib:BOOL=ON \
  -DENABLE_vrpn:BOOL=OFF \
  -DENABLE_cosmotools:BOOL=OFF \
  -DENABLE_osmesa:BOOL=ON \
  -Dmesa_USE_SWR:BOOL=OFF \
  -DENABLE_tbb:BOOL=ON \
  -DENABLE_silo:BOOL=OFF \
  -DENABLE_boost:BOOL=OFF \
  -DENABLE_vortexfinder2:BOOL=OFF \
  -DENABLE_las:BOOL=OFF \
  -DBUILD_TESTING:BOOL=ON \
  -DENABLE_adios2:BOOL=OFF \
  -DENABLE_ospray:BOOL=ON \
  -DENABLE_ospraymodulempi:BOOL=ON \
  -DENABLE_fontconfig:BOOL=ON \
  -DENABLE_bzip2:BOOL=ON \
  -DPARAVIEW_BUILD_EDITION:STRING=CATALYST_RENDERING \
  -DSUPERBUILD_DEFAULT_INSTALL:STRING=paraviewsdk/TGZ

workdir /paraview/build/paraview
run make download-all 
run make -j8
run make install

#env LD_LIBRARY_PATH=/paraview/install/paraview/lib64/:/paraview/install/ospray/lib:/paraview/install/paraview/lib64/python3.6/site-packages/vtkmodules:$LD_LIBRARY_PATH
#env PATH=/paraview/install/paraview/bin:$PATH

# delete sources to save space in the image
run rm -rf /paraview/src

#delete build files to save space
run rm -rf /paraview/build

