cmake_minimum_required(VERSION 3.6)

# Name of the project
project(pFaces-PIRK)

# Include CMake configs for pFaces
if("$ENV{PFACES_SDK_ROOT}" STREQUAL "")
  message(FATAL_ERROR "Please make sure pFaces is installed correctly.")
else()
  include($ENV{PFACES_SDK_ROOT}/pfaces_kernel.cmake)
endif()

# Kernel name and its sources
set(PFACES_KERNEL pirk)
set(PFACES_KERNEL_SOURCES 
    ${PROJECT_SOURCE_DIR}/kernel/pirk_io.cpp
    ${PROJECT_SOURCE_DIR}/kernel/pirk_utils.cpp
    ${PROJECT_SOURCE_DIR}/kernel/pirk_ctmm.cpp
    ${PROJECT_SOURCE_DIR}/kernel/pirk_growthbound.cpp
    ${PROJECT_SOURCE_DIR}/kernel/pirk_montecarlo.cpp
    ${PROJECT_SOURCE_DIR}/kernel/pirk_montecarlo_hd.cpp
    ${PROJECT_SOURCE_DIR}/kernel/pirk.cpp
)
set(PFACES_KERNEL_OUT_PATH "${PROJECT_SOURCE_DIR}/kernel-pack")

# Generic CMake instructions to make the kernel
link_directories($ENV{PFACES_SDK_ROOT}/lib)
ADD_LIBRARY(${PFACES_KERNEL} SHARED
    ${PFACES_KERNEL_SOURCES}
)
target_include_directories(${PFACES_KERNEL} PUBLIC
    ${OpenCL_INCLUDE_DIR}
    $ENV{PFACES_SDK_ROOT}/include
)

# Include link configs for the kernel.
include($ENV{PFACES_SDK_ROOT}/pfaces_link.cmake)
