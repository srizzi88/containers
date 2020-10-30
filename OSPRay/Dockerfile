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
    ncurses-devel \
    xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps \
    libX11-devel \
    libXt-devel \
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
    rsh \ 
    rsh-server
#run yum autoremove -y \
# && yum clean all
run yum autoremove -y

############################
# Build directory structure
############################

run mkdir /paraview \
 && mkdir /paraview/build \
 && mkdir /paraview/src \
 && mkdir /paraview/install 
# && mkdir /sensei \
# && mkdir /sensei/build \
# && mkdir /sensei/src \
# && mkdir /sensei/install

###############
# CMake
###############

#workdir /paraview/src
#run wget https://cmake.org/files/v3.17/cmake-3.17.3.tar.gz \
# && tar xzf cmake-3.17.3.tar.gz \
# && rm cmake-3.17.3.tar.gz

#run mkdir /paraview/build/CMake 
#workdir /paraview/build/CMake
#run /paraview/src/cmake-3.17.3/bootstrap --prefix=/paraview/install/CMake
#run make -j8
#run make install

workdir /paraview/install
run wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4-Linux-x86_64.tar.gz \
 && tar xvzf cmake-3.18.4-Linux-x86_64.tar.gz \
 && rm cmake-3.18.4-Linux-x86_64.tar.gz \
 && mv cmake-3.18.4-Linux-x86_64 cmake

# add cmake binaries to the path
#env PATH="/paraview/install/CMake/bin:$PATH"
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
 && cmake -G Ninja \
    -D CMAKE_INSTALL_PREFIX=/paraview/install/paraview \
    -D CMAKE_BUILD_TYPE=Release \
    -D PARAVIEW_BUILD_SHARED_LIBS=ON \
    -D BUILD_TESTING=OFF \
    -D VTK_PYTHON_VERSION=3 \
    -D PARAVIEW_BUILD_LEGACY_SILENT=ON \
    -D PARAVIEW_USE_MPI=ON \
    -D PARAVIEW_USE_PYTHON=ON \
    -D USE_CATALYST=ON \
    -D PARAVIEW_USE_QTHELP=OFF \
    -D PARAVIEW_ENABLE_WEB=OFF \
    -D PARAVIEW_ENABLE_RAYTRACING=ON \
    -D VTK_ENABLE_OSPRAY=ON \
    -D PARAVIEW_USE_QT=OFF \
    -D VTK_USE_X=OFF \
    -D CMAKE_SKIP_INSTALL_RPATH=TRUE \
    -D PARAVIEW_BUILD_SHARED_LIBS=ON \
    -D VTK_USE_PATH=OFF \
    -D PARAVIEW_RELOCATABLE_INSTALL=OFF \
    -D VTK_OPENGL_HAS_OSMESA=ON \
    -D OSMESA_INCLUDE_DIR="/usr/include/GL/" \
    -D OSMESA_LIBRARY="/usr/lib64/libOSMesa.so" \
    /paraview/src/ParaView
RUN cd /paraview/build/paraview \
 && ninja \
 && ninja install




# remove mpich to avoid any possible conflict with system libraries
run sudo rm -rf /paraview/install/mpich

# point to correct directory

#env LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/paraview/lib64/"
###############################################################################



#run wget "http://springdale.princeton.edu/data/springdale/7/x86_64/os/Computational/libGLEW2-2.0.0-4.sdl7.x86_64.rpm" \
# && rpm -ivh libGLEW2-2.0.0-4.sdl7.x86_64.rpm

#run yum install libGLEW2 -y

#ENV PYTHONPATH=/usr/local/paraview/lib64/python3.6/site-packages:/usr/local/paraview/lib64/python3.6/site-packages/vtkmodules:/usr/local/paraview/lib64/python3.6/site-packages/paraview/modules

# Add copied libraries and ParaView's python modules to the environment library path
#ENV LD_LIBRARY_PATH="/usr/local/lib64:/ospray/lib:/usr/local/paraview/lib64/python3.6/site-packages/vtkmodules:/mdl/linux-x86-64/lib:/optix/lib64:/index/lib:$LD_LIBRARY_PATH"

