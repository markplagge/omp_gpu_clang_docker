#Docker image for OMP-Target / Clang / MPI Build env.
#Using NVIDIA docker image
FROM nvidia/cuda:9.2-devel-ubuntu18.04
ARG NUM_CPU
ENV NUM_CPU ${NUM_CPU:-40}
#ARG SM_MAX
#ENV SM_MAX ${SM_MAX:-61}
run echo $NUM_CPU
#add llvm_configure.sh ./
env DEBIAN_FRONTEND=noninteractive
env INCLUDE_FOLDER=/llvm_work/install/include
env LIB_FOLDER=/llvm_work/lib

############################ OLD Redundant apt-issues ######################
#run apt-get install -y tzdata
#run apt-get update 
#run apt-get install -y clang-6.0 llvm-6.0 
#run apt-get update && apt-get  install -y \
#        vim git wget htop python python-dev \
#        cmake-curses-gui  build-essential \
#        checkinstall  \
#        libreadline-gplv2-dev libncursesw5-dev \
#        libssl-dev libsqlite3-dev \
#        screen tmux zsh \
#	libxml2-dev libcurses-ocaml-dev libncurses5-dev libxml2-dev \
#	swig swig3.0 libedit2 libedit-dev  libelf-dev 

#run apt-get install -y  libreadline-dev readline-common 

#run ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
#run dpkg-reconfigure --frontend noninteractive tzdata
##########################################################################
##########################################################################


## From Triton Docker Image 

#RUN apt-get update && apt-get install -y --no-install-recommends \
#        build-essential \
#        curl \
#        libfreetype6-dev \
#        pkg-config \
#        python \
#        python-dev \
#        rsync \
#        software-properties-common \
#        unzip
#
##
##############################################################################################################3
########## New Required and nice-to-have packages
run apt-get update
run apt-get install -y man
run apt-get install -y \
    clang-6.0 \
    llvm-6.0 \
    cmake \
    cmake-curses-gui \
    checkinstall \
    libreadline-gplv2-dev \
    libssl-dev \
    libxml2-dev \
    swig \
    readline-common \
    unzip \
    git \
    build-essential \
    libncursesw5-dev \
    libsqlite3-dev \
    libcurses-ocaml-dev \
    swig3.0 \
    wget \
    python \
    python-dev \
    libncurses5-dev \
    libedit2 \
    libfreetype6-dev \
    libxml2-dev \
    libedit-dev \
    python \
    libelf-dev \
    python-dev \
    #libreadline-dev \
    curl \
    rsync 
## Nice-to-haves
run apt-get install -y \
    vim \
    tmux \
    p7zip-full \
    htop \
    zsh \
    software-properties-common

### OLD MONOLITHIC SCRIPT BASED LLVM SETUP ###
#run bash llvm_configure.sh
#run chmod +x ./llvm_configure.sh
## run sh ./llvm_configure.sh Run inside docker for sanity checks
###########################################
############ LLVM BUILD ##################################

run wget https://github.com/llvm/llvm-project/archive/master.zip && unzip ./master.zip && mv ./llvm-project-master ./llvm_work
#add https://github.com/llvm/llvm-project/archive/master.zip /

#run unzip ./master.zip 
#run mv ./llvm-project-master ./llvm_work
#run git clone https://github.com/llvm/llvm-project.git ./llvm_work
run cd llvm_work && mkdir build && mkdir build_bs && mkdir install
run cd llvm_work/build && \
cmake -DLLVM_ENABLE_PROJECTS="openmp;clang;libcxx;libcxxabi;parallel-libs;lld;llvm;lldb;libclc;clang-tools-extra" \
	-DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_C_COMPILER=`which clang-6.0` \
	-DCMAKE_CXX_COMPILER=`which clang++-6.0` \
	-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_61 \
	-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,52,35 \
	-DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
	-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
#	-DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=ON \i
#	-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,35 \
#	-DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
	-DLIBOMP_USE_DEBUGGER=ON \
	-DLLVM_ENABLE_BACKTRACES=ON \
	-DLLVM_ENABLE_CXX1Y=ON \
	-DLIBCXXABI_BUILD_STATIC=ON \
	-DLLVM_ENABLE_CXX1Z=ON \
