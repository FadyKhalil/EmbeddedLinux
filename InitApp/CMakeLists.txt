cmake_minimum_required(VERSION 3.16)

# The cross compiler must be known before project(), so pass it on the command line:
#   cmake -B build -DCMAKE_C_COMPILER=${CROSS_COMPILE}gcc
project(DEAMONAPP C)

add_executable(deamonapp deamonapp.c)

# link statically so the app runs on a rootfs without shared libraries
target_link_options(deamonapp PRIVATE -static)
