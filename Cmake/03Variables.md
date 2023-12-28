# Variable and Cache



## Local Variables

To set a local variable in Cmake

```CMake
set(HELLO "value")
```

in order to access the following variables in another function provided by Cmake use `${}` meaning `${HELLO}` this will be replaced with `value`

The local variable is only defined within the scope of CMakeList.txt file created or a scope of function created in cmake file (will discuss about function later).

A variable can store list of values:

```cmake
set(LIST "one" "two")
# or
set(LIST "one;two")
```



## Cache Variables

The cache is actually just a text file, `CMakeCache.txt`, that gets created in the build directory when you run CMake. This is how CMake remembers anything you set, so you don't have to re-list your options every time you rerun CMake

If you want to set a variable from a command like how we use to do in Linux, Cmake offer `CACHE` keyword to make the variable in the cache.

This will be like the variable initiate by Cmake such as `CMAKE_CXX_BUILD`

```cmake
set(MY_CACHE_VARIABLE "VALUE" CACHE STRING "Description of the variable")
```

If you want to use the value as global variable we can add `FORCE`

```cmake
set(MY_CACHE_VARIABLE "VALUE" CACHE STRING "Description of the variable" FORCE)
```

We can as well set option of value to be set as true or false called `BOOL`

```cmake
option(MY_OPTION "This is settable from the command line" OFF)
# ON OFF
```

See [cmake-variables](https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html) for a listing of known variables in CMake.



## Environment Variables

in Cmake, you can as well set a variable as global by using the following commands

```cmake
# to set an env variable
set(ENV{variable_name} value)

# to get the env variable
$ENV{variable_name}
```

