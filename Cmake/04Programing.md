# Programing Language



## Control flow

Cmake is like any other programing language and it support if condition 

```cmake
f(variable)
    # If variable is `ON`, `YES`, `TRUE`, `Y`, or non zero number
else()
    # If variable is `0`, `OFF`, `NO`, `FALSE`, `N`, `IGNORE`, `NOTFOUND`, `""`, or ends in `-NOTFOUND`
endif()
# If variable does not expand to one of the above, CMake will expand it then try again
```

here variable can be replace by many other case such as env variable and local variable discussed in previous chapters.

```cmake
if("${variable}")
    # True if variable is not false-like
else()
    # Note that undefined variables would be `""` thus false
endif()
```

There are a variety of keywords as well, such as:

- Unary: `NOT`, `TARGET`, `EXISTS` (file), `DEFINED`, etc.
- Binary: `STREQUAL`, `AND`, `OR`, `MATCHES` (regular expression), `VERSION_LESS`, `VERSION_LESS_EQUAL` (CMake 3.7+), etc.
- Parentheses can be used to group



## Macros and Functions

You can define your own CMake [`function`](https://cmake.org/cmake/help/latest/command/function.html) or [`macro`](https://cmake.org/cmake/help/latest/command/macro.html) easily. The only difference between a function and a macro is scope. So, if you set a variable in a function and want it to be visible outside, you'll need `PARENT_SCOPE`. 

```cmake
function(functionName REQUIRED_ARG)
    message(STATUS "Simple arguments: ${REQUIRED_ARG}, followed by ${ARGN}")
    set(${REQUIRED_ARG} "From SIMPLE" PARENT_SCOPE)
    # without PARENT_SCOPE the variable won't be seen outside of the scope
endfunction()

functionName(This Foo Bar)
message("Output: ${This}")
```

```cmake
# Define the macro
macro(print_message message)
    # Create a variable to hold the formatted message
    set(formatted_message "[Macro Message] ${message}")

endmacro()

# Example usage of the macro
print_message("Hello, this is a custom message.")

# Print the formatted message
message(STATUS ${formatted_message})
```

We can see from macro from this example it will print the variable however we can see it's local but because cmake treated as text replacement not as function.

if we did the same for function it won't work.