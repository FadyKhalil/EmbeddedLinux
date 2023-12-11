# Library

A library is a group of pre-compiled coded, called functions, to avoid repetition of code, package is created, called library.

Note: Library is not an executable.

## Static Library and Building Process

### Introduction

A **static library** is a collection of object files that are linked together during the compilation phase of a program. Unlike dynamic libraries, static libraries are linked with the program at compile time, resulting in a single executable file that contains the code from both the program and the library.

### Building a Static Library

#### 1. Write Your Code

Write the source code for your library. For example, let's create a simple library named `mylib` with a function `add_numbers`:

```c
#ifndef MYLIB_H
#define MYLIB_H

int add_numbers(int a, int b);

#endif
```

```c
#include "mylib.h"

int add_numbers(int a, int b) {
    return a + b;
}
```

#### 2. Compile the Source Files

Compile the source files (`mylib.c` in this case) into object files using a compiler like `gcc`:

```bash
gcc -c mylib.c -o mylib.o
```

#### 3. Create the Static Library

Use the `ar` (archiver) command to create the static library (`libmylib.a`):

```bash
ar rcs libmylib.a mylib.o
```

This command creates a static library (`libmylib.a`) and adds the object file (`mylib.o`) to it.

#### 4. Use the Static Library in Your Program

Now, you can use the static library in your main program. Create a program (`main.c`) that includes the library header and calls the library function:

```c
// main.c
#include <stdio.h>
#include "mylib.h"

int main() {
    int result = add_numbers(5, 7);
    printf("Result: %d\n", result);
    return 0;
}
```

#### 5. Compile Your Program with the Static Library

Compile your program with the static library:

```bash
gcc main.c -o my_program -L. -lmylib
# OR
gcc main.c -o my_program -L. libmylib
```

Here, `-L.` tells the linker to look for libraries in the current directory, and `-lmylib` links your program with `libmylib.a`.

#### 6. Run Your Program

Execute the compiled program:

```bash
./my_program
```

## Dynamic Library and Building Process

### Introduction

A **dynamic library** is a collection of compiled code that can be loaded into a program at runtime. Unlike static libraries, dynamic libraries are not embedded into the executable at compile time. Instead, they are linked at runtime, providing flexibility and modularity to the programs.

### Building a Dynamic Library

#### 1. Write Your Code

Similar to static libraries, write the source code for your library. For example, let's create a dynamic library named `mylib` with a function `add_numbers`:

```c
// mylib.h
#ifndef MYLIB_H
#define MYLIB_H

int add_numbers(int a, int b);

#endif
```

```c
// mylib.c
#include "mylib.h"

int add_numbers(int a, int b) {
    return a + b;
}
```

#### 2. Compile the Dynamic Library

Compile the source file into a shared object (dynamic library) using the `-shared` flag:

```bash
gcc -shared -fPIC -o libmylib.so mylib.c
```

The `-shared` flag indicates that you are creating a shared object, and `-fPIC` generates position-independent code, which is necessary for shared libraries.

#### 3. Use the Dynamic Library in Your Program

Create a program (`main.c`) that includes the library header and calls the library function:

```c
// main.c
#include <stdio.h>
#include "mylib.h"

int main() {
    int result = add_numbers(5, 7);
    printf("Result: %d\n", result);
    return 0;
}
```

#### 4. Compile Your Program with the Dynamic Library

Compile your program with the dynamic library:

```
gcc main.c -o my_program -L. -lmylib
```

Here, `-L.` tells the linker to look for libraries in the current directory, and `-lmylib` links your program with `libmylib.so`.

#### 5. Run Your Program

Execute the compiled program:

```bash
./my_program
```

