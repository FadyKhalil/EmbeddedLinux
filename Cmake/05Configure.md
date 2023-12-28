# Configuration in Cmake



## Configure File

If i want Cmake to generate a file that has some definition such as product_year, minor and major version, and those variable can printed in source file normally and be used.

```cmake
set(PRODUCT_YEAR "2020")
configure_file(config.h.in config.h)
target_include_directories(targetname PUBLIC ${PROJECT_BINARY_DIR})
```

In `config.h.in`

```cmake
##### this is configured within the configure file
#define ProductType "value"

#### this variable can be assigned in cmake file
#define ProductYear "${PRODUCT_YEAR}"

#### this to get importent variable 
#define MY_VERSION_MAJOR @PROJECT_VERSION_MAJOR@
#define MY_VERSION_MINOR @PROJECT_VERSION_MINOR@
```





## Reading Files

The other direction can be done too; you can read in something (like a version) from your source files. If you have a header only library that you'd like to make available with or without CMake, for example, then this would be the best way to handle a version. This would look something like this:

```cmake
# Assuming the canonical version is listed in a single line
# This would be in several parts if picking up from MAJOR, MINOR, etc.
set(VERSION_REGEX "#define MY_VERSION[ \t]+\"(.+)\"")

# Read in the line containing the version
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/include/My/Version.hpp"
    VERSION_STRING REGEX ${VERSION_REGEX})

# Pick out just the version
string(REGEX REPLACE ${VERSION_REGEX} "\\1" VERSION_STRING "${VERSION_STRING}")

# Automatically getting PROJECT_VERSION_MAJOR, My_VERSION_MAJOR, etc.
project(My LANGUAGES CXX VERSION ${VERSION_STRING})
```

Above, `file(STRINGS file_name variable_name REGEX regex)` picks lines that match a regex; and the same regex is used to then pick out the parentheses capture group with the version part. Replace is used with back substitution to output only that one group.



## Running a command at build time

Build time commands are a bit trickier. The main complication comes from the target system; when do you want your command to run? Does it produce an output that another target needs? With this in mind, here is an example that calls a Python script to generate a header file:

```cmake
add_custom_target(flash ALL
    DEPENDS main.elf
    COMMAND avr-objcopy -j .text -j .data -o ihex main.elf main.hex
    )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/Generated.hpp DESTINATION include)
```

ALL here is used to run the command with make command.