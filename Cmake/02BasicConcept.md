# Basics Concept

## Minimum Version

Here's the first line of every `CMakeLists.txt`, which is the required name of the file CMake looks for:

```cmake
cmake_minimum_required(VERSION 3.1)

# you can set a version from to by the following
cmake_minimum_required(VERSION 3.1...3.12)
```

The `cmake_minimum_required` command in CMake is required to set the version of the current cmake file use. The `VERSION` is a special keyword for this function, and the version value follows the keyword. In this documentation, you can click on the command name to access the [official documentation](https://cmake.org/cmake/help/latest/command/cmake_minimum_required.html). 

## Create project

Now, every top-level CMake file will have the next line:

```cmake
project(MyProject VERSION 1.0
                  DESCRIPTION "Very nice project"
                  LANGUAGES CXX)
```

Here Version describe the version of the project, and you can give small description to describe the project following by the language used for the project to compile.

## Making an executable

Although libraries are much more interesting, and we'll spend most of our time with them, let's start with a simple executable.

```cmake
add_executable(hellobinary main.cpp header.h)
```

here the executable is used to create a executable binary file which will be named `hellobinary`, `hellobinary` can be described as target as well. then the other input are the folder to be compiled taking in count that cmake is smart to know that header file are only to be included in the cpp file and will only proceed with compiling the `main.cpp` file. you can add many input file as you want after the target.

## Making a Library

Making a library is done with [`add_library`](https://cmake.org/cmake/help/latest/command/add_library.html), and is just about as simple:

```cmake
add_library(operation STATIC operations.cpp operations.h)
```

with the following command cmake will create a library named operation which as well represent a target. We can see here a keyword static which mean that cmake will create the library static `.a` however, if you want to created as shared replace `STATIC` witch `SHARED`

if you left it empty the library will be created by the value stored in the variable `BUILD_SHARED_LIBS`

## Usage of target

in order to include more directory to let cmake look at we use the [`target_include_directories`](https://cmake.org/cmake/help/latest/command/target_include_directories.html)

```cmake
target_include_directories(hellobinary INTERFACE include/)
```

here we are including `include` directory to the project to let cmake look at. `PUBLIC` explain that any target need target `hellobinary` must include the `include` file.

`INTERFACE` here is used if nothing depends on the directory include, is usually used with header file, as header file are not part of the compilation process.

[`target_link_libraries`](https://cmake.org/cmake/help/latest/command/target_link_libraries.html) is used to link a library to the executable that will be created, example:

```cmake
#link the library
target_link_libraries(helloworld PUBLIC operation)
```

we will discuss later how we created the operation mentioned.

# Quick Example

```cmake
#version required
cmake_minimum_required(VERSION 3.2)

project(Calculator LANGUAGES CXX)

add_library(operation STATIC src/operation.cpp include/calc/operation.hpp)
target_include_directories(operation PUBLIC include)
target_compile_features(operation PUBLIC cxx_std_11)

add_executable(calc apps/calc.cpp)
target_link_libraries(calc PUBLIC operation)
```