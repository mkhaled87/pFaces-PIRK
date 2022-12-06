cmake_minimum_required(VERSION 3.6)

# Check: supported OS
if(NOT APPLE AND NOT UNIX AND NOT WIN32)
    message(FATAL_ERROR "You are using not-supported OS.")
endif()

# check installation of pFaces/pFaces-SDK
if (WIN32)
find_program(PFACES_BINARY "pfaces.bat")
else()
find_program(PFACES_BINARY "pfaces")
endif()
if( (NOT PFACES_BINARY) OR ("$ENV{PFACES_SDK_ROOT}" STREQUAL "") OR (NOT EXISTS "$ENV{PFACES_SDK_ROOT}/include") OR (NOT EXISTS "$ENV{PFACES_SDK_ROOT}/lib"))
    message(FATAL_ERROR "couldn't find pFaces binary. Please make sure to install it correctly.")
else()
    file(READ "$ENV{PFACES_SDK_ROOT}/VERSION" PFACES_VERSION)
    string(SUBSTRING "${PFACES_VERSION}" 24 3 PFACES_VERSION)
    message(STATUS "pFaces binary and SDK environment found (pFaces v${PFACES_VERSION}).")
endif()

# [Update Here] give a name to the project
project(pFaces-PIRK)

# [Update Here] set kernel name and its sources
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

# Set C++ Standard
if (${PFACES_VERSION} GREATER_EQUAL 1.3)
set(CMAKE_CXX_STANDARD 14)
else()
set(CMAKE_CXX_STANDARD 11)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Check: Win -> MSVC
if(WIN32 AND NOT MSVC)
    message(FATAL_ERROR "We only support MSVC++ compiler in Windows.")
endif()

# fix CMake for Ubuntu
if(UNIX)
	set(CMAKE_PREFIX_PATH /usr/lib/x86_64-linux-gnu/cmake/)
endif()

# Needed packages
find_package(OpenCL REQUIRED)
find_package(cpprestsdk REQUIRED NAMES cpprestsdk cpprest)

# Generic CMake instructions to make the kernel
link_directories($ENV{PFACES_SDK_ROOT}/lib)
ADD_LIBRARY(${PFACES_KERNEL} SHARED
    ${PFACES_KERNEL_SOURCES}
)
target_include_directories(${PFACES_KERNEL} PUBLIC
    ${OpenCL_INCLUDE_DIR}
    $ENV{PFACES_SDK_ROOT}/include
)
set_target_properties(${PFACES_KERNEL}
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${PFACES_KERNEL_OUT_PATH}"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PFACES_KERNEL_OUT_PATH}"
    LIBRARY_OUTPUT_DIRECTORY_DEBUG "${PFACES_KERNEL_OUT_PATH}"
    ARCHIVE_OUTPUT_DIRECTORY "${PFACES_KERNEL_OUT_PATH}"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PFACES_KERNEL_OUT_PATH}"
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${PFACES_KERNEL_OUT_PATH}"
    RUNTIME_OUTPUT_DIRECTORY "${PFACES_KERNEL_OUT_PATH}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PFACES_KERNEL_OUT_PATH}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${PFACES_KERNEL_OUT_PATH}"
    SUFFIX ".driver"
    PREFIX ""
)
if (MSVC)
    set_target_properties(${PFACES_KERNEL} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:pfaces-sdk.lib")
    target_link_libraries(${PFACES_KERNEL} ${OpenCL_LIBRARY} cpprestsdk::cpprest ws2_32)
elseif (APPLE)
    set_target_properties(${PFACES_KERNEL} PROPERTIES LINK_FLAGS "-Wl,-all_load -lpfaces-sdk")
    target_link_libraries(${PFACES_KERNEL} ${OpenCL_LIBRARY} cpprestsdk::cpprest dl pthread ${OPENSSL_LIBRARIES}) 
else()
    set_target_properties(${PFACES_KERNEL} PROPERTIES LINK_FLAGS "-Wl,--whole-archive -lpfaces-sdk -Wl,--no-whole-archive")
    target_link_libraries(${PFACES_KERNEL} ${OpenCL_LIBRARY} cpprestsdk::cpprest pthread boost_system)
endif()

# suppress some warnings
if(UNIX OR APPLE)
    target_compile_options(${PFACES_KERNEL} PRIVATE -Wno-deprecated -Wno-ignored-attributes -Wno-nullability-completeness-on-arrays)
elseif(MSVC)
    target_compile_options(${PFACES_KERNEL} PRIVATE /wd4267 /wd4996 /wd4101 /wd4390)
endif()


