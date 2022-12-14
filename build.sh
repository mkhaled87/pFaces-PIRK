#!/bin/sh

# CMake cofiguration
BUILDTYPE=Release
KERNEL_NAME=pirk
CLEAN_BUILD=false

# remove old build binaries
if [ $CLEAN_BUILD = true ]
then 
    rm -rf kernel-pack/$KERNEL_NAME.driver
    rm -rf build
fi

# building ...
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=$BUILDTYPE
cmake --build . --config $BUILDTYPE
cd ..
