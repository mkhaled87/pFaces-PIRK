cmake_minimum_required(VERSION 3.6)

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

# [Update Here] Must use C++11 or later
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Needed packages
find_package(OpenCL REQUIRED)
find_package(cpprestsdk REQUIRED NAMES cpprestsdk cpprest)

# Generic CMake instructions to make the kernel
ADD_LIBRARY(${PFACES_KERNEL} SHARED
    ${PFACES_KERNEL_SOURCES}
)
target_include_directories(${PFACES_KERNEL} PUBLIC
    ${OpenCL_INCLUDE_DIR}
    $ENV{PFACES_SDK_ROOT}/include
)
target_link_directories(${PFACES_KERNEL} PUBLIC
    $ENV{PFACES_SDK_ROOT}/lib
)
set_target_properties(${PFACES_KERNEL}
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${PFACES_KERNEL_OUT_PATH}
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${PFACES_KERNEL_OUT_PATH}
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ${PFACES_KERNEL_OUT_PATH}
    SUFFIX ".driver"
    PREFIX ""
)
if (MSVC)
    set_target_properties(${PFACES_KERNEL} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE")
    target_link_libraries(${PFACES_KERNEL} pfaces-sdk ${OpenCL_LIBRARY} cpprestsdk::cpprest)
elseif (APPLE)
    set_target_properties(${PFACES_KERNEL} PROPERTIES LINK_FLAGS "-Wl,-all_load")
    target_link_libraries(${PFACES_KERNEL} pfaces-sdk ${OpenCL_LIBRARY} cpprestsdk::cpprest dl pthread)
elseif (UNIX)
    set_target_properties(${PFACES_KERNEL} PROPERTIES LINK_FLAGS "-Wl,--whole-archive")
    target_link_libraries(${PFACES_KERNEL} pfaces-sdk ${OpenCL_LIBRARY} cpprestsdk::cpprest pthread boost_system)
else()
    message(FATAL_ERROR "You are using a not-supported build system!")
endif ()

# suppress some warnings
if(UNIX OR APPLE)
    target_compile_options(${PFACES_KERNEL} PRIVATE -Wno-deprecated -Wno-ignored-attributes -Wno-nullability-completeness-on-arrays)
elseif(MSVC)
    target_compile_options(${PFACES_KERNEL} PRIVATE /wd4267 /wd4996 /wd4101 /wd4390)
endif()


