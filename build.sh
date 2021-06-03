#!/bin/sh

# CMake cofiguration
BUILDTYPE=Release
KERNEL_NAME=pirk

# check
if ! command -v cmake &> /dev/null
then
    echo "CMAKE is not installed. Please install it first."
    exit
fi

# remove old build files and binaries
rm -rf kernel-pack/$KERNEL_NAME

# building ...
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=$BUILDTYPE
cmake --build . --config $BUILDTYPE
cd ..
rm -rf build
