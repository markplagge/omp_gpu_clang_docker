#!/bin/sh
##LLVM DOCKER BUILD SCRIPT - ENSURE CLANG is installed
mkdir llvm-work
cd llvm-work
git clone https://github.com/llvm/llvm-project.git
cd llvm-project
mkdir build
mkdir install
mkdir build_bs
cd build
cmake -DLLVM_ENABLE_PROJECTS="openmp;clang;libcxx;libcxxabi;parallel-libs;lld;llvm;lldb;libclc;clang-tools-extra" \
-DCMAKE_BUILD_TYPE="RELEASE" \
-DCMAKE_INSTALL_PREFIX=$(pwd)/../install \
-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_61 \
-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,35 \
-DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
../llvm
make -j40
make -j40 install

cd ..
cd build_bs

cmake -DLLVM_ENABLE_PROJECTS:"openmp;clang;libcxx;libcxxabi;parallel-libs;lld;llvm;lldb;libclc;clang-tools-extra" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_C_COMPILER=$(pwd)/../install/bin/clang \
-DCMAKE_CXX_COMPILER=$(pwd)/../install/bin/clang++ \
-DCLANG_DEFAULT_CXX_LIB=libc++ \
-DCLANG_DEFAULT_RTLIB=compiler-rt \
-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_61 \
-DLIBOMP_USE_DEBUGGER=ON \
-DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=ON \
-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=61,35 \
-DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=`which gcc-7` \
../llvm

make -j40
make -j40 install

