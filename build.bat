@ECHO OFF

rem CMake settings for using Visual Studio (you may only change the 
rem VS version with one from the list in 'cmake --help')
set BUILD_TYPE=Release
set KERNEL_NAME=pirk
set VS_VERSION="Visual Studio 17 2022"
set BUILD_DEF=-DCMAKE_BUILD_TYPE=%BUILD_TYPE%
set VCPKG_PATH=C:/src/vcpkg
set VCPKG_TRIPLET=-DVCPKG_TARGET_TRIPLET=x64-windows

rem Remove any old build
IF NOT EXIST .\build GOTO BUILDING
  rmdir /S/Q .\build

rem Building ....
:BUILDING
set vcpkg=-DCMAKE_TOOLCHAIN_FILE=%VCPKG_PATH%/scripts/buildsystems/vcpkg.cmake
mkdir build
cd build
cmake .. -Wno-dev -Wno-deprecated %BUILD_DEF% %vcpkg% %VCPKG_TRIPLET% -G %VS_VERSION%
cmake --build . --config %BUILD_TYPE%
cd ..