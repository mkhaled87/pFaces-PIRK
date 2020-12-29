#!/bin/sh

# CMake cofiguration
BUILDTYPE=Release
KERNEL_NAME=pirk

# remove old build files and binaries
rm -rf kernel-pack/$KERNEL_NAME

# building ...
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=$BUILDTYPE
cmake --build . --config $BUILDTYPE
cd ..
rm -rf build
