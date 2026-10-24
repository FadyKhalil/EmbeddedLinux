# Cross-compiling with CMake

> Build any CMake project for the board with one toolchain file, and check the result is an ARM binary.

| | |
|---|---|
| **Previous** | [Configure & custom commands](05-configure.md) |
| **Uses** | The cross toolchain from [lesson 2](../../02-toolchain/README.md) |

## Why a toolchain file?

CMake picks the compiler the **first time** it configures a build folder, before reading your `CMakeLists.txt`
in detail. Setting `CMAKE_C_COMPILER` inside `CMakeLists.txt` is therefore too late, or ignored. The clean way
is a **toolchain file** given on the command line: it tells CMake the target system, the compilers, and where
it may look for target libraries.

## The toolchain file

[`toolchain-arm.cmake`](toolchain-arm.cmake) reads the same `CROSS_COMPILE` variable every lesson uses:

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER   $ENV{CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER $ENV{CROSS_COMPILE}g++)

# programs come from the host, libraries and headers only from the target
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
```

## Build `heartbeat` with CMake

The course's demo daemon ([`06-init/app`](../../06-init/README.md#1-build-heartbeat)) has a `CMakeLists.txt`
next to its Makefile:

```bash
source <path-to-this-repo>/docs/scripts/setenv-cross.sh     # sets CROSS_COMPILE
cd <path-to-this-repo>/docs/06-init/app

cmake -B build -DCMAKE_TOOLCHAIN_FILE=../../extras/cmake/toolchain-arm.cmake
cmake --build build
file build/heartbeat
```

```text
build/heartbeat: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, ...
```

Install it straight into the rootfs folder from lesson 5:

```bash
sudo cmake --install build --prefix $HOME/rootfs/usr
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `CROSS_COMPILE is not set` | New terminal | `source docs/scripts/setenv-cross.sh` |
| Still builds an x86 binary | Build folder configured before with the host compiler | Delete `build/` and configure again |
| `Could not find ...` for a library | It only exists on the host | Build it for the target too, and point `SYSROOT` at a rootfs that contains it |

## Exercises

1. Build the [CMake example](example/CMakeLists.txt) for the board with the same toolchain file.
2. Add `-DCMAKE_BUILD_TYPE=Release` and compare the binary size with `ls -l`.
