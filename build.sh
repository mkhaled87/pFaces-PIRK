#!/bin/sh

# CMake configs
BUILD_TYPE=Release
KERNEL_NAME=pirk
CLEAN_BUILD=true

# remove old build binaries
if [ $CLEAN_BUILD = true ]
then 
    rm -rf kernel-pack/$KERNEL_NAME.driver
    rm -rf build
fi

# building ...
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE
cmake --build . --config $BUILD_TYPE
cd ..
