#minimum version required to start cmake
cmake_minimum_required(VERSION 3.1...3.22)

#project name
project(HelloWorld)

#to print a variable
message(STATUS ${CMAKE_HOME_DIRECTORY})

#to set a variable
set(SRC_FILE main.cpp)

#to set compile flags
set(COMPILE_C_FLAGS "-v -g")

# read file content and display it
file(READ ${SRC_FILE} MAIN_TEXT)
message(${MAIN_TEXT})

# to change the compiler
# set(CMAKE_CXX_COMPILER /home/fady/x-tools/arm-cortexa9_neon-linux-gnueabihf/bin/arm-cortexa9_neon-linux-gnueabihf-g++)

#to create the executable
add_executable(helloworld ${SRC_FILE})

#to run another cmake in another directory
add_subdirectory(${CMAKE_HOME_DIRECTORY}/library)

#include the files that the cpp needs
target_include_directories(helloworld INTERFACE ${CMAKE_HOME_DIRECTORY}/include)

#link the library
target_link_libraries(helloworld PRIVATE mcalLib)

#give option to the compiler
target_compile_options(helloworld PRIVATE "-std=gnu++17")

# Define the macro
# replace the macro with function and see the difference.
macro(print_message message)
    # Create a variable to hold the formatted message
    set(formatted_message "[Macro Message] ${message}")

endmacro()
    
    
# Example usage of the macro
print_message("Hello, this is a custom message.")
# Print the formatted message
message(STATUS "helloo ${formatted_message}")