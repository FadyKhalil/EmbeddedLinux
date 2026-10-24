cmake_minimum_required(VERSION 3.16)

# Cross-compile with the toolchain file from the CMake extra lesson:
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=../../extras/cmake/toolchain-arm.cmake
#   cmake --build build
project(heartbeat C)

add_executable(heartbeat heartbeat.c)
target_compile_options(heartbeat PRIVATE -Wall -Wextra)

# static, so it runs on a rootfs without shared libraries
target_link_options(heartbeat PRIVATE -static)

install(TARGETS heartbeat RUNTIME DESTINATION bin)
