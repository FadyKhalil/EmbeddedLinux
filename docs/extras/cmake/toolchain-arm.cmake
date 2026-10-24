# CMake toolchain file for the course's cross compiler.
#
#   export CROSS_COMPILE=arm-cortexa9_neon-linux-gnueabihf-   # from lesson 2
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=<path>/toolchain-arm.cmake
#
# Optional: export SYSROOT to search headers and libraries of the target
# rootfs instead of the toolchain's own sysroot.

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

if(NOT DEFINED ENV{CROSS_COMPILE})
  message(FATAL_ERROR "CROSS_COMPILE is not set (e.g. arm-cortexa9_neon-linux-gnueabihf-)")
endif()

set(CMAKE_C_COMPILER   $ENV{CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER $ENV{CROSS_COMPILE}g++)

if(DEFINED ENV{SYSROOT})
  set(CMAKE_SYSROOT $ENV{SYSROOT})
endif()

# programs (like code generators) come from the host,
# libraries and headers only from the target
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
