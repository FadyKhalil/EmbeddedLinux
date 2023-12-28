# CMake Overview

## What is CMake?

[CMake](https://cmake.org/) is an open-source cross-platform build system designed to control the software building process. It allows developers to describe the build process in a platform-independent manner, and it generates native build files (such as Makefiles or project files for IDEs) based on the configuration provided.

## Key Concepts

### CMakeLists.txt

The heart of CMake configuration is the `CMakeLists.txt` file. This file, typically located in the root of the project, contains instructions for CMake regarding how to build the project. It includes details like source files, dependencies, and build targets.

### Configure and Generate

CMake operates in two main steps: configure and generate. During the configure step, CMake reads the `CMakeLists.txt` file and checks the system for necessary libraries, compilers, and other dependencies. In the generate step, CMake creates platform-specific build files based on the configuration.

### Build Directories

CMake supports out-of-source builds, meaning the build files and the source code are in separate directories. This helps keep the source directory clean and facilitates building the same codebase with different configurations. (**use mkdir to create a directory build**)

## Basic Workflow

1. **Create CMakeLists.txt:** Start by creating a `CMakeLists.txt` file in your project directory. This file specifies project details, source files, and any dependencies.

2. **Configure:** Run `cmake` in the terminal, pointing it to the directory containing your `CMakeLists.txt` file. This step identifies the system environment and generates build files.

   ```bash
   cmake path/to/your/project
   ```

3. **Generate:** After configuring, use the generated build files to compile your project. For Makefiles, run:

   ```bash
   make
   ```

4. **Run and Test:** Execute the built executable or test files as needed.

## Example CMakeLists.txt

```cmake
# minimum required version of cmake to run
cmake_minimum_required(VERSION 3.12)

# This is your project statement. You should always list languages;
# Listing the version is nice here since it sets lots of useful variables
project(MyProject VERSION 1.0
                  DESCRIPTION "my first project"
                  LANGUAGES CXX)

# Add source files
add_executable(my_executable main.cpp)
```