#	-DCLANG_DEFAULT_STD_CXX="c++1y" \
#	-DCLANG_DEFAULT_STD_C="c11" \
	-LLVM_ENABLE_RUNTIMES="all" \
	../llvm
run cd llvm_work/build && make -j $NUM_CPU && make install

run mkdir ./llvm_work/omp && cd ./llvm_work/omp && cmake -DCMAKE_C_COMPILER=`which clang` -DCMAKE_CXX_COMPILER=`which clang++` \
-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,35 \
        -DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
        -DCLANG_DEFAULT_CXX_LIB=libc++ \
	-DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=ON \
        -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,52,35 \
        -DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
        -DLIBOMP_USE_DEBUGGER=ON \
	-DCMAKE_CXX_FLAGS="-std=c++14" \
../openmp
run cd ./llvm_work/omp && make -j $NUM_CPU && make -j $NUM_CPU install
#run cd llvm_work/build && cmake -DLLVM_ENABLE_PROJECTS="openmp;clang;libcxx;libcxxabi;parallel-libs;lld;llvm;lldb;libclc;clang-tools-extra" \
#-DCMAKE_BUILD_TYPE="RELEASE" \
#-DCMAKE_INSTALL_PREFIX=$(pwd)/../install \
#-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_61 \
#-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,35 \
#-DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
#../llvm 
#run cd llvm_work/build && make -j40 && make -j40 install
#
#run cd llvm_work/build_bs && cmake -DLLVM_ENABLE_PROJECTS:"openmp;clang;libcxx;libcxxabi;parallel-libs;lld;llvm;lldb;libclc;clang-tools-extra" \
#-DCMAKE_BUILD_TYPE=Release \
#-DCMAKE_C_COMPILER=$(pwd)/../install/bin/clang \
#-DCMAKE_CXX_COMPILER=$(pwd)/../install/bin/clang++ \
#-DCLANG_DEFAULT_CXX_LIB=libc++ \
#-DCLANG_DEFAULT_RTLIB=compiler-rt \
#-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_61 \
#-DLIBOMP_USE_DEBUGGER=ON \
#-DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=ON \
#-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,35 \
#-DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
#../llvm
#run cd llvm_work/build_bs && make -j40 && make -j40 install



#### LOCATE AND HELPER FUNS
RUN apt-get install -y locate 
RUN ldconfig
add veccopy.c ./veccopy.c
add reduction.c ./reduction.c
run updatedb

###################################
# GCC-8 Added for testing (omp-target, possible openACC)
## GCC 8 with openACC / OpenMP Offload
#RUN apt-get install -y gcc-8-offload-nvptx 

####################
# MPICH for MPI
####################
run update-alternatives --install /usr/bin/cc cc /usr/local/bin/clang 30 && update-alternatives --install /usr/bin/cxx cxx /usr/local/bin/clang++ 30
RUN cd / && \
#update-alternatives --install /usr/bin/cc cc /usr/bin/clang-8 30 && \
#update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-8 30 && \
wget  http://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz && \
tar -xvf ./mpich-3.3.tar.gz && \
cd mpich-3.3 && export CC=`which clang` && export CXX=`which clang++` && \
./configure --disable-fortran &&\
make -j 10 && make install
#remove tar.gz
run rm -f /mpich-3.3.tar.gz

################
# SSH
################
run apt-get update && apt-get install -y openssh-server
run mkdir /var/run/sshd
run echo 'root:dev' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

####
#User setup
###

#########################
##CLEANUP
#RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV CLANG_CXX_FLAGS="-fgnu -std=c++14 -fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -L/usr/local/lib -stdlib=libc++ -lm"
ENV CLANG_C_FLAGS="-fgnu  -fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -L/usr/local/lib -stdlib=libc++ -lm"
RUN rm -rf ./llvm_work/*
CMD ["/usr/sbin/sshd", "-D"]